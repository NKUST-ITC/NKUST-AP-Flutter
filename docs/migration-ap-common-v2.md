# nkust_ap 遷移至 ap_common v2 評估紀錄

> 日期：2026-04-01 ~ 2026-04-02
> 分支：develop (v3.13.0)
> ap_common：monorepo v1.0.1-dev.x

---

## 1. 現況盤點

### nkust_ap develop (v3.13.0)

- Dart SDK: `>=3.1.0 <4.0.0`（null safe）
- ap_common: `^1.0.1-dev.0`（新版 monorepo）
- 已完成：`registerOneForAll()` 初始化、barrel import、Dio 5.x、Firebase 現代化、Material 3 ApTheme
- 編譯狀態：0 error, 0 warning, 112 info
- 仍使用 `GeneralCallback`：48 處, 22 個檔案
- 仍使用 `ApLocalizations.of(context)`：33 處, 21 個檔案

### ap_common monorepo 架構

```
ap_common_core (Pure Dart)
    |
ap_common_flutter_core (Flutter 抽象層 + Slang i18n)
    |-- ap_common_flutter_platform (平台實作)
    |-- ap_common_flutter_ui (Material 3 UI 元件)
    |   |-- ap_common_announcement_ui (公告功能)
    |-- ap_common_firebase (Firebase 整合)
    |-- ap_common_plugin (原生外掛)
    |
ap_common (barrel package, re-export all)
```

### develop vs master 關係

master (07427d7, v3.11.8) 已完全包含在 develop 中。develop 是 master 的超集，多了 30+ commits：

- stdsys 爬蟲（StdsysHelper + StdsysParser）
- ap_common v2 遷移（commit eeaabd0）
- Android 16KB alignment / store permission fix
- CI/CD git flow 更新
- feature/gen-4-ui UI 更新

master 上沒有 develop 缺少的 commit，不存在平行衝突問題。

---

## 2. ap_common Issues & PRs 狀態（v1.0.0 起）

### 已完成的重大變更

| PR | Issue | 合併日期 | 說明 | 對 nkust_ap 影響 |
|---|---|---|---|---|
| #145 | #144 | 3/18 | AP Common UI v2 — Material 3 全面遷移 | develop 已透過 eeaabd0 適配 |
| #147 | #146 | 3/28 | intl → Slang i18n 遷移 | nkust_ap 尚未適配 |
| #148 | #134 | 3/30 | Announcement API 改用 Swagger 生成 + ApiResult | 需確認公告功能 |
| #155 | #149 | 3/31 | 完全移除 GeneralCallback | nkust_ap 48 處引用將 break |
| #156 | #150 | 3/31 | 擴增測試覆蓋率 | 無直接影響 |
| #157 | #151 | 3/31 | 清理 intl → slang 殘留 | 與 i18n 遷移連動 |

### 仍開啟的 Issues

| # | 標題 | 說明 |
|---|---|---|
| #144 | 第二代介面 | UI v2 主 issue，PR #145 已 merge 但 issue 未關 |
| #152 | 清理 TODO 與技術債 | 4 個 TODO 待處理 |
| #153 | 各套件個別改善 | callback typedef 現代化、大檔案拆分、Firebase 文件 |
| #154 | 新增 GitHub Issue/PR 範本 | 標準化範本 |
| #159 | 透過 Sealed Class 簡化 UI 整合 | DataState + 便利 Widget（見下方詳細分析）|

### 正在開發的分支

| 分支 | PR | 說明 |
|---|---|---|
| `feat/6-course-app-widget` | #158 | 上課提醒小工具 — Android & iOS |

---

## 3. 架構分層分析

```
Pages (UI 層)
  | GeneralCallback<T>       <-- 只在這層
  v
helper.dart (調度層)
  | Future<T> (plain async)  <-- 邊界：爬蟲層不用 GeneralCallback
  v
WebApHelper / StdsysHelper / BusHelper / LeaveHelper / MobileNkustHelper (爬蟲層)
  |
  v
Parser (HTML parsing)
```

關鍵發現：**爬蟲層完全不使用 GeneralCallback**，它們回傳 plain `Future<T>`。GeneralCallback 只存在於 `helper.dart`（調度層）和 Pages（UI 層）。因此 GeneralCallback 遷移與爬蟲開發可完全平行。

---

## 4. ApiResult vs DataState 分析

### 定義

```dart
// ApiResult — API 呼叫的結果（網路層）
sealed class ApiResult<T> {
  ApiSuccess(T data)
  ApiError(GeneralResponse)    // 伺服器錯誤（有 statusCode）
  ApiFailure(DioException)     // 網路/客戶端異常
}

// DataState — UI 該呈現什麼（表現層）
sealed class DataState<T> {
  DataLoading()
  DataLoaded(T data)
  DataError(...)
  DataEmpty()
}
```

### 結論：不建議合併

| 面向 | ApiResult | DataState |
|---|---|---|
| 關注層 | 網路/API | UI 表現 |
| Loading 狀態 | 不存在 | 需要 |
| Empty 狀態 | 不存在 | 需要 |
| 錯誤粒度 | 區分 Server/Network | 扁平化 message |
| 使用場景 | API 邊界 | Widget 狀態管理 |

正確的關係是映射，不是合併。便利 Widget 內部處理 `Future<T>` → `DataState<T>` 的轉換。

---

## 5. Issue #159 影響分析

### 新增的便利 Widget

| Widget | 取代 | nkust_ap 對應 | 簡化幅度 |
|---|---|---|---|
| `DataState<T>` | 手動 State enum | 所有頁面 | — |
| `ApApp` | MaterialApp + ApTheme + i18n | app.dart (173行) | 大 |
| `ApLoginPage` | LoginScaffold + 偏好設定 | login_page.dart (252行) | 大 |
| `ApCoursePage` | CourseScaffold + 學期+狀態 | course_page.dart (190行→~40行) | 極大 |
| `ApScorePage` | ScoreScaffold + 學期+狀態 | score_page.dart (175行→~40行) | 極大 |

### 便利 Widget 的 API 假設

```dart
ApCoursePage(
  onLoadSemesters: () => Future<SemesterData>,   // 直接回傳，throw on error
  onLoadCourse: (semester) => Future<CourseData>, // 直接回傳，throw on error
)
```

便利 Widget 內部自動處理 `Future<T>` → `DataState<T>` 轉換，nkust_ap 不需要直接使用 ApiResult。

### nkust_ap 特殊邏輯

| 頁面 | 特有邏輯 | 能否直接用便利 Widget |
|---|---|---|
| login_page | 搜尋學號、自訂錯誤碼、5次密碼錯誤 | 部分可用，需 hook |
| course_page | 多爬蟲源 switch、課程通知、離線 cache | onLoadCourse 可封裝 |
| score_page | 離線成績載入 | 較單純，適合直接用 |
| app.dart | ShareDataWidget、自訂路由、Firebase init | ApApp 可簡化主題/i18n |

---

## 6. 遷移策略

### 路線選擇：#159 優先

helper.dart → `Future<T>`（拆除 GeneralCallback 包裝），不引入 ApiResult 中間層。便利 Widget 內部處理 DataState 轉換。

### 優勢

| | ApiResult 路線 | #159 優先路線 |
|---|---|---|
| helper.dart 改法 | GeneralCallback → ApiResult | GeneralCallback → Future\<T\>（更簡單）|
| Pages 改法 | switch ApiResult | 直接用便利 Widget（更少程式碼）|
| 中間型別 | ApiResult（新概念）| 無（直接穿透 Future）|
| 便利 Widget 頁面 | 套用時還需再改一次 | 一步到位 |

### 依賴與平行關係

```
         可平行 ──────────────────────────────
        |                                     |
   +----------+  +----------+          +--------------+
   | 票1      |  | 票2      |          | 爬蟲開發     |
   | Future<T>|  | Slang    |          | (持續平行)   |
   +----+-----+  +----+-----+          +--------------+
        |              |
        +------+  +----+
        |      |  |
   +----+--+ +-+--+--+
   | 票3             |
   | 頁面遷移至      |
   | ap_common v2    |
   +--------+--------+
            |
   +--------+--------+
   |     票4 清理     |
   +-----------------+
```

---

## 7. 開票結果

| Issue | 票名 | 優先級 | 前置 |
|---|---|---|---|
| [#306](https://github.com/NKUST-ITC/NKUST-AP-Flutter/issues/306) | helper.dart 移除 GeneralCallback，回傳 `Future<T>` | P0 | — |
| [#307](https://github.com/NKUST-ITC/NKUST-AP-Flutter/issues/307) | Slang i18n 適配（`context.ap`）| P0 | — |
| [#308](https://github.com/NKUST-ITC/NKUST-AP-Flutter/issues/308) | 頁面遷移至 ap_common v2 API | P1 | #306, #307 |
| [#309](https://github.com/NKUST-ITC/NKUST-AP-Flutter/issues/309) | 技術清理 | P3 | — |

### 票 3 (#308) 可選項目

依需求與 ap_common#159 進度逐一評估：

**便利 Widget 套用（依賴 ap_common#159）：**
- [ ] app.dart → ApApp 遷移
- [ ] score_page.dart → ApScorePage（建議先做 pilot）
- [ ] course_page.dart → ApCoursePage
- [ ] login_page.dart → ApLoginPage

**非便利 Widget 頁面（不依賴 ap_common#159）：**
- [ ] Bus 模組（5 頁）
- [ ] Leave 模組（4 頁）
- [ ] Study 其他（midterm、reward、room 等）
- [ ] Info / 其他（home、setting、search 等）

---

## 8. 相關 ap_common Issues

| Issue | 標題 | 狀態 | 與 nkust_ap 關係 |
|---|---|---|---|
| abc873693/ap_common#134 | Announcement API Swagger 生成 | Closed | 需確認公告功能適配 |
| abc873693/ap_common#144 | 第二代介面 | Open | UI v2，develop 已部分適配 |
| abc873693/ap_common#149 | 移除 GeneralCallback | Closed | nkust_ap #306 |
| abc873693/ap_common#151 | intl → slang 遷移 | Closed | nkust_ap #307 |
| abc873693/ap_common#152 | 清理 TODO 與技術債 | Open | nkust_ap #309 |
| abc873693/ap_common#153 | 各套件個別改善 | Open | callback typedef 現代化可能影響 |
| abc873693/ap_common#158 | 上課提醒小工具 | Open (PR) | 未來整合 |
| abc873693/ap_common#159 | DataState + 便利 Widget | Open | nkust_ap #308 核心依賴 |
