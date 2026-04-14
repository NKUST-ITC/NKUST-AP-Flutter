# 第三方 i18n 管理平台評估報告

## 1. 現況分析

### 1.1 目前架構

| 項目 | 說明 |
|------|------|
| 框架 | Flutter `intl` 套件 + `flutter_intl` IDE 插件 |
| 翻譯格式 | ARB (Application Resource Bundle) |
| 支援語言 | 繁體中文 (zh_TW, 主語系)、英文 (en)、日文 (ja) |
| 翻譯鍵數量 | 207 個 |
| 參數化字串 | 14 個 (使用 `%s` 佔位符搭配 sprintf) |
| 延遲載入 | 已啟用 (`use_deferred_loading: true`) |
| 檔案位置 | `lib/l10n/intl_*.arb` |
| 程式碼產生 | `lib/l10n/l10n.dart` + `lib/l10n/intl/messages_*.dart` |

### 1.2 現有流程的痛點

- **手動管理 ARB 檔案**：新增或修改翻譯鍵時，需同時編輯 3 個 ARB 檔案，容易漏改
- **無翻譯狀態追蹤**：無法得知哪些鍵在哪些語系缺少翻譯
- **協作困難**：非開發人員（如翻譯者）需直接編輯 JSON 格式的 ARB 檔案
- **無審核流程**：翻譯品質無法經過 review 流程
- **無翻譯記憶體**：重複或相似的翻譯無法複用
- **無上下文資訊**：翻譯者看不到字串在 UI 中的使用場景

---

## 2. 第三方平台比較

### 2.1 候選平台一覽

| 平台 | 類型 | ARB 支援 | 免費方案 | CLI 工具 | GitHub 整合 | API |
|------|------|----------|----------|----------|-------------|-----|
| **Crowdin** | SaaS | 原生支援 | 開源專案免費 | crowdin-cli | 完整 | REST |
| **Lokalise** | SaaS | 原生支援 | 無（14天試用）| lokalise2 | 完整 | REST |
| **Phrase** | SaaS | 原生支援 | 無（14天試用）| phrase-cli | 完整 | REST |
| **POEditor** | SaaS | 支援匯入匯出 | 1,000 字串免費 | 無官方 CLI | Webhook | REST |
| **Weblate** | 自架/SaaS | 支援 | 自架免費；SaaS 有免費方案 (開源) | wlc | 完整 | REST |
| **Transifex** | SaaS | 支援匯入匯出 | 開源專案免費 | tx-cli | 完整 | REST |

---

### 2.2 各平台詳細評估

#### A. Crowdin

**概述**：業界最廣泛使用的翻譯管理平台之一，對開源專案完全免費。

**優點**：
- 開源專案可申請免費方案（本專案符合資格，已在 GitHub 公開）
- 原生支援 ARB 格式，無需格式轉換
- 強大的 GitHub 整合：可自動同步分支、建立 PR
- `crowdin-cli` 支援 `crowdin push` / `crowdin pull` 操作
- 內建翻譯記憶體 (TM) 和術語庫 (Glossary)
- 支援機器翻譯整合（Google Translate、DeepL 等）預填翻譯
- 支援螢幕截圖上傳，讓翻譯者看到 UI 上下文
- 支援 ICU MessageFormat 和 printf-style 參數

**缺點**：
- 免費方案僅限開源專案（若未來轉為私有需付費）
- 介面功能豐富但學習曲線稍高
- 免費方案不含某些進階功能（如分支管理的部分功能）

**定價**：
- 開源：免費
- Team：$100/月起

**整合流程**：
```
GitHub Repo ← crowdin.yml → Crowdin Project
      ↑                           ↓
  Auto PR (翻譯完成)        翻譯者在平台上翻譯
      ↑                           ↓
  合併 PR ← 審核            翻譯記憶體 / 機器翻譯輔助
```

---

#### B. Lokalise

**概述**：專為開發者設計的現代化翻譯管理平台，Flutter/Dart 生態支援度高。

**優點**：
- 對 Flutter ARB 有專門的整合指南和良好支援
- 提供 Over-the-Air (OTA) 翻譯更新（無需重新發布 App）
- 直覺的 Web 編輯器，適合非技術翻譯者
- 強大的品質保證功能（自動檢查參數遺漏、翻譯一致性等）
- 支援複數形式和性別變化等 ICU 語法
- GitHub Actions 整合文件完善
- 翻譯工作流程支援（任務分配、截止日期、審核流程）

**缺點**：
- 無免費方案（僅 14 天試用）
- 付費方案價格較高
- OTA 功能需額外整合 SDK

**定價**：
- Essential：$120/月起
- Pro：$300/月起

---

#### C. Phrase (前身為 PhraseApp)

**概述**：老牌翻譯管理平台，企業級功能完整。

**優點**：
- 長期穩定的平台，社群資源豐富
- `phrase-cli` 功能完善，適合 CI/CD 整合
- 支援分支翻譯（與程式碼分支對應）
- 翻譯記憶體和術語庫功能成熟
- 支援 ARB 格式匯入匯出
- 高品質的 QA 檢查

**缺點**：
- 無免費方案
- 近年被收購後，定價策略變動頻繁
- 介面有時反應較慢

**定價**：
- Starter：$129/月起
- Growth：$259/月起

---

#### D. POEditor

**概述**：輕量、低成本的翻譯管理平台。

**優點**：
- 免費方案允許 1,000 字串（本專案 207 個鍵可完全涵蓋）
- 介面簡潔直覺
- 支援 ARB 格式匯入/匯出
- 支援自動翻譯（Google Translate、Microsoft Translator）
- API 可用於基本的自動化
- 價格親民

**缺點**：
- 無官方 CLI 工具（需透過 API 自行腳本化）
- GitHub 整合有限（僅 Webhook，無自動 PR）
- 缺乏進階工作流程功能（審核、任務分配）
- 翻譯記憶體功能有限
- 免費方案限制：無協作者角色權限控制

**定價**：
- Free：1,000 字串
- Freelancer：$14.99/月
- Startup：$23.99/月

---

#### E. Weblate

**概述**：開源翻譯管理平台，可自行架設或使用 SaaS 版本。

**優點**：
- 完全開源 (GPL-3.0)，可自行部署
- SaaS 版對自由/開源軟體專案免費
- 支援 ARB 格式
- 原生 Git 整合（直接操作 Git 倉庫）
- 翻譯記憶體和機器翻譯整合
- 社群翻譯友善，可公開翻譯入口讓社群貢獻
- 完整的翻譯品質檢查

**缺點**：
- 自行架設需維運成本
- SaaS 版 UI 相對樸素
- Flutter/ARB 的整合文件不如 Crowdin、Lokalise 完善
- 效能在大量字串時可能稍差

**定價**：
- 自架：免費（開源）
- SaaS 開源專案：免費
- SaaS 基本方案：€16/月起

---

#### F. Transifex

**概述**：企業級翻譯管理平台，適合大規模多語系專案。

**優點**：
- 開源專案免費方案
- 強大的 API 和 CLI 工具 (`tx`)
- 支援 ARB 格式匯入匯出
- 完整的翻譯工作流程
- OTA 翻譯更新 (Transifex Native)

**缺點**：
- 介面較複雜
- ARB 不是原生支援格式，需做格式對應
- 社群活躍度近年下降
- 某些功能鎖在高階方案

**定價**：
- 開源：免費
- Starter：$120/月起

---

## 3. 整合工作流程設計

### 3.1 推薦工作流程（以 Crowdin 為例）

```
開發者新增/修改翻譯鍵
        ↓
提交到 GitHub (intl_zh_TW.arb 為 source)
        ↓
Crowdin GitHub Integration 自動偵測變更
        ↓
新的翻譯鍵出現在 Crowdin 平台
        ↓
翻譯者在 Crowdin Web 編輯器中翻譯 (en, ja)
        ↓
翻譯完成後 Crowdin 自動建立 PR
        ↓
開發者 Review 並合併 PR
        ↓
執行 flutter_intl 產生 l10n.dart 等檔案
```

### 3.2 Crowdin 設定檔範例

```yaml
# crowdin.yml
project_id_env: CROWDIN_PROJECT_ID
api_token_env: CROWDIN_API_TOKEN

files:
  - source: /lib/l10n/intl_zh_TW.arb
    translation: /lib/l10n/intl_%locale%.arb
    type: arb
```

### 3.3 CI/CD 整合（GitHub Actions 範例）

```yaml
# .github/workflows/crowdin-sync.yml
name: Crowdin Sync
on:
  push:
    branches: [master]
    paths:
      - 'lib/l10n/intl_zh_TW.arb'

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Upload sources to Crowdin
        uses: crowdin/github-action@v2
        with:
          upload_sources: true
          download_translations: false
        env:
          CROWDIN_PROJECT_ID: ${{ secrets.CROWDIN_PROJECT_ID }}
          CROWDIN_PERSONAL_TOKEN: ${{ secrets.CROWDIN_PERSONAL_TOKEN }}
```

---

## 4. 綜合評估矩陣

以 1~5 分評分（5 分最佳），依本專案需求加權：

| 評估項目 (權重) | Crowdin | Lokalise | Phrase | POEditor | Weblate | Transifex |
|-----------------|---------|----------|--------|----------|---------|-----------|
| 成本效益 (25%) | 5 | 2 | 2 | 5 | 5 | 5 |
| ARB 格式支援 (20%) | 5 | 5 | 4 | 3 | 4 | 3 |
| GitHub 整合 (20%) | 5 | 5 | 4 | 2 | 5 | 4 |
| 易用性 (15%) | 4 | 5 | 4 | 5 | 3 | 3 |
| Flutter 生態整合 (10%) | 5 | 5 | 4 | 3 | 3 | 3 |
| 翻譯品質工具 (10%) | 5 | 5 | 5 | 3 | 4 | 4 |
| **加權總分** | **4.85** | **4.05** | **3.60** | **3.55** | **4.05** | **3.75** |

---

## 5. 建議方案

### 5.1 首選推薦：Crowdin

**理由**：
1. **零成本**：本專案為 GitHub 公開的開源專案（MIT 授權），符合 Crowdin 開源免費方案資格
2. **原生 ARB 支援**：無需格式轉換，直接對接現有的 `.arb` 檔案
3. **GitHub 深度整合**：自動偵測原始檔變更、自動建立翻譯 PR，與現有開發流程無縫銜接
4. **社群翻譯友善**：可公開翻譯入口，讓校內國際學生或社群貢獻者參與翻譯
5. **翻譯輔助**：翻譯記憶體 + 機器翻譯預填，可大幅加速翻譯流程
6. **成熟穩定**：業界廣泛使用，文件完善

### 5.2 備選方案：Weblate (SaaS)

**適用情境**：若偏好完全開源的工具鏈，或未來有自架需求。

### 5.3 備選方案：POEditor

**適用情境**：若只需要最輕量的翻譯管理，且不需要 GitHub 自動同步。207 個鍵在免費方案限額內。

---

## 6. 導入 Crowdin 的步驟

### Phase 1：初始設定（約 1 小時）

1. 以 GitHub 帳號登入 Crowdin，申請開源專案方案
2. 建立專案，設定 source language 為 `zh_TW`，target languages 為 `en`、`ja`
3. 安裝 Crowdin GitHub App，授權 `NKUST-ITC/NKUST-AP-Flutter` 倉庫
4. 在專案根目錄新增 `crowdin.yml` 設定檔
5. 首次上傳 source 檔案 (`intl_zh_TW.arb`)

### Phase 2：匯入既有翻譯（約 30 分鐘）

1. 透過 Crowdin 上傳 `intl_en.arb` 和 `intl_ja.arb` 作為既有翻譯
2. 驗證所有 207 個鍵的翻譯都已正確匯入
3. 確認參數化字串（`%s`）的對應正確

### Phase 3：建立工作流程（約 1 小時）

1. 設定 GitHub 整合的自動同步規則
2. 設定翻譯完成後自動建立 PR 的規則
3. 建立翻譯品質檢查規則（參數一致性、長度限制等）
4. （選擇性）設定機器翻譯預填

### Phase 4：調整開發流程

**開發者端**：
- 只需維護 `intl_zh_TW.arb`（source），不再手動編輯 `intl_en.arb`、`intl_ja.arb`
- 新增翻譯鍵後 push 到 GitHub，Crowdin 會自動偵測
- Review 並合併 Crowdin 建立的翻譯 PR

**翻譯者端**：
- 在 Crowdin Web 編輯器中翻譯
- 利用翻譯記憶體和機器翻譯建議加速工作
- 可加入審核流程確保品質

---

## 7. 注意事項

### 7.1 格式相容性

目前專案使用 `%s` 作為參數佔位符（搭配 `sprintf` 套件），而非 Flutter 官方推薦的 ICU MessageFormat `{paramName}`。Crowdin 的 ARB parser 支援兩種格式，但建議：

- **短期**：維持現有 `%s` 格式，Crowdin 可正確處理
- **長期**：考慮遷移到 ICU MessageFormat（如 `{date}` 取代 `%s`），可獲得更好的翻譯上下文

### 7.2 日文語系 (ja) 的註冊問題

目前 `app.dart` 的 `supportedLocales` 僅註冊了 `en` 和 `zh_TW`，但 `intl_ja.arb` 已存在完整翻譯。導入平台前建議先確認日文是否為正式支援語系，若是則應加入 `supportedLocales`。

### 7.3 產生的程式碼管理

`flutter_intl` 產生的 `l10n.dart` 和 `messages_*.dart` 目前存在於版本控制中。導入翻譯平台後的建議做法：

- 翻譯 PR 合併後需執行 `flutter pub run intl_utils:generate` 重新產生程式碼
- 可在 CI 中自動化此步驟，或在 PR 合併後的 hook 中執行

### 7.4 ap_common 套件的翻譯

本專案依賴 `ap_common` 套件，該套件可能有自己的翻譯鍵。導入平台時需確認是否需一併管理這些翻譯，或僅管理本專案的 207 個鍵。

---

## 8. 結論

對於本專案（開源、207 個翻譯鍵、3 種語言），**Crowdin** 是最佳選擇：

- 免費（開源方案）
- 原生 ARB 支援
- GitHub 自動整合
- 成熟的翻譯輔助工具
- 導入成本低（約 2-3 小時即可完成初始設定）

導入後，翻譯管理從「開發者手動編輯 JSON 檔案」轉變為「翻譯者在 Web 平台上作業，自動化同步到程式碼倉庫」，可顯著提升多語系維護的效率和品質。
