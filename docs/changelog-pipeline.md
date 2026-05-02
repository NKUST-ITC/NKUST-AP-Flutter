# Changelog Pipeline

本文件說明 NKUST AP Flutter 兩條互不相干的 changelog 流程：

1. **Store / GitHub Release notes** — 由 PR 留言 → LLM aggregator → 上架腳本，全自動。
2. **App 內升版／更新對話框** — 讀取 root `changelog.json`，需要手動填寫 entry。

兩條流程**目前沒有互通**：自動 aggregator **不會**回填 `changelog.json`。要讓使用者在 app 內看到「剛升版」與「有新版本」對話框內容，發版時要手動加 entry。

---

## 一、Store / Release notes 流程（自動）

```
[PR 合併到 develop]
        │  .github/workflows/pr_changelog.yml
        ▼
qwen2.5:3b（self-hosted Ollama）依 PR title + body 生成 {"zh-TW", "en-US"}
        │  gh pr comment "<!-- changelog-entry {...} -->"
        ▼
[push 到 develop 或 production]
        │  .github/workflows/cd.yml → prepare job
        ▼
.github/scripts/aggregate_changelog.sh <beta|stable>
   ├─ gh release list 找上次 release 時間（stable 排除 pre-release）
   ├─ gh pr list --base develop --state merged 撈那之後的 PR
   └─ 每個 PR 抓最後一筆 <!-- changelog-entry --> → changelog_aggregated.json
        │  upload-artifact: changelog-aggregated
        ▼
deploy_android / deploy_ios / deploy_macos / github_release jobs
   └─ .github/scripts/generate_changelog.sh <version_code> <target>
        env AGGREGATED_CHANGELOG=changelog_aggregated.json
        ├─ android  → metadata/android/{en-US,zh-TW}/changelogs/default.txt
        ├─ ios|macos → en-US.txt / zh-TW.txt（Fastlane App Store metadata）
        └─ github   → RELEASE_NOTES_GENERATED.md（GitHub Release notes）
```

### 觸發範圍

`pr_changelog.yml` 只在改到 `lib/**`、`pubspec.yaml`、`pubspec.lock`、`android/**`、`ios/**`、`macos/**`、`linux/**`、`windows/**`、`assets/**` 的 PR 才會觸發。純 docs / CI / scripts 變動 **不會** 進 changelog。

### release type

| 觸發來源 | release type | 撈取範圍 |
|---|---|---|
| push 到 `develop` | `beta` | 上一個 release（含 pre-release）之後合併的 PR |
| push 到 `production` | `stable` | 上一個正式 release 之後（**含期間 betas 累積**）的 PR |

### 失敗處理

| 情境 | 行為 |
|---|---|
| Ollama 沒回應 | workflow `exit 0`，PR 不貼留言 |
| LLM 回 malformed JSON | 同上，`jq -e` 校驗失敗就略過 |
| PR 沒 changelog 留言 | aggregator 跳過該 PR |
| `changelog_aggregated.json` 為空 | `generate_changelog.sh` 寫 fallback：「問題修正與效能改善。」/ `Bug fixes and improvements.` |

### LLM 輸出契約

**System prompt**（`pr_changelog.yml` 內嵌）：
> 你是 App 更新說明撰寫員。根據 PR 資訊，用一句話生成使用者可看懂的更新描述。繁體中文使用台灣用語，避免技術術語。只輸出 JSON，格式為 `{"zh-TW": "...", "en-US": "..."}`，不要其他文字。

**留言格式**：
```html
<!-- changelog-entry
{"zh-TW": "...", "en-US": "..."}
-->
```

### 手動覆寫

合併後若 LLM 內容不滿意，**直接編輯 PR 那則 `<!-- changelog-entry -->` 留言**——aggregator 用 `last`，會抓最後一筆。不必重跑 workflow。

---

## 二、App 內版本對話框流程（半手動）

`lib/pages/home_page.dart` 的 `_checkData` 在 app 啟動時跑，會用兩種對話框顯示版本資訊，**兩者都讀同一份 root `changelog.json`**：

| 觸發時機 | 對應對話框 | 資料來源 | 索引鍵 |
|---|---|---|---|
| 偵測到 `prefCurrentVersion != packageInfo.buildNumber` | `DialogUtils.showUpdateContent`（剛升版） | bundled `changelog.json`（透過 `FileAssets.changelogData` / `rootBundle`） | `packageInfo.buildNumber` |
| Firebase Remote Config 顯示有新版可下載 | `DialogUtils.showNewVersionContent`（有新版本） | Remote Config `newVersionContent` → 被 `https://raw.githubusercontent.com/NKUST-ITC/NKUST-AP-Flutter/master/changelog.json` 蓋過 | `versionInfo.code`（Remote Config `appVersion`） |

> 兩條路徑都吃 **root** `changelog.json`：bundled 是 `pubspec.yaml` flutter assets 把 root 那份打包進 app；master fetch 是直接抓 GitHub raw URL。

### `changelog.json` 格式（現役）

```json
{
  "<versionCode>": {
    "version": "<x.y.z>",
    "date": "<YYYY-MM-DD>",
    "zh-TW": [ "...", "..." ],
    "en-US": [ "...", "..." ]
  }
}
```

- `versionCode` 是字串型 key，對應 Android `versionCode` / iOS `CFBundleVersion`，亦即 `packageInfo.buildNumber`。
- `zh-TW` / `en-US` 是字串陣列；UI 會自動加上 `•` 前綴並用換行串接。
- 新版本 entry 放在 JSON object 開頭（與既有檔案順序一致）。

### Legacy 格式（v3.8 之前）

舊條目（`30708` 以下、`assets/changelog.json` 整份）使用：
```json
"<versionCode>": {
  "visible": true,
  "date": "YYYY/MM/DD",
  "zh-TW": "* item1\n* item2",
  "en-US": "* item1\n* item2"
}
```

字串型而非陣列。`_checkData` 同時容忍兩種：

```dart
if (localeValue is List) {
  updateNoteContent = localeValue.map((e) => '• $e').join('\n');
} else if (localeValue is String && localeValue.isNotEmpty) {
  updateNoteContent = localeValue;
}
```

新增 entry 一律使用陣列格式即可。

### 死檔提醒：`assets/changelog.json`

這份檔停在 2021 年（v3.8.x），**沒有任何程式碼引用**：
- `FileAssets.changelog = 'changelog.json'`（root，沒 `assets/` 前綴）
- `pubspec.yaml` flutter assets 也只列 root `changelog.json`

可以視同 dead code，未來有清掃機會再刪。

---

## 三、發版時的 manual checklist

每次升 `pubspec.yaml` 版本（不論 minor/major），請補一筆 `changelog.json` entry：

1. 拿當前 GitHub Variable `VERSION_CODE`（CD `prepare` job 用的那個值）作為 key。
2. 想好那個版本最值得讓使用者注意的 1–3 句中英對照亮點，**避免技術術語**（與 store 上架文案一致的口吻）。
3. PR 進 master 即可——這份檔同時被 bundle 到 app 跟由 raw.githubusercontent.com fetch，所以**新 entry 會立刻對未升版的舊版使用者生效**（透過「有新版本」對話框）；升版到該 build 的使用者開 app 時則會看到「剛升版」對話框。

> 不補 entry 也能 release，只是兩個對話框顯示不到內容。store metadata 不受影響。

### 範例

```json
"40044": {
  "version": "4.0.0",
  "date": "2026-05-02",
  "zh-TW": [
    "全新 Material Design 3 介面：採用 Material You 設計語言，帶來更現代的視覺風格與動態色彩體驗。"
  ],
  "en-US": [
    "All-new Material Design 3 interface: Adopts the Material You design language, delivering a more modern visual style with dynamic color experiences."
  ]
}
```

---

## 四、檔案／腳本一覽

| 路徑 | 角色 |
|---|---|
| `.github/workflows/pr_changelog.yml` | PR merged → LLM 生成單句雙語條目 → 貼回 PR 留言 |
| `.github/scripts/aggregate_changelog.sh` | CD prepare：撈未發行 PR 的 changelog 留言 → `changelog_aggregated.json` |
| `.github/scripts/generate_changelog.sh` | 把 aggregated JSON 轉成各平台 metadata；`AGGREGATED_CHANGELOG` 未設則 fallback 到 root `changelog.json` |
| `changelog.json`（repo root） | App 內兩個對話框讀的來源；同時被 bundle 進 app（`pubspec.yaml` flutter assets） + master raw fetch |
| `assets/changelog.json` | **Dead code**，停在 v3.8.x |
| `lib/pages/home_page.dart` `_checkData` | 啟動時跑對話框邏輯 |
| `lib/res/assets.dart` `FileAssets.changelogData` | 讀 bundled root changelog |
