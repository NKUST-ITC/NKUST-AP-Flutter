# AGENTS.md

給 AI coding agent（Claude Code、Cursor、Codex、Gemini Code Assist 等）使用的專案說明文件。人類貢獻者請優先閱讀 [`README.md`](./README.md)。

## 專案簡介

**高科校務通（NKUST AP）** 是高雄科技大學的校務系統 App，使用 Flutter 開發，支援 Android、iOS、macOS、Windows、Linux 五個平台（Web 因學校阻擋高請求 IP 已停用）。Repo 在 [`NKUST-ITC/NKUST-AP-Flutter`](https://github.com/NKUST-ITC/NKUST-AP-Flutter)。

由於學校沒有正式 API，整支 App 大量倚賴 **client-side web scraping**：對 `webap.nkust.edu.tw`、`stdsys.nkust.edu.tw`、`leave.nkust.edu.tw`、`vms.nkust.edu.tw` 等校內服務發 HTTP 請求並 parse HTML。這個爬蟲層是專案的核心複雜度來源。

## 技術棧

| 工具 | 版本 | 來源 |
|------|------|------|
| Flutter | `3.41.7` | `mise.toml` / `.fvmrc` |
| Dart SDK | `>=3.6.0 <4.0.0` | `pubspec.yaml` |
| Java | `zulu-21` | `mise.toml`（Android build） |
| Ruby | `3.3` | `mise.toml`（Fastlane） |

工具版本統一由 [mise](https://github.com/jdx/mise) 管理。Agent 在執行任何 build/test 命令前，請先確認當前 Flutter 版本符合 `mise.toml`，不要擅自升級 SDK。

主要相依：
- `ap_common` 系列：校務通跨校共用 UI / 函式庫
- `nkust_crawler`（in-repo package，路徑 `packages/nkust_crawler/`）：純 Dart 爬蟲套件
- `dio` + `cookie_jar` + `native_dio_adapter`：HTTP 與 cookie 管理
- `slang` / `slang_flutter`：i18n（設定見 `slang.yaml`）
- `flutter_inappwebview`：登入流程的 WebView fallback
- `syncfusion_flutter_pdf`：課表 / 證件 PDF 產生

## Repo 結構

```
nkust_ap/
├── lib/
│   ├── api/              # Scraper helpers、capability、registry、exceptions
│   ├── pages/            # UI 頁面（bus / info / leave / study 等）
│   ├── config/           # constants
│   ├── extensions/       # Dart extension methods
│   ├── integrations/     # Firebase、Google Sign-In 等外部整合
│   ├── l10n/             # slang i18n 來源檔（.i18n.json）與 generated/
│   ├── res/              # 顏色、樣式、theme
│   ├── utils/            # 工具函式
│   ├── widgets/          # 共用 widget
│   ├── app.dart          # MaterialApp
│   ├── main.dart         # entry point + flavor bootstrap
│   └── firebase_options.dart   # 由 flutterfire CLI 產生
│
├── packages/
│   └── nkust_crawler/    # 純 Dart 爬蟲套件（webap / stdsys / leave / vms-bus）
│
├── test/                 # 主 app 測試（hermetic）
├── assets/               # 圖片、CA、學程資料 JSON
├── assets_test/          # 測試用 HTML fixture
├── docs/                 # 架構 / 重構 / 遷移文件（見下方）
├── scripts/              # dev_configs encrypt/decrypt 腳本
├── .github/workflows/    # CI/CD
└── android/ ios/ macos/ linux/ windows/   # 各平台 native 殼
```

## 重要參考文件

修改特定模組前，先讀對應的 doc：

| 文件 | 內容 |
|------|------|
| `docs/crawler-architecture.md` | 爬蟲分層、ScraperRegistry、Capability 介面、Session 狀態機 |
| `docs/refactor-scraper-state-design.md` | Scraper 狀態設計決策記錄（ADR 風格） |
| `docs/cookie-handling.md` | Cookie / `SafeCookieManager` 行為 |
| `docs/changelog-pipeline.md` | PR → `changelog.json` → Fastlane 變更紀錄管線 |
| `docs/extracting-flutter-crawler-as-dart-package.md` | 將爬蟲抽離成獨立 Dart package 的流程（reusable guide） |
| `docs/migration-ap-common-v2.md` | ap_common v2 遷移筆記 |
| `docs/POLICY.md` | 隱私 / 資料處理政策 |

## 常用指令

### 環境設定

```bash
mise trust && mise install    # 安裝對應版本的 Flutter / Java / Ruby
flutter pub get               # 主 app
(cd packages/nkust_crawler && dart pub get)
```

### Lint / Test

```bash
# 主 app
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test

# 爬蟲 package（CI 是分開跑的，本地也請分開）
cd packages/nkust_crawler
dart analyze
dart test
```

**注意**：root 的 `analysis_options.yaml` 已將 `packages/**` 排除（見檔內註解）。Agent **不要**嘗試從 root 跑 `flutter analyze` 涵蓋 `packages/`，會因為 sub-package 自己的 dev_dependencies 沒被解析而炸掉。

### Live integration test（打真實 NKUST server）

`packages/nkust_crawler/test/` 內有以 `@Tags(['integration'])` 標記的 live test：

```bash
cd packages/nkust_crawler
NKUST_USERNAME=xxx NKUST_PASSWORD=xxx dart test --tags integration
# 可選：開 HTTP log
NKUST_HTTP_LOG=1 dart test --tags integration
```

沒有環境變數時這些 test 會 skip（見 `dart_test.yaml`）。Agent 不要把帳密寫進 commit 或 log。

### Code generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs    # json_serializable + slang
```

修改 `*.i18n.json` 或加 `@JsonSerializable` 的 model 後要跑一次。

### Run / Build

```bash
flutter run -d macos        # 或 chrome / windows / linux / <device-id>
flutter build apk --release
flutter build appbundle --release
flutter build ipa --release
flutter build macos --release
```

正式發版會帶 `--build-number=<VERSION_CODE>`，由 CI 控制，本地不用手動指定。

## 爬蟲層核心概念

> 摘要自 `docs/crawler-architecture.md`，動到 `lib/api/` 或 `packages/nkust_crawler/` 前必讀原始文件。

分層（上到下）：

```
UI (lib/pages/*)
  → Helper Facade (lib/api/helper.dart)
    → ScraperRegistry (lib/api/scraper_registry.dart)
      → Capability 介面（6 個 *_provider.dart）
        → 各 ScraperHelper（WebAp / Stdsys / Leave / VmsBus / NKUST）
          → 對應 Parser
```

- **Helper Facade** 是 UI 唯一入口，不要從 UI 直接 import 個別 scraper helper
- **Capability provider** 用來宣告「某個 helper 提供哪些功能」（成績、課表、請假…），Registry 會挑能滿足的 helper
- 多個學校系統可能都能查同一資料（例如成績），Registry 的選擇順序見原 doc
- **Session 狀態機**處理登入 → cookie 失效 → 重登的流程，不要繞過
- 例外階層在 `lib/api/exceptions/`，新增錯誤類型請延伸既有 base class

## 目標伺服器（爬蟲對象）

App 沒有自建後端，所有資料來自爬學校的五個網域。每個網域有自己的登入機制、cookie 範圍、HTML 結構，動到任何一個 helper 前先看清楚是哪一隻。

| 網域 | Helper | Dio | CookieJar | 登入方式 | 提供能力 |
|------|--------|-----|-----------|---------|---------|
| `webap.nkust.edu.tw` | `WebApHelper` | own | own（**shared**） | captcha + form POST → `perchk.jsp` | Course / Score / UserInfo / Semester |
| `stdsys.nkust.edu.tw` | `StdsysHelper` | 借 webap | 借 webap | webap SSO 起頭，`loginToStdsys()` single-flight | Course / Score / UserInfo / Semester、在校證明、教室借用、PDF 成績單 |
| `leave.nkust.edu.tw` | `LeaveHelper` | own | 借 webap | WebView 登入（`flutter_inappwebview`），手動 `setCookie` 注入 | Leave（請假紀錄 / 送出 / 證明上傳） |
| `vms.nkust.edu.tw` | `VmsBusHelper` | own | own（獨立） | 直接 form POST，**不走 SSO** | Bus（時刻表 / 預約 / 取消 / 違規紀錄） |
| `nkust.edu.tw` | `NKUSTHelper` | own | own | 不需登入 | 學校公告 |

### 各伺服器重點

**`webap.nkust.edu.tw`（主入口）**
- 校務系統 portal，課表 / 成績 / 個人資料的權威來源
- 登入要過 captcha：解法在 `packages/nkust_crawler/lib/src/captcha/`（`EuclideanCaptchaSolver` + bundled template `assets/eucdist/`）
- 走 `apQuery('ag222_01')` 之類的查詢端點，回的是 HTML，由 `WebApParser` 解析
- `WebApHelper` 是其他 helper 的 cookie 起點：stdsys / leave 都借它的 `cookieJar`
- Session 大概 8 小時過期，過期時 server 回 `code=2`；由 `ReloginMixin` 接住、single-flight 重登

**`stdsys.nkust.edu.tw`（學生資訊系統）**
- 跟 webap 是兩支獨立的校內系統，但走 SSO：webap 登入後呼叫 `loginToStdsys()` 把 session 帶過去
- `StdsysHelper` **不持有自己的 Dio**，直接用 `WebApHelper.dio`，所以 cookie jar 同時帶兩邊 session
- 多數 capability 在 stdsys 也能查（Course / Score / Semester / UserInfo），使用者可在設定頁選偏好來源（`CrawlerSelector`），預設 webap 優先
- stdsys 獨家功能：在校證明（`getEnrollmentLetter`）、教室借用查詢（`roomList` / `roomCourseTableQuery`）、PDF 格式成績單（`getScoresByYearSemester`）
- `getSemesters` 需要帶 antiforgery token + `X-Requested-With` header（df7fad8d 修過的坑）

**`leave.nkust.edu.tw`（請假系統）**
- 登入流程跟 webap 不同：headers 不一樣、且通常要在 WebView 內完成（學校導頁邏輯複雜，純 HTTP 客戶端不好處理）
- `LeaveHelper` 有自己的 Dio 但**借 webap 的 cookieJar**，登入後手動把 cookie `setCookie(url, name, value, domain)` 注入
- 唯一提供 `LeaveProvider`，沒有來源切換
- 送請假要附證明圖片（`submit(data, proofImage)`），multipart upload

**`vms.nkust.edu.tw`（校車系統）**
- **完全獨立**，自己的 Dio + 自己的 CookieJar，跟 webap session 無關
- 登入是直接打 vms 的 form POST，不走 SSO，所以 `VmsBusHelper.isLogin` 是獨立旗標
- 沒有 `ReloginMixin`（暫未包進 auto-relogin 機制）
- 歷史包袱：合校（KUAS + 第一 + 海大 → NKUST）前的 `bus.kuas.edu.tw` 跟過渡期的 `mobile.nkust.edu.tw` 校車入口都已刪除；現在校車**只走 vms**

**`nkust.edu.tw`（學校官網）**
- 純讀取學校公告，不需登入
- `NKUSTHelper` 完全獨立

### 修 scraper 時要先判斷的事

1. **是哪一隻 helper 的問題？** 從錯誤 stack 找到呼叫的 capability 介面，再從 `Helper._registerProviders()` 反推（同一個 capability 可能 webap / stdsys 都註冊了）
2. **是 NKUST server 改了 HTML，還是我方邏輯？** 先比對 `assets_test/` 或 `packages/nkust_crawler/test/fixtures/` 內的 HTML fixture 跟現場回應差異
3. **動到登入流程前**，看清楚是 webap captcha、stdsys SSO、leave WebView、還是 vms form POST，這四條登入路徑彼此不相關
4. **動到 cookie 行為前**，看 `docs/cookie-handling.md` 和 `packages/nkust_crawler/lib/src/interceptors/safe_cookie_manager.dart`；webap / stdsys / leave 共用 cookie jar，動錯一個會影響三個系統
5. **historic context**：`docs/crawler-architecture.md` 附錄 B 有歷代爬蟲遷移紀錄（為什麼 vms 2025 年才拆出來、為什麼 mobile portal 被砍），看到看似奇怪的設計先去那邊找原因

## 程式碼慣例

- 嚴格遵守 `analysis_options.yaml`：`prefer_single_quotes`、`always_specify_types`、`lines_longer_than_80_chars` 都是開啟的
- 變數命名一律英文
- **不要主動加註解**，除非要解釋「為什麼」（特殊處理、繞 bug、暫時方案才寫）；不要解釋程式碼在做什麼
- 不要在程式碼裡留註解掉的舊邏輯，該刪就刪（git 會記得）
- i18n 字串只能透過 slang（`t.xxx.yyy`）取得，不要硬寫中文字串到 widget；新增字串改 `lib/l10n/*.i18n.json` 再跑 build_runner
- Dart model 的 `fromJson` / `toJson` 由 `json_serializable` 產生，不要手寫 `.g.dart`
- 主 app 用 `lint: ^2.1.2`；`packages/nkust_crawler` 用同一份 lint 但有自己的 `analysis_options.yaml`

## Branch 與 PR 規則

```
feature/xxx ─┐
fix/xxx     ─┴─→ master ─→ develop（Beta 發版）
                      └─→ production（正式發版）
```

- 開新 branch 一律從 `master`
- PR target 是 `master`，**不是** `develop` / `production`
- `develop` / `production` 由維護者合併 `master` 過去，並觸發 CD（見 `README.md` 的 CI/CD 表）

### Commit message（Conventional Commits）

```
<type>(<scope>): <subject>
```

- `type`: `feat` / `fix` / `refactor` / `chore` / `docs` / `test` / `style` / `perf` / `ci` / `build`
- subject 用英文、小寫開頭、不加句點、祈使句（`add`，不是 `added`）
- 一個 commit 只做一件事
- 不要加 emoji，不要加 `Generated with Claude Code` 之類署名

### PR 描述

繁體中文（台灣用語），技術名詞保留英文。依序：

1. 變更摘要（1–2 句）
2. 對應 ticket：`Refs #12345`
3. 變更內容（條列重點）
4. 測試方式（哪個 flavor / 平台 / 是否跑 live test）
5. 影響範圍與風險

PR 開啟後 `.pr_agent.toml` 會自動觸發 `qodo-merge-pro` 跑 `/describe`、`/review`、`/update_changelog`，可保留也可覆寫。

### Changelog

每次 PR 合進 `master` 時，PR body 內可塞 changelog 標記，CD 發版時 `.github/scripts/aggregate_changelog.sh` 會聚合最後寫入 `changelog.json`，再給 Fastlane 用。詳見 `docs/changelog-pipeline.md`。

## CI/CD

| Workflow | 觸發 | 內容 |
|----------|------|------|
| `.github/workflows/ci.yml` | PR / push to `master` `develop` | analyze + test（主 app + crawler package 分開），build 各平台 |
| `.github/workflows/cd.yml` | push to `develop` / `production` | 發版（Play Store / TestFlight / GitHub Release / Snap） |
| `.github/workflows/crawler-monitor.yml` | schedule | 定期跑 live test，校方系統壞掉時告警 |
| `.github/workflows/pr_agent.yml` | PR event | qodo-merge-pro auto-review |
| `.github/workflows/pr_changelog.yml` | PR event | 維持 PR body 的 changelog 區塊 |

iOS / macOS / Android signing 用 self-hosted runner（避免 GitHub-hosted runner 的 keychain / Ruby 安裝問題，見 `cd.yml` 內註解）。Agent 不要動 self-hosted runner 相關設定。

## 機密與設定檔

- `dev_configs.zip.gpg`：加密過的 Firebase / signing 設定，本地解密用 `scripts/decrypt_dev_configs.sh`（需要 passphrase）
- `dev_configs.zip`：解密後產物，**不要 commit**
- Android keystore、Apple App Store Connect API key：由 GitHub Secrets 管理，僅 CD 流程內 decode
- Agent **絕不**將 `NKUST_USERNAME` / `NKUST_PASSWORD` / API key / passphrase 寫進 code、commit、log、或 PR description

## Agent 行為守則

1. **語言**：使用者偏好繁體中文（台灣用語）；技術名詞、API、套件名、檔名、錯誤訊息保留英文原文；中英文之間加半形空格
2. **回答風格**：先給結論再給細節；不要客套開場 / 結尾；不要在程式碼裡主動加註解
3. **動 `packages/nkust_crawler/`** 前，先讀 `docs/crawler-architecture.md` 和 `docs/refactor-scraper-state-design.md`
4. **修 scraper bug** 前，先確認是 NKUST server 變更（HTML 結構改了）還是我方邏輯問題；前者要更新 fixture（`assets_test/` 或 `packages/nkust_crawler/test/fixtures/`）
5. **不要**：
   - 升級 Flutter / Dart SDK 版本（除非使用者明確指示）
   - 把 `packages/**` 加回 root `flutter analyze`（會壞 CI）
   - 為了讓 CI 過而加 `// ignore:` 或關掉 lint rule，先想根因
   - 主動跑 `git push` / `gh pr create` / `gh pr merge`，除非使用者明確要求
6. **可以**：自由跑本地 `flutter analyze` / `flutter test` / `dart analyze` / `dart test`，自由讀任何檔案，自由 edit 程式碼後再 review

## 版本歷史

- 2026-05-25：初版，對應 master `1ae3ab65`（crawler package 抽離後）
