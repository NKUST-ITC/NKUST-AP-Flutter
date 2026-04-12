# Scraper State Design Refactoring Plan

## Context

NKUST-AP-Flutter 的爬蟲層由 7 個 Helper 類別組成，各自管理不同大學系統的 HTTP session。目前的狀態設計存在多項架構問題：登入狀態分散在多處、重試邏輯不一致、Dio 初始化重複（未善用已有的 `ApiConfig`）、介面定義存在但未被實作、`clearSetting()` 手動逐一重設容易遺漏、CrawlerSelector 基於字串切換缺乏型別安全且擴充性差。本次重構的目標是**統一爬蟲的狀態模型**，並建立更靈活的 runtime 切換架構。

### 關聯 Issue: [#342 — 登入成功但實際沒有資料](https://github.com/NKUST-ITC/NKUST-AP-Flutter/issues/342)

Issue #342 是本次重構要直接解決的 bug。其根因鏈：

1. `_login()` 呼叫 `Helper.instance.login()` 成功 → Toast 顯示「登入成功」
2. `_getUserInfo()` 以 fire-and-forget 方式呼叫（無 await），內部走 `StdsysHelper.getUserInfo()` → `loginToStdsys()` → `apQuery('ag304_01')`
3. Server 因 race condition 回傳 code 2（session 過期），觸發 `apQuery` 的 re-login 迴圈
4. **致命缺陷**: `reLoginReTryCounts` 是 `WebApHelper` 上的 **static** 欄位（`ap_helper.dart:28`），所有操作共用同一個計數器。一旦 `apQuery('ag304_01')` 耗盡 3 次重試，後續 ALL 呼叫（課表、校車、成績等）都會立即因 `reLoginReTryCounts > 3` 而失敗
5. 所有錯誤被 `_getUserInfo()` 的 catch-all 靜默吞掉，UI 無任何反饋

本次重構的 Step 3（ReloginMixin）和 Step 1（Session State）直接解決此問題。

---

## Current Architecture Analysis

### Helper 依賴關係圖

```
Helper (Facade/Router) ── CrawlerSelector (string-based switch)
├── WebApHelper (Hub - CAPTCHA login, owns Dio+Cookies)
│   ├── StdsysHelper (delegates Dio+CookieJar to WebApHelper)
│   ├── LeaveHelper (uses WebApHelper's CookieJar)
│   └── MobileNkustHelper (adds WebApHelper's CookieJar as interceptor)
├── BusHelper (independent Dio+Cookies, encrypted login)
└── NKUSTHelper (independent, no login needed)
```

### CrawlerSelector 現況（Runtime Config 來自 Firebase Remote Config）

- `main.dart:54` — 啟動時從 SharedPreferences 載入
- `home_page.dart:954-957` — 從 Firebase Remote Config 動態更新並存入 Preferences
- `home_page.dart:1013` — Remote Config 失敗時 fallback 到本地儲存值
- 欄位皆為 `String`：`login`/`userInfo`/`course`/`score`/`semester`
- 值為 `"webap"`/`"mobile"`/`"stdsys"`/`"config"` 等字串常數

### ApiConfig 已提供的基礎設施 (`/lib/api/api_config.dart`)

| 已有能力 | 說明 | 目前被使用狀況 |
|----------|------|---------------|
| `ApiConfig.createDio()` | 工廠方法：timeout、headers、NativeAdapter、RetryInterceptor、ErrorInterceptor | **僅 MobileNkustHelper 間接使用了部分設定**，其他 4 個 helper 各自手寫 `dioInit()` |
| `RetryInterceptor` | HTTP 層級自動重試（timeout/5xx，指數退避，上限 3 次） | 僅掛在 `createDio()` 上，現有 helper 未使用 |
| `ErrorInterceptor` | 增強中文錯誤訊息 | 同上，未被現有 helper 使用 |
| `ApiConfig.setProxy()` | 統一 proxy 設定 | 未被使用，每個 helper 各自實作 `setProxy()` |
| `DioExtensions.safeGet/safePost` | 安全封裝 | 未被使用 |

### 核心問題

| # | 問題 | 現況 | 影響 |
|---|------|------|------|
| 1 | **登入狀態散落** | `Helper.username/password/expireTime` (static)、`WebApHelper.isLogin` (bool)、`BusHelper.isLogin` (bool)、`LeaveHelper.isLogin` (bool?)、`MobileNkustHelper.cookiesData` | 無法可靠判斷「目前是否已登入」 |
| 2 | **ApiConfig 未被善用** | 4 個 helper 各自手寫 `dioInit()`，重複 timeout/UA/NativeAdapter/PrivateCookieManager 設定 | `RetryInterceptor`/`ErrorInterceptor` 等已有能力被浪費 |
| 3 | **介面未被實作** | `WebApInterface`/`BusInterface`/`LeaveInterface` 存在但無人 implements | 無法做策略替換或測試 |
| 4 | **重試邏輯混淆** | HTTP retry（ApiConfig 已有）vs Session re-login（各 helper 手寫），兩層混在一起 | 行為不可預測 |
| 5 | **CrawlerSelector 擴充性差** | 字串比對 + Helper 中 6 個 switch 手動路由，新增爬蟲需改所有 switch | 無型別安全、無 fallback、難擴充 |
| 6 | **clearSetting() 脆弱** | 手動逐一 reset 每個 helper，且遺漏了 LeaveHelper | 登出不完整（bug） |
| 7 | **隱性耦合** | StdsysHelper/LeaveHelper 直接存取 `WebApHelper.instance.dio` | 難以理解和測試 |

### 關鍵檔案

- `/lib/api/helper.dart` — 主 Facade，路由+全域靜態狀態（534 行）
- `/lib/api/ap_helper.dart` — WebAP 爬蟲，session hub（624 行）
- `/lib/api/mobile_nkust_helper.dart` — Mobile 爬蟲，WebView login（505 行）
- `/lib/api/stdsys_helper.dart` — 學務系統，委託 WebApHelper（306 行）
- `/lib/api/bus_helper.dart` — 校車系統，獨立加密 login（380 行）
- `/lib/api/leave_helper.dart` — 請假系統，WebView login（426 行）
- `/lib/api/nkust_helper.dart` — 公告系統，無需登入（207 行）
- `/lib/api/api_config.dart` — **已有** createDio/RetryInterceptor/ErrorInterceptor（220 行）
- `/lib/api/interface/*.dart` — 未使用的介面定義
- `/lib/models/crawler_selector.dart` — string-based 執行期策略選擇（70 行）
- `/lib/pages/home_page.dart:949-1017` — Remote Config 更新 selector 的邏輯
- `/lib/app.dart` — `MyAppState.logout()` 呼叫 `Helper.clearSetting()`

---

## Refactoring Plan (7 Steps, Incremental)

### Step 1: 定義 Sealed Session State Model

**新增檔案**: `/lib/api/session_state.dart`

用 Dart 3 sealed class 明確建模爬蟲 session 的所有狀態：

```dart
sealed class ScraperSessionState {
  const ScraperSessionState();
}

class Unauthenticated extends ScraperSessionState {
  const Unauthenticated();
}

class Authenticated extends ScraperSessionState {
  final String username;
  final DateTime expireTime;
  const Authenticated({required this.username, required this.expireTime});
  bool get isExpired => DateTime.now().isAfter(
    expireTime.add(const Duration(hours: 8)),
  );
}

class AuthenticationFailed extends ScraperSessionState {
  final int statusCode;
  final String message;
  const AuthenticationFailed({required this.statusCode, required this.message});
}
```

**目的**: 取代 `Helper.username/password/expireTime` 三個 static fields + `isLogin` bool，讓狀態轉換可窮舉、可 pattern match。

**異動檔案**: 
- 新增 `/lib/api/session_state.dart`
- 修改 `/lib/api/helper.dart` — 新增 `ScraperSessionState _sessionState` 欄位，提供 getter

---

### Step 2: 統一 Dio 初始化，善用 ApiConfig

**核心思路**: 不另建 mixin，而是**擴充已有的 `ApiConfig.createDio()`** 使其支援 CookieJar，讓所有 helper 直接使用。

**修改 `/lib/api/api_config.dart`**:

```dart
class ApiConfig {
  // ... 既有的 timeout/retry 常數 ...

  /// 為爬蟲 helper 建立 Dio，已包含：
  /// - PrivateCookieManager（處理非 RFC6265 cookie）
  /// - RetryInterceptor（HTTP 層 timeout/5xx 自動重試）
  /// - ErrorInterceptor（中文錯誤訊息）
  /// - NativeAdapter（iOS/Android/macOS）
  static Dio createScraperDio({
    CookieJar? cookieJar,
    Map<String, dynamic>? headers,
    bool keepAlive = false,  // WebAp 需要 Connection: close
  }) {
    final jar = cookieJar ?? CookieJar();
    final dio = createDio(
      headers: {
        if (!keepAlive) 'Connection': 'close',
        ...?headers,
      },
    );
    dio.interceptors.insert(0, PrivateCookieManager(jar));
    return dio;
  }
}
```

**異動各 helper**:
- `/lib/api/ap_helper.dart` — `dioInit()` 改呼叫 `ApiConfig.createScraperDio()`
- `/lib/api/bus_helper.dart` — 同上
- `/lib/api/nkust_helper.dart` — 同上
- `/lib/api/leave_helper.dart` — 同上，傳入 `cookieJar: WebApHelper.instance.cookieJar`
- `/lib/api/mobile_nkust_helper.dart` — 因有隨機 UA、雙 CookieManager 等特殊需求，保留自訂初始化但可從 `ApiConfig` 取 timeout 常數

**效果**: 
- 所有 helper 自動獲得 `RetryInterceptor`（HTTP timeout/5xx 重試）和 `ErrorInterceptor`（中文錯誤）
- 各 helper 的 `setProxy()` 改呼叫 `ApiConfig.setProxy(dio, proxyIP)`，刪除重複實作
- 統一 timeout、User-Agent、NativeAdapter 設定

---

### Step 3: 分離 HTTP Retry vs Session Re-login（直接修復 #342）

**關鍵區分**:
- **HTTP Retry**（已有）: `RetryInterceptor` 處理 timeout/5xx，透明重試，helper 不需知道
- **Session Re-login**（需新增）: 偵測 session 過期（如 WebAP 回傳 code=2、Bus 回傳 "未登入"），自動重新登入後重試

**#342 根因分析 → 設計決策**:

現行 `WebApHelper.reLoginReTryCounts` 的三個致命問題：
1. **static 共用計數器** — 一個操作耗盡重試次數，所有操作都被連坐封鎖
2. **無重試延遲** — Server race condition（session 尚未初始化就收到 query）需要 delay
3. **重試上限後無法恢復** — 計數器只在成功時歸零，若連續失敗後 server 恢復，app 仍然被鎖

`ReloginMixin` 設計以此為出發點：
- 計數器為 **instance field**，每個 helper instance 獨立（非 static）
- 提供 **per-call 重試**：`withAutoRelogin` 每次呼叫獨立計數，不影響其他操作
- 支援**延遲重試**：re-login 後加入短暫 delay，避免 server race condition
- 成功時自動歸零

**新增檔案**: `/lib/api/relogin_mixin.dart`

```dart
/// 處理 session 過期的自動重新登入邏輯。
/// HTTP 層 retry 已由 RetryInterceptor 處理，此 mixin 僅處理 session 層。
///
/// 與原有 static reLoginReTryCounts 的差異（修復 #342）：
/// - 計數器 per-call 而非 per-class static，一個操作失敗不影響其他操作
/// - 支援延遲重試，避免 server session race condition
mixin ReloginMixin {
  int get maxRelogins;  // 各 helper 自行定義（WebAp: 3, Bus: 5）

  /// 帶自動重新登入的操作執行器。
  /// [retryDelay] 預設 500ms，給 server 時間完成 session 初始化（#342 race condition）
  Future<T> withAutoRelogin<T>({
    required Future<T> Function() action,
    required Future<void> Function() relogin,
    required bool Function(dynamic error) isSessionExpired,
    Duration retryDelay = const Duration(milliseconds: 500),
  }) async {
    int attempts = 0;
    while (true) {
      try {
        return await action();
      } catch (e) {
        if (isSessionExpired(e) && attempts < maxRelogins) {
          attempts++;
          await relogin();
          await Future<void>.delayed(retryDelay);  // 避免 race condition
          continue;
        }
        rethrow;
      }
    }
  }
}
```

**與現行程式碼的對應**:

```dart
// 現行 apQuery()（ap_helper.dart:404-447）:
// if (code == 2) {
//   reLoginReTryCounts += 1;  // ← static! 所有操作共用
//   await login(...);          // ← 無延遲
//   return apQuery(...);       // ← 遞迴
// }
// reLoginReTryCounts = 0;     // ← 只有成功才歸零

// 重構後:
Future<Response> apQuery(String qid, Map<String, String?>? data) {
  return withAutoRelogin(
    action: () => _doApQuery(qid, data),
    relogin: () => login(username: Helper.username!, password: Helper.password!),
    isSessionExpired: (e) {
      // 將 code==2 的檢查從 response parsing 移到這裡
      return e is _ApSessionExpiredException;
    },
  );
}
```

**異動檔案**:
- 新增 `/lib/api/relogin_mixin.dart`
- 修改 `/lib/api/ap_helper.dart` — `with ReloginMixin`，`apQuery()` 改用 `withAutoRelogin()`，**移除 static reLoginReTryCounts**
- 修改 `/lib/api/bus_helper.dart` — `with ReloginMixin`，移除每個方法中手寫的 retry 邏輯
- 修改 `/lib/api/leave_helper.dart` — `with ReloginMixin`
- 修改 `/lib/api/nkust_helper.dart` — `with ReloginMixin`

---

### Step 4: Capability Interface + ScraperRegistry（靈活 Runtime 切換）

**這是架構改動最大的一步**。取代目前 string-based CrawlerSelector + Helper 中 6 個 switch 的做法。

#### 4a. 定義 Capability Interface（按功能，非按系統）

**新增 `/lib/api/capability/`** 目錄，取代現有的 `/lib/api/interface/`：

```dart
// /lib/api/capability/course_provider.dart
abstract class CourseProvider {
  Future<CourseData> getCourseTable({String? year, String? semester});
}

// /lib/api/capability/score_provider.dart
abstract class ScoreProvider {
  Future<ScoreData?> getScores({required String year, required String semester});
}

// /lib/api/capability/user_info_provider.dart
abstract class UserInfoProvider {
  Future<UserInfo> getUserInfo();
  Future<Uint8List?> getUserPicture(String? pictureUrl);
}

// /lib/api/capability/semester_provider.dart
abstract class SemesterProvider {
  Future<SemesterData?> getSemesters();
}

// /lib/api/capability/bus_provider.dart
abstract class BusProvider {
  Future<BusData> getTimeTable({required DateTime dateTime});
  Future<BookingBusData> bookBus({required String busId});
  Future<CancelBusData> cancelBus({required String busId});
  Future<BusReservationsData> getReservations();
  Future<BusViolationRecordsData> getViolationRecords();
}

// /lib/api/capability/leave_provider.dart
abstract class LeaveProvider {
  Future<LeaveData> getLeaves({required String year, required String semester});
  Future<LeaveSubmitInfoData> getSubmitInfo();
  Future<Response<dynamic>?> submit(LeaveSubmitData data, {XFile? proofImage});
}
```

**各 Helper 實作對應的 capability**：

```dart
// WebApHelper 提供：course, score, userInfo, semester
class WebApHelper with ReloginMixin
    implements CourseProvider, ScoreProvider, UserInfoProvider, SemesterProvider { ... }

// StdsysHelper 提供：course, score, userInfo, semester
class StdsysHelper
    implements CourseProvider, ScoreProvider, UserInfoProvider, SemesterProvider { ... }

// MobileNkustHelper 提供：course, score, userInfo, bus
class MobileNkustHelper
    implements CourseProvider, ScoreProvider, UserInfoProvider, BusProvider { ... }

// BusHelper 提供：bus
class BusHelper with ReloginMixin implements BusProvider { ... }

// LeaveHelper 提供：leave
class LeaveHelper with ReloginMixin implements LeaveProvider { ... }
```

#### 4b. ScraperRegistry — 按 Capability 註冊和解析

**新增 `/lib/api/scraper_registry.dart`**:

```dart
enum ScraperSource {
  webap, stdsys, mobile, remoteConfig;

  // 支援從 JSON string 反序列化（相容 Remote Config）
  static ScraperSource fromString(String value) =>
      ScraperSource.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ScraperSource.webap,  // fallback default
      );
}

class ScraperRegistry {
  final Map<Type, Map<ScraperSource, Object>> _providers = {};

  /// 註冊一個 provider，聲明它的來源和它實作的 capability
  void register<T>(ScraperSource source, T provider) {
    _providers.putIfAbsent(T, () => {})[source] = provider as Object;
  }

  /// 根據偏好來源解析 provider；找不到時拋異常
  T resolve<T>(ScraperSource? preferred) {
    final map = _providers[T];
    if (map == null || map.isEmpty) {
      throw StateError('No provider registered for $T');
    }
    if (preferred != null && map.containsKey(preferred)) {
      return map[preferred]! as T;
    }
    return map.values.first as T;  // fallback to first registered
  }

  /// 查詢某 capability 有哪些可用來源（用於 UI 設定頁）
  List<ScraperSource> availableSources<T>() {
    return _providers[T]?.keys.toList() ?? [];
  }
}
```

#### 4c. CrawlerSelector 改為 enum-based + 相容 Remote Config

**修改 `/lib/models/crawler_selector.dart`**:

```dart
@JsonSerializable()
class CrawlerSelector {
  @JsonKey(fromJson: ScraperSource.fromString, toJson: _sourceToString)
  final ScraperSource login;
  @JsonKey(name: 'user_info', fromJson: ScraperSource.fromString, toJson: _sourceToString)
  final ScraperSource userInfo;
  @JsonKey(fromJson: ScraperSource.fromString, toJson: _sourceToString)
  final ScraperSource course;
  @JsonKey(fromJson: ScraperSource.fromString, toJson: _sourceToString)
  final ScraperSource score;
  @JsonKey(fromJson: ScraperSource.fromString, toJson: _sourceToString)
  final ScraperSource semester;

  static String _sourceToString(ScraperSource s) => s.name;
  // ... copyWith, fromJson, save, load 同原有邏輯
}
```

用 `ScraperSource.fromString()` 做反序列化，**完全相容**現有 Remote Config 下發的 JSON（`"webap"`, `"mobile"` 等），不需改後端。

#### 4d. Helper 改用 Registry 解析，消除 switch

**修改 `/lib/api/helper.dart`**:

```dart
class Helper {
  final ScraperRegistry registry = ScraperRegistry();

  Helper() {
    // 初始化時註冊所有 provider
    _registerProviders();
  }

  void _registerProviders() {
    // WebApHelper
    registry.register<CourseProvider>(ScraperSource.webap, WebApHelper.instance);
    registry.register<ScoreProvider>(ScraperSource.webap, WebApHelper.instance);
    registry.register<UserInfoProvider>(ScraperSource.webap, WebApHelper.instance);
    registry.register<SemesterProvider>(ScraperSource.webap, WebApHelper.instance);

    // StdsysHelper
    registry.register<CourseProvider>(ScraperSource.stdsys, StdsysHelper.instance);
    registry.register<ScoreProvider>(ScraperSource.stdsys, StdsysHelper.instance);
    registry.register<UserInfoProvider>(ScraperSource.stdsys, StdsysHelper.instance);
    registry.register<SemesterProvider>(ScraperSource.stdsys, StdsysHelper.instance);

    // MobileNkustHelper
    registry.register<CourseProvider>(ScraperSource.mobile, MobileNkustHelper.instance);
    registry.register<ScoreProvider>(ScraperSource.mobile, MobileNkustHelper.instance);
    registry.register<UserInfoProvider>(ScraperSource.mobile, MobileNkustHelper.instance);
    registry.register<BusProvider>(ScraperSource.mobile, MobileNkustHelper.instance);

    // LeaveHelper
    registry.register<LeaveProvider>(ScraperSource.webap, LeaveHelper.instance);
  }

  // 取代原有的 6 個 switch 方法
  Future<CourseData> getCourseTables({required Semester semester, Semester? semesterDefault}) async {
    final provider = registry.resolve<CourseProvider>(selector?.course);
    return provider.getCourseTable(year: semester.year, semester: semester.value);
  }

  Future<ScoreData?> getScores({required Semester semester}) async {
    final provider = registry.resolve<ScoreProvider>(selector?.score);
    return provider.getScores(year: semester.year, semester: semester.value);
  }

  Future<UserInfo> getUsersInfo() async {
    final provider = registry.resolve<UserInfoProvider>(selector?.userInfo);
    return provider.getUserInfo();
  }

  Future<SemesterData> getSemester() async {
    final provider = registry.resolve<SemesterProvider>(selector?.semester);
    final data = await provider.getSemesters();
    if (data == null) throw GeneralResponse.unknownError();
    return data;
  }
  // ... 其餘方法同理
}
```

**效果**:
- 新增爬蟲來源只需：1) 寫新 helper 實作 capability interface 2) 在 `_registerProviders()` 註冊 → **不需改任何 switch**
- `registry.availableSources<CourseProvider>()` 可用於 UI 設定頁，動態顯示可選來源
- Runtime 切換只需修改 `CrawlerSelector`，registry 自動解析
- Fallback 邏輯集中在 `registry.resolve()` 中

**異動檔案**:
- 新增 `/lib/api/capability/` 目錄（6 個 capability interface 檔案）
- 新增 `/lib/api/scraper_registry.dart`
- 修改 `/lib/models/crawler_selector.dart` — String → ScraperSource enum
- 修改 `/lib/api/helper.dart` — 移除所有 switch，改用 registry
- 修改各 helper — 加上 `implements XxxProvider`
- 刪除 `/lib/api/interface/` 目錄（被 capability 取代）
- 修改 `/lib/pages/home_page.dart:954-957` — CrawlerSelector 反序列化方式不變（fromRawJson 內部自動 enum 轉換）

---

### Step 5: 集中 Session State + 註冊式 Cleanup

**修改 `/lib/api/helper.dart`**:

```dart
class Helper {
  ScraperSessionState _sessionState = const Unauthenticated();
  ScraperSessionState get sessionState => _sessionState;

  String? get username => switch (_sessionState) {
    Authenticated(:final username) => username,
    _ => null,
  };

  // 註冊式 cleanup，不再手動列舉
  final List<VoidCallback> _cleanupCallbacks = [];

  void registerCleanup(VoidCallback callback) {
    _cleanupCallbacks.add(callback);
  }

  void clearSetting() {
    _sessionState = const Unauthenticated();
    for (final callback in _cleanupCallbacks) {
      callback();
    }
    ApCommonPlugin.clearCourseWidget();
    ApCommonPlugin.clearUserInfoWidget();
  }
}
```

各 sub-helper 在初始化時自行註冊 cleanup，**包含目前遺漏的 LeaveHelper**：

```dart
// WebApHelper
Helper.instance.registerCleanup(() {
  logout();
  resetReloginCount();
  dioInit();
  isLogin = false;
});

// LeaveHelper（修復現有 bug — 目前未被 clearSetting 重設）
Helper.instance.registerCleanup(() {
  isLogin = null;
  resetReloginCount();
  dioInit();
});
```

**注意**: `password` 不存在 session state 中（安全考量），需要 re-login 時從 `PreferenceUtil` 的加密儲存讀取。

---

### Step 6: 顯式化 StdsysHelper/LeaveHelper 的依賴

**修改 `/lib/api/stdsys_helper.dart`**:
```dart
class StdsysHelper implements CourseProvider, ScoreProvider, UserInfoProvider, SemesterProvider {
  final WebApHelper _webApHelper;
  StdsysHelper(this._webApHelper);

  Dio get dio => _webApHelper.dio;
  CookieJar get cookieJar => _webApHelper.cookieJar;

  static StdsysHelper? _instance;
  static StdsysHelper get instance =>
      _instance ??= StdsysHelper(WebApHelper.instance);
}
```

**修改 `/lib/api/leave_helper.dart`**: 同理，構造函數接受 WebApHelper 注入。

**目的**: 依賴關係顯式化，方便測試時注入 mock WebApHelper。

---

### Step 7: 進階 — Fallback Chain（可選）

在 `ScraperRegistry.resolve()` 中支援 fallback 順序：

```dart
T resolve<T>(ScraperSource? preferred, {List<ScraperSource>? fallbacks}) {
  final map = _providers[T];
  if (map == null || map.isEmpty) throw StateError('No provider for $T');

  // 嘗試偏好來源
  if (preferred != null && map.containsKey(preferred)) {
    return map[preferred]! as T;
  }

  // 嘗試 fallback 順序
  if (fallbacks != null) {
    for (final source in fallbacks) {
      if (map.containsKey(source)) return map[source]! as T;
    }
  }

  // 最後 fallback
  return map.values.first as T;
}
```

**使用場景**: 當 stdsys 系統維護時自動 fallback 到 webap：
```dart
final provider = registry.resolve<ScoreProvider>(
  selector?.score,
  fallbacks: [ScraperSource.webap, ScraperSource.stdsys],
);
```

---

## Implementation Order

| 順序 | Step | 風險 | 說明 |
|------|------|------|------|
| 1 | Step 1 (Session State) | 低 | 純新增 sealed class，不破壞現有程式碼 |
| 2 | Step 2 (ApiConfig 統一 Dio) | 中 | 逐一替換各 helper 的 `dioInit()`，改用 `createScraperDio()` |
| 3 | Step 3 (ReloginMixin) | 中 | 清楚區分 HTTP retry vs session re-login |
| 4 | Step 4 (Capability + Registry) | **高** | 架構核心改動，需同時改 interface + helper + Helper 路由 |
| 5 | Step 5 (集中 Session + Cleanup) | 中 | 修改 Helper 靜態欄位，移除散落狀態 |
| 6 | Step 6 (顯式依賴注入) | 低 | StdsysHelper/LeaveHelper 構造函數改動 |
| 7 | Step 7 (Fallback Chain) | 低 | 可選，增強 registry 的 resolve 邏輯 |

每一步完成後都應能獨立 `flutter analyze` 通過並保持功能正常。

## Verification

1. **編譯**: 每步完成後 `flutter analyze` 確認無錯誤
2. **功能測試**: 
   - 登入 → 確認 session state 為 `Authenticated`
   - 登出 → 確認所有 helper 狀態重設（包含 LeaveHelper）、session state 為 `Unauthenticated`
   - Session 過期 → 確認 ReloginMixin 自動 re-login 正常
   - 各系統功能（課表、成績、校車、請假）正常存取
3. **#342 迴歸測試（重點）**:
   - 模擬 server 對 `ag304_01` 回傳 code 2（session 過期）→ 確認 re-login 有 500ms delay
   - 確認單一操作失敗後，**其他操作仍可正常執行**（per-call 計數器，非 static 共用）
   - 確認 re-login 成功後，後續 query 正常取得資料
   - 確認重試上限耗盡時，拋出的 `GeneralResponse` 能被 UI 層正確處理（不被靜默吞掉）
4. **Runtime 切換測試**:
   - 透過 Remote Config 下發不同 selector → 確認即時切換爬蟲來源
   - `registry.availableSources<CourseProvider>()` 回傳正確的可用來源
   - Fallback: 指定不存在的 source → 確認 fallback 到預設
5. **相容性**:
   - Remote Config JSON 格式不變（`"webap"` 等字串），`ScraperSource.fromString()` 自動轉換
   - UI 層（pages/）不需修改（Helper 的 public API 簽名不變）
6. **邊界條件**:
   - Re-login 超過上限 → 拋出 `GeneralResponse` with `networkConnectFail`
   - 未註冊的 capability + source 組合 → `StateError` 提示開發者
