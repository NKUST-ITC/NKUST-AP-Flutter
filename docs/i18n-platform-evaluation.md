# 第三方 i18n 管理平台評估報告（基於 slang）

> 對應 Issue: #368
> 前置依賴: #307 (Slang i18n 適配)

## 1. 背景

隨著 ap_common v2 遷移至 slang i18n（abc873693/ap_common#147），nkust_ap 也將跟進適配（#307）。
翻譯檔案格式將從 ARB 轉為 slang 的 nested JSON（`.i18n.json`），這改變了第三方平台的評估前提。

### 1.1 架構對比

| 項目 | 目前 (intl) | 遷移後 (slang) |
|------|------------|----------------|
| 翻譯格式 | `.arb` (flat JSON) | `.i18n.json` (nested JSON) |
| 參數語法 | `%s` (sprintf) | `$name` / `{name}` |
| 支援語言 | zh_TW、en、ja | 同左 |
| 翻譯鍵數量 | 207 個 | 同左（結構化後可能調整） |
| 程式碼產生 | `flutter_intl` → `l10n.dart` | `dart run slang` → `strings.g.dart` |
| 型別安全 | 無（字串 key） | 有（`t.bus.reserve`） |

### 1.2 slang 生態工具

| 套件 | 用途 |
|------|------|
| `slang` | 核心 i18n 庫 + 程式碼產生 |
| `slang_flutter` | Flutter 整合（TranslationProvider 等） |
| `slang_build_runner` | build_runner 整合 |
| `slang_gpt` | GPT 自動翻譯（legacy） |
| `slang_mcp` | MCP Server，搭配 Claude 等 LLM 翻譯（推薦） |

### 1.3 slang CLI

```
dart run slang                    # 產生 Dart 程式碼
dart run slang analyze            # 找出缺漏/未使用的翻譯
dart run slang clean              # 移除未使用的翻譯
dart run slang apply              # 補齊缺少的翻譯鍵
dart run slang normalize          # 按 base locale 排序
dart run slang migrate arb        # ARB → JSON（單向）
dart run slang stats              # 翻譯統計
dart run slang watch              # 監聽變更自動重建
```

---

## 2. 平台比較

### 2.1 總覽

| 平台 | slang 整合度 | nested JSON 支援 | 免費方案 | GitHub 整合 |
|------|-------------|------------------|----------|-------------|
| **Weblate** | 官方推薦 | 原生 | 開源免費 | Git 原生 |
| **Crowdin** | 非官方 | 支援 | 開源免費 | 完整 |
| **Lokalise** | 非官方 | 支援 | 無 | 完整 |
| **POEditor** | 非官方 | 部分 | 1,000 字串免費 | Webhook |
| **slang_mcp** | 原生 | — | 隨 LLM 訂閱 | — |

### 2.2 各平台詳細評估

#### A. Weblate — 官方推薦

slang 作者在 README 中有專屬 Weblate 設定文件，LocalSend（知名開源專案）即使用 slang + Weblate 的組合。

**優點：**
- slang 唯一官方推薦的 TMS 平台，有文件記載的設定方式
- 原生 Git 整合：直接讀寫倉庫中的 `.i18n.json`，無匯入匯出步驟
- SaaS 版對開源專案免費；也可自架（GPL-3.0）
- 社群翻譯友善，可公開翻譯入口讓貢獻者參與
- 翻譯記憶體 + 機器翻譯整合
- 完整的品質檢查（參數一致性、格式等）

**缺點：**
- SaaS 版 UI 相對樸素
- 自架需維運成本
- slang 的 key modifier（如 `(rich)`、`(context=X)`）會以原始字串顯示

**定價：** 自架免費 / SaaS 開源免費 / SaaS 基本 €16/月起

**整合流程：**
```
開發者修改 zh_TW.i18n.json (source)
        ↓
Push 到 GitHub
        ↓
Weblate 透過 Git 自動偵測變更
        ↓
翻譯者在 Weblate Web 編輯器翻譯
        ↓
Weblate 自動 commit 回倉庫（或建立 PR）
        ↓
開發者 pull 後執行 dart run slang 產生程式碼
```

#### B. Crowdin — 業界標準

**優點：**
- 開源專案免費
- 支援 nested JSON 匯入（可對接 slang 的 `.i18n.json`）
- GitHub 整合完整：自動同步、自動建立 PR
- 翻譯記憶體 + 術語庫 + 機器翻譯預填
- 螢幕截圖上傳，提供翻譯 UI 上下文
- 社群與文件最豐富

**缺點：**
- 無 slang 原生整合，需以 generic nested JSON 格式匯入
- slang 的 `$name` 參數語法需設定自訂 placeholder 規則
- key modifier 會被視為 key 名稱的一部分

**定價：** 開源免費 / Team $100/月起

#### C. Lokalise

**優點：**
- 原生支援 nested JSON（深度無限制）
- OTA 翻譯更新
- 品質保證功能強大

**缺點：**
- 無免費方案（14 天試用），$120/月起
- 無 slang 原生整合

#### D. POEditor

**優點：**
- 免費方案 1,000 字串
- 介面簡潔

**缺點：**
- nested JSON 支援有限（鍵路徑扁平化）
- 無 CLI、GitHub 整合僅 Webhook
- 不適合 slang 的巢狀結構

#### E. slang_mcp / slang_gpt — 原生 AI 翻譯

適合小團隊或開發者自行管理翻譯，可與 TMS 平台互補。

**slang_mcp（推薦）：**
- MCP Server，搭配 Claude Code 等 LLM 使用
- `dart pub global activate slang_mcp`
- 提供 `get-missing-translations`、`apply-translations` 等工具
- 無需額外 API key

**slang_gpt（legacy）：**
- `dart run slang_gpt --target=ja --api-key=<key>`
- 預設只翻譯缺少的鍵（節省成本）

---

## 3. 評估矩陣

以 slang 為前提，1~5 分評分（5 分最佳）：

| 評估項目 (權重) | Weblate | Crowdin | slang_mcp | Lokalise | POEditor |
|----------------|---------|---------|-----------|----------|----------|
| slang 相容性 (25%) | 5 | 3 | 5 | 3 | 2 |
| 成本效益 (20%) | 5 | 5 | 4 | 2 | 5 |
| GitHub/Git 整合 (20%) | 5 | 5 | 3 | 5 | 2 |
| 非技術者協作 (15%) | 4 | 5 | 1 | 5 | 4 |
| 翻譯品質工具 (10%) | 4 | 5 | 4 | 5 | 3 |
| 導入複雜度 (10%) | 4 | 3 | 5 | 3 | 3 |
| **加權總分** | **4.60** | **4.20** | **3.65** | **3.40** | **2.95** |

---

## 4. 建議方案

### 首選：Weblate

| 理由 | 說明 |
|------|------|
| 官方推薦 | slang 唯一有文件記載的 TMS 整合 |
| 實戰驗證 | LocalSend 已成功使用 slang + Weblate |
| 零成本 | 開源專案 SaaS 免費 |
| Git 原生 | 直接讀寫 `.i18n.json`，無匯入匯出 |
| 社群友善 | 可公開翻譯入口讓校內國際學生貢獻 |

### 備選 A：Crowdin

適用情境：需要更強大的翻譯記憶體、術語庫、螢幕截圖等企業級功能。
需將 `.i18n.json` 以 generic nested JSON 格式匯入，並設定自訂 placeholder 規則。

### 備選 B：slang_mcp

適用情境：團隊小、不需要非技術者參與翻譯、偏好 AI 輔助在本地完成。
可與 Weblate 互補：slang_mcp 產生初始翻譯 → Weblate 上審核修正。

---

## 5. 導入步驟（Weblate）

### 前置條件

- [ ] 完成 #307（slang i18n 適配）
- [ ] 翻譯檔案遷移為 `<locale>.i18n.json` 格式

### Phase 1：初始設定（~1 小時）

1. 在 Hosted Weblate 申請開源專案
2. 建立 component，指向 `NKUST-ITC/NKUST-AP-Flutter` 倉庫
3. 設定 source language `zh-TW`，target `en`、`ja`
4. 設定檔案路徑 pattern

### Phase 2：Weblate 設定

依 slang README 建議：
- File format: JSON nested
- File mask / template 對應 slang 命名慣例
- 啟用建議的 Weblate addons
- 設定翻譯品質檢查規則

### Phase 3：工作流程

**開發者：** 只維護 `zh_TW.i18n.json`（source），push 後 Weblate 自動偵測
**翻譯者：** 在 Weblate Web 編輯器翻譯，利用 TM 和 MT 輔助

---

## 6. 注意事項

### slang key modifier

slang 的 `(rich)`、`(plural)`、`(context=GenderContext)` 等 modifier 會在 Weblate 中顯示為 key 名稱的一部分。建議在專案中加入說明文件。

### 無 ARB 匯出

`dart run slang migrate arb` 是單向（ARB → JSON），無法反向。選擇的平台必須能直接處理 nested JSON。

### 與 slang_mcp 互補

即使導入 Weblate，仍可搭配 slang_mcp 在開發階段快速產生初始翻譯，再由翻譯者在 Weblate 上審核修正。

---

## 7. 相關 Issues

- #307 — Slang i18n 適配
- abc873693/ap_common#147 — intl → Slang 遷移
- abc873693/ap_common#151 — 清理 intl → slang 殘留
