# Scraper State Design — 架構文件

## Context

NKUST-AP-Flutter 的爬蟲層由 7 個 Helper 類別組成，各自管理不同大學系統的 HTTP session。本次重構統一了爬蟲的狀態模型，並建立靈活的 runtime 切換架構。

### 關聯 Issue: [#342 — 登入成功但實際沒有資料](https://github.com/NKUST-ITC/NKUST-AP-Flutter/issues/342)

Issue #342 的根因鏈：

1. `_login()` 呼叫 `Helper.instance.login()` 成功 → Toast 顯示「登入成功」
2. `_getUserInfo()` 以 fire-and-forget 方式呼叫（無 await）
3. Server 因 race condition 回傳 code 2（session 過期），觸發 re-login
4. **致命缺陷**: `reLoginReTryCounts` 是 **static** 欄位，所有操作共用同一個計數器
5. 所有錯誤被 `_getUserInfo()` 的 catch-all 靜默吞掉

本次重構以 `ReloginMixin`（per-call 計數器）和 Login Mutex 直接解決。

---

## Architecture Overview

### Helper 依賴關係圖

```
Helper (Facade/Router) ── ScraperRegistry ── CrawlerSelector (enum-based)
├── WebApHelper (with ReloginMixin)
│   ├── implements CourseProvider, ScoreProvider, UserInfoProvider, SemesterProvider
│   ├── owns Dio + CookieJar (via ApiConfig.createScraperDio)
│   ├── loginToStdsys() → SSO to stdsys.nkust.edu.tw
│   ├── loginToLeave()  → SSO to leave.nkust.edu.tw
│   └── Login Mutex (_loginInProgress Completer)
│
├── StdsysHelper
│   ├── implements CourseProvider, ScoreProvider, UserInfoProvider, SemesterProvider
│   └── delegates Dio/CookieJar to WebApHelper (constructor injection)
│
├── LeaveHelper (with ReloginMixin)
│   ├── implements LeaveProvider
│   └── shares CookieJar with WebApHelper (constructor injection)
│
├── MobileNkustHelper
│   ├── implements CourseProvider, ScoreProvider, UserInfoProvider, BusProvider
│   └── independent Dio/CookieJar + WebView login
│
├── BusHelper (with ReloginMixin)
│   ├── implements BusProvider
│   └── independent Dio/CookieJar + encrypted login
│
└── NKUSTHelper
    └── 公告系統，無需登入，per-call retry loop
```

### Capability Interface + ScraperRegistry

6 個按功能分類的 capability interface 取代了 Helper 中的 switch 路由：

| Interface | Methods | Providers |
|-----------|---------|-----------|
| `CourseProvider` | `getCourseTable()` | WebApHelper, StdsysHelper, MobileNkustHelper |
| `ScoreProvider` | `getScores()` | WebApHelper, StdsysHelper, MobileNkustHelper |
| `UserInfoProvider` | `getUserInfo()`, `getUserPicture()` | WebApHelper, StdsysHelper, MobileNkustHelper |
| `SemesterProvider` | `getSemesters()` | WebApHelper, StdsysHelper |
| `BusProvider` | `getTimeTable()`, `bookBus()`, `cancelBus()`, `getReservations()`, `getViolationRecords()` | MobileNkustHelper, BusHelper |
| `LeaveProvider` | `getLeaves()`, `getSubmitInfo()`, `submit()` | LeaveHelper |

`ScraperRegistry` 根據 `CrawlerSelector` 的 `ScraperSource` enum 解析 provider：

```dart
final provider = registry.resolve<CourseProvider>(selector?.course);
final data = await provider.getCourseTable(year: '114', semester: '2');
```

### CrawlerSelector（Runtime Config from Firebase Remote Config）

```dart
class CrawlerSelector {
  final ScraperSource login;     // 登入方式
  final ScraperSource userInfo;  // 使用者資訊來源
  final ScraperSource course;    // 課表來源
  final ScraperSource score;     // 成績來源
  final ScraperSource semester;  // 學期列表來源
}
```

`ScraperSource` enum 值：`webap`, `stdsys`, `mobile`, `remoteConfig`

完全相容 Remote Config JSON（`"webap"` 等字串），`ScraperSource.fromString()` 自動轉換。

---

## Login Flow（登入流程）

### 概觀：所有登入路徑

```
┌─────────────────────────────────────────────────────────────────┐
│                     使用者按下「登入」                            │
│                     LoginPage._login()                          │
│                          │                                      │
│                          ▼                                      │
│                  Helper.login(username, password)                │
│                          │                                      │
│              ┌───────────┴───────────┐                          │
│              │                       │                          │
│   selector.login == mobile    selector.login == webap (default) │
│              │                       │                          │
│              ▼                       ▼                          │
│   WebApHelper.login()         WebApHelper.login()               │
│   + WebApHelper.loginVms()                                      │
│              │                       │                          │
│              └───────────┬───────────┘                          │
│                          │                                      │
│                          ▼                                      │
│             Helper._sessionState = Authenticated                │
│             Helper.username = username                           │
│             Helper.expireTime = loginResponse.expireTime        │
│                          │                                      │
│              ┌───────────┼───────────┐                          │
│              │           │           │                          │
│              ▼           ▼           ▼                          │
│      _getUserInfo() _loadCourse  _setupBusNotify()              │
│      (fire-and-forget)  Data     (fire-and-forget)              │
│              │                       │                          │
│      apQuery('ag003')    registry.resolve<BusProvider>(null)    │
│                          → MobileNkustHelper.getReservations()  │
└─────────────────────────────────────────────────────────────────┘
```

### 1. WebApHelper.login() — Captcha 登入

```
login(username, password, retryCounts=5)
  │
  ├── _loginInProgress != null? ──► 等待已進行的登入結果（Login Mutex）
  │
  ▼
_doLogin() — captcha loop (最多 5 次):
  │
  ├── GET validateCode.jsp → 驗證碼圖片
  ├── CaptchaUtils.extractByEucDist() → OCR 辨識
  ├── POST perchk.jsp {uid, pwd, etxt_code}
  │
  ▼ 解析 WebApParser.apLoginParser(response):
  │
  ├── code -1: 驗證碼錯誤 → 繼續 loop
  ├── code  0: 登入成功 → isLogin=true, return LoginResponse(expiry=now+6h)
  ├── code  1: 帳密錯誤 → throw GeneralResponse(1401)
  ├── code  4: 舊密碼提醒 → stayOldPwd() → 遞迴重試
  ├── code  5: 鎖定(5次) → throw GeneralResponse(1405)
  └── code 500: Server 錯誤 → throw GeneralResponse(503)

全部 5 次失敗 → throw GeneralResponse(1402, 'captcha error')

成功後:
  markReloginSuccess() → 記錄 _lastSuccessfulRelogin 時間戳
  _loginInProgress.complete(result)
```

**Login Mutex 行為**：

```
apQuery A ─── code 2 ───► login() ──► 取 captcha、POST
                                ▲
apQuery B ─── code 2 ───► login() ──► _loginInProgress != null
                                       → return _loginInProgress.future（等待 A 的結果）
```

防止並行 captcha 登入互相覆蓋 session。

### 2. WebApHelper.loginToStdsys() — 跨系統 SSO

```
loginToStdsys()
  │
  ├── _stdsysLoginExpireTime 有效？ → return 快取結果（跳過登入）
  │
  ▼
  checkLogin() → 確保 WebAP session 有效
  │
  ▼
  apQuery('ag304_01') → 取得 session token
  │                     （此處可能觸發 withAutoRelogin）
  ▼
  POST fnc.jsp {fncid: 'CK004'} → 取得 SkyDirect 參數
  │
  ▼
  POST stdsys.nkust.edu.tw/Student/Account/LoginBySkytekPortalNewWindow
  │
  ├── 成功（含 /Student/Home/Index）→ _stdsysLoginExpireTime = now+1h
  └── 失敗 → throw GeneralResponse(100, 'cancel')
```

**同樣的流程用於**：
- `loginToLeave()` → leave.nkust.edu.tw
- `loginToMobile()` → mobile.nkust.edu.tw
- `loginToOosaf()` → oosaf.nkust.edu.tw

### 3. BusHelper.busLogin() — 加密登入

```
busLogin()
  │
  ├── loginPrepare()
  │     ├── HEAD bus.kuas.edu.tw → 取得全域 cookie
  │     └── GET /API/Scripts/a1 → 下載 JS 加密程式碼
  │           └── BusEncrypt.jsEncryptCodeParser() → 解析加密種子
  │
  ▼
  POST /API/Users/login
  data: {
    account: username,
    password: password,
    n: busEncryptObject.loginEncrypt(username, password)
       └── 多層 MD5: 魔術字串 + 種子 + 帳密 → 加密 payload
  }
  │
  ├── code 200 + success=true → isLogin=true
  ├── code 400 → 校區錯誤 / 找不到使用者
  └── code 302 → 密碼錯誤
```

### 4. MobileNkustHelper.login() — WebView 互動登入

```
login(context, username, password, clearCache)
  │
  ├── 嘗試 cookie 快取:
  │     ├── MobileCookiesData.load() → 讀取已儲存的 cookies
  │     ├── setCookieFromData() → 還原到 CookieJar
  │     ├── isCookieAlive() → GET /Account/CheckExpire
  │     │     ├── 回傳 'alive' → return LoginResponse（跳過 WebView）
  │     │     └── 其他 → cookie 過期，繼續
  │     └── clearCache=true → 跳過快取
  │
  ▼
  Navigator.push(MobileNkustPage)
  │  └── InAppWebView → 自動填入帳密 → 使用者完成登入
  │        ├── onTitleChanged 偵測到 homeUrl → _finishLogin()
  │        │     ├── CookieManager.getCookies() → 擷取 cookies
  │        │     ├── data.save() → 持久化到 SharedPreferences
  │        │     └── Navigator.pop(true)
  │        └── 使用者取消 → Navigator.pop(false)
  │
  ├── result=true → return LoginResponse()
  └── result=false → throw GeneralResponse(100, 'cancel')
```

### 5. LeaveHelper — 請假系統登入

```
getLeaves() / getLeavesSubmitInfo()
  │
  ├── isLogin == true? → 跳過登入
  │
  └── isLogin == false/null
        │
        ▼
      _webApHelper.loginToLeave()
        └── WebApHelper 跨系統 SSO 到 leave.nkust.edu.tw
             → 成功後設定 LeaveHelper.instance.isLogin = true
```

LeaveHelper 的 `login()` 方法（需要 BuildContext 的互動式登入）是給 WebView 方式使用的，因為 leave 系統有 Google reCAPTCHA。

---

## Session Re-login 機制

### 兩層 Retry 架構

```
┌─────────────────────────────────────────────────────┐
│ Layer 1: HTTP Retry (RetryInterceptor)              │
│   觸發條件: timeout, 5xx                             │
│   行為: 指數退避重試，最多 3 次                       │
│   對 Helper 透明，不需知道                           │
├─────────────────────────────────────────────────────┤
│ Layer 2: Session Re-login (ReloginMixin)            │
│   觸發條件: server 回應 session 過期                 │
│     - WebAP: apLoginParser() == 2                   │
│     - Bus: code==400 + "未登入或是登入逾"             │
│   行為: 重新登入後重試                               │
│   per-call 計數器，操作間互相獨立                     │
└─────────────────────────────────────────────────────┘
```

### withAutoRelogin 流程

```
withAutoRelogin(action, relogin, isSessionExpired)
  │
  ▼
  執行 action()
  │
  ├── 成功 → return 結果
  │
  └── 失敗 + isSessionExpired(error) == true
        │
        ├── attempts >= maxRelogins → rethrow（放棄）
        │
        ├── attempts == 1 且 _lastSuccessfulRelogin < 30 秒前
        │     → 判定為 server race condition
        │     → delay 500ms → 重試 action()（不重新登入）
        │
        └── 其他情況
              → relogin()（完整重新登入）
              → markReloginSuccess()
              → delay 500ms → 重試 action()
```

**使用 ReloginMixin 的 Helper**:
- `WebApHelper` — maxRelogins=3, relogin=login(captcha)
- `BusHelper` — maxRelogins=5, relogin=busLogin(encrypted)
- `LeaveHelper` — maxRelogins=3 (目前未透過 withAutoRelogin 呼叫)

### Login Mutex（防止並行登入）

`WebApHelper.login()` 使用 `Completer<LoginResponse>? _loginInProgress` 確保同一時間只有一個 captcha 登入在進行：

```dart
Future<LoginResponse> login({...}) async {
    if (_loginInProgress != null) return _loginInProgress!.future;
    _loginInProgress = Completer<LoginResponse>();
    try {
      final result = await _doLogin(...);
      markReloginSuccess();
      _loginInProgress!.complete(result);
      return result;
    } catch (e) {
      _loginInProgress!.completeError(e);
      rethrow;
    } finally {
      _loginInProgress = null;
    }
}
```

---

## 狀態欄位一覽

### 全域狀態（Helper）

| 欄位 | 型別 | 用途 | 更新時機 |
|------|------|------|----------|
| `_sessionState` | `ScraperSessionState` (sealed) | 統一 session 狀態 | login 成功→Authenticated, clearSetting→Unauthenticated |
| `username` | `static String?` | 帳號（大寫） | login 時設定, clearSetting 時清除 |
| `password` | `static String?` | 密碼（記憶體中） | login 時設定, clearSetting 時清除 |
| `expireTime` | `static DateTime?` | 過期時間 | login 成功時設定 |
| `selector` | `static CrawlerSelector?` | Runtime provider 選擇 | 啟動時從 Preferences 載入, Remote Config 更新 |
| `reLoginCount` | `int` | Helper 層計數器 | 各 get* 成功後歸零（目前未遞增，待移除） |

### 各 Helper 狀態

| Helper | 欄位 | 型別 | 用途 |
|--------|------|------|------|
| WebApHelper | `isLogin` | `bool` | WebAP session 有效 |
| WebApHelper | `_loginInProgress` | `Completer?` | Login mutex |
| WebApHelper | `_stdsysLoginExpireTime` | `DateTime?` | Stdsys SSO 快取(1h) |
| WebApHelper | `_lastSuccessfulRelogin` | `DateTime?` | ReloginMixin 時間戳 |
| BusHelper | `isLogin` | `bool` | Bus API session 有效 |
| BusHelper | `busEncryptObject` | `static BusEncrypt` | 加密種子 |
| LeaveHelper | `isLogin` | `bool?` | Leave session 有效(tri-state) |
| MobileNkustHelper | `cookiesData` | `MobileCookiesData?` | WebView cookies |

### 清理流程（clearSetting）

```dart
static void clearSetting() {
    instance._sessionState = const Unauthenticated();
    expireTime = null;
    username = null;
    password = null;
    ApCommonPlugin.clearCourseWidget();
    ApCommonPlugin.clearUserInfoWidget();

    // 呼叫所有已註冊的 cleanup callbacks
    for (final callback in instance._cleanupCallbacks) {
      callback();
    }
}
```

Cleanup callbacks（在 `_registerProviders()` 中註冊）:
- WebApHelper: `logout()` + `dioInit()` + `isLogin=false`
- BusHelper: `isLogin=false` + `dioInit()`
- LeaveHelper: `isLogin=null`
- MobileNkustHelper: `cookiesData?.clear()`

---

## 資料流追蹤

### 課表取得流程

```
CoursePage._getCourseTables()
  │
  ▼
Helper.getCourseTables(semester)
  │
  ▼
registry.resolve<CourseProvider>(selector?.course)
  │
  ├── webap → WebApHelper.getCourseTable()
  │             └── apQuery('ag222', {arg01: year, arg02: semester})
  │                   └── withAutoRelogin → _doApQuery → checkLogin → POST
  │
  ├── stdsys → StdsysHelper.getCourseTable()
  │              ├── _webApHelper.loginToStdsys()
  │              │     ├── checkLogin() → 確保 WebAP 有效
  │              │     ├── apQuery('ag304_01') → session token
  │              │     └── POST LoginBySkytekPortal → SSO
  │              └── POST /student/Course/StudentCourseList/Query
  │
  └── mobile → MobileNkustHelper.getCourseTable()
                 └── POST /Student/Course {Yms: year-semester}
```

### 校車查詢流程

```
BusReservePage._getBusTimeTables(dateTime)
  │
  ▼
Helper.getBusTimeTables(dateTime)
  │
  ├── MobileNkustHelper.isSupport? (platform check)
  │   false → throw platformNotSupport
  │
  ▼
registry.resolve<BusProvider>(null) → 第一個註冊的 provider
  │
  ├── mobile (MobileNkustHelper) — 預設
  │     └── busTimeTableQuery(fromDateTime)
  │           ├── GET /Bus/Bus/Timetable → 提取 CSRF + busInfo
  │           ├── 4 路線並行 POST /Bus/Bus/GetTimetableGrid
  │           └── 合併結果 → BusData
  │
  └── webap (BusHelper) — fallback
        └── timeTableQuery(year, month, day)
              └── withAutoRelogin
                    ├── !isLogin? → busLogin() (加密登入)
                    ├── POST /API/Frequencys/getAll
                    ├── _checkBusSessionExpired()
                    │     code==400 + "未登入" → throw BusSessionExpiredException
                    │     → withAutoRelogin 捕獲 → busLogin() → 重試
                    └── 成功 → BusData
```

---

## Registry 註冊表

```dart
// _registerProviders() 中的完整註冊
ScraperSource.webap:
  CourseProvider    → WebApHelper.instance
  ScoreProvider     → WebApHelper.instance
  UserInfoProvider  → WebApHelper.instance
  SemesterProvider  → WebApHelper.instance
  BusProvider       → BusHelper.instance
  LeaveProvider     → LeaveHelper.instance

ScraperSource.stdsys:
  CourseProvider    → StdsysHelper.instance
  ScoreProvider     → StdsysHelper.instance
  UserInfoProvider  → StdsysHelper.instance
  SemesterProvider  → StdsysHelper.instance

ScraperSource.mobile:
  CourseProvider    → MobileNkustHelper.instance
  ScoreProvider     → MobileNkustHelper.instance
  UserInfoProvider  → MobileNkustHelper.instance
  BusProvider       → MobileNkustHelper.instance
```

### 新增爬蟲來源只需：
1. 實作對應的 capability interface
2. 在 `_registerProviders()` 註冊
3. 不需修改任何 switch 或路由邏輯

---

## 已知問題 / 未來改進

### 待處理

| # | 問題 | 說明 |
|---|------|------|
| 1 | **MobileNkustHelper 無 auto-relogin** | 作為 BusProvider 的預設 provider，cookie 過期後無法自動恢復，只能回 UI 層報錯。原因：登入需要 WebView 互動，無法自動化 |
| 2 | **`Helper.reLoginCount` 是死代碼** | 每個 `get*` 成功後歸零，但從未被遞增或檢查。應移除 |
| 3 | **`_sessionState` 未被 relogin 更新** | `withAutoRelogin` 的 `relogin` callback 呼叫的是 `WebApHelper.login()`，不是 `Helper.login()`，所以 `_sessionState.expireTime` 不會更新 |
| 4 | **`isExpire()` / `Authenticated.isExpired` 未被使用** | 過期偵測完全依賴 server 回傳 code 2，客戶端未主動檢查 |
| 5 | **Bus 缺少 CrawlerSelector 欄位** | `resolve<BusProvider>(null)` 硬編碼取第一個，無法透過 Remote Config 切換 |
| 6 | **`_getUserInfo()` catch-all 靜默吞掉錯誤** | `ApSessionExpiredException` 到達 UI 層後只記 Crashlytics，使用者無回饋 |
| 7 | **`LeaveHelper` 未實際使用 `withAutoRelogin`** | 已 `with ReloginMixin` 但 `getLeaves()`/`getLeavesSubmitInfo()` 仍用手動 `if (!isLogin)` 檢查 |

### 已解決

| # | 原問題 | 解決方式 |
|---|--------|----------|
| ✅ | static `reLoginReTryCounts` 共用計數器（#342） | `ReloginMixin` per-call 計數器 |
| ✅ | 並行 captcha 登入互相覆蓋 session | `_loginInProgress` Completer mutex |
| ✅ | Server race condition 不必要的 re-login | `_lastSuccessfulRelogin` 時間戳 + `recentLoginWindow` |
| ✅ | 各 helper 手寫 `dioInit()` | `ApiConfig.createScraperDio()` 統一初始化 |
| ✅ | 介面定義存在但未被實作 | 6 個 capability interface + `implements` |
| ✅ | `clearSetting()` 遺漏 LeaveHelper | 註冊式 cleanup callbacks |
| ✅ | CrawlerSelector 字串比對無型別安全 | `ScraperSource` enum + `fromString()` 反序列化 |
| ✅ | StdsysHelper/LeaveHelper 隱性耦合 WebApHelper | 構造函數注入 `_webApHelper` |
| ✅ | NKUSTHelper static retry 跨呼叫累積 | per-call loop retry |

---

## 關鍵檔案索引

| 檔案 | 用途 |
|------|------|
| `/lib/api/session_state.dart` | Sealed session state model |
| `/lib/api/relogin_mixin.dart` | Session re-login mixin + exception classes |
| `/lib/api/scraper_registry.dart` | ScraperSource enum + ScraperRegistry |
| `/lib/api/api_config.dart` | createScraperDio / RetryInterceptor / ErrorInterceptor |
| `/lib/api/capability/*.dart` | 6 個 capability interface |
| `/lib/api/helper.dart` | Facade — registry routing + cleanup |
| `/lib/api/ap_helper.dart` | WebAP 爬蟲 — captcha login + login mutex |
| `/lib/api/bus_helper.dart` | 校車 API — encrypted login |
| `/lib/api/leave_helper.dart` | 請假系統 — WebView login |
| `/lib/api/stdsys_helper.dart` | 學務系統 — SSO via WebApHelper |
| `/lib/api/mobile_nkust_helper.dart` | Mobile 爬蟲 — WebView login |
| `/lib/api/nkust_helper.dart` | 公告系統 — no login |
| `/lib/models/crawler_selector.dart` | Runtime provider 選擇 (enum-based) |
