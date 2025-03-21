[![Build Test](https://github.com/NKUST-ITC/NKUST-AP-Flutter/workflows/Build%20Test/badge.svg)](https://github.com/NKUST-ITC/NKUST-AP-Flutter/actions/workflows/workflow.yml)
[![CD Store](https://github.com/NKUST-ITC/NKUST-AP-Flutter/workflows/Store%20CD/badge.svg)](https://github.com/NKUST-ITC/NKUST-AP-Flutter/actions/workflows/workflow.yml)

<a href='https://play.google.com/store/apps/details?id=com.kuas.ap&hl=zh_TW'><img alt='Get it on the App Store' src='screenshots/google_play.png' height='48px'/></a>
<a href='https://itunes.apple.com/us/app/id1439751462'><img alt='Get it on the App Store' src='screenshots/app_store.png' height='48px'/></a>
<a href='https://snapcraft.io/nkust-ap'><img alt='Get it on the App Store' src='screenshots/snap_store.png' height='48px'/></a>
# 高科校務通(NKUST AP)

高雄科技大學校務系統 App，使用由 Google 開發的 UI 框架[Flutter](https://flutter.dev/)開發

# 支援平台

- [X] [Android](https://play.google.com/store/apps/details?id=com.kuas.ap&hl=zh_TW)
- [X] [iOS](https://itunes.apple.com/us/app/id1439751462)
- [ ] [Web](https://nkust-ap-flutter.web.app)
- [X] [Windows(目前無法使用因為目前 TFLite 套件不支援 桌面版)](https://github.com/NKUST-ITC/NKUST-AP-Flutter/releases/download/v3.8.5/nkust_ap_windows.zip)
- [X] [MacOS(目前無法使用因為目前 TFLite 套件不支援 桌面版)](https://itunes.apple.com/us/app/id1439751462)
- [X] [Linux(目前無法使用因為目前 TFLite 套件不支援 桌面版)](https://snapcraft.io/nkust-ap)

# 維護團隊

高科校務通為校務通起源，目的為讓高科學生更方便的存取學校系統。目前為版本三，由 Flutter 做開發。後續衍伸出許多校務通系列，又因套件獨立而產生AP Common，讓校務通開發更加統一與高效。  
目前由校務通團隊做維護，App 商店託管由 [OCF 財團法人開放文化基金會](https://ocf.tw)管理。

v1 & v2 開發人員：呂紹榕（Louie Lu），姜尚德（JohnThunder），registerAutumn，詹濬鍵（Evans），陳建霖（HearSilent），陳冠蓁，徐羽柔
v3 開發人員：房志剛（Rainvisitor），林義翔（takidog）林鈺軒（Lin YuHsuan），周鈺禮（Gary）

OCF 由多個台灣開源社群共同發起，在開放源碼、開放資料、開放政府等領域，提供社群支援、組織合作、海外交流、顧問諮詢等服務。期待以法人組織的力量激起開放協作的火花。

### Web 版本自7月起因為學校阻擋高請求IP，改為客戶端爬蟲，因此暫時無法使用

# 如何貢獻?
如果你想為專案付出一份心力，你需要知道:
 - [Flutter](https://flutter.dev/) : 
   專案所使用的基本框架
 - [Git](https://git-scm.com/) : 
   使用Git作為版本控制的工具，倉儲採用GitHub
 - [AP-COMMON](https://github.com/abc873693/ap_common) : 
   校務通系列UI與函式庫共用工程，有共用的項目可至該專案檢查
 - [NKUST API](https://github.com/NKUST-ITC/NKUST-AP-API) : 
   高科校務通後端HTTP RESTful API，代為App處理所有爬蟲問題

## 開發事前需求

### 開發需安裝工具

 - GPG 

### 解密開發所需檔案

`$DEV_CONFIGS_PASSPHRASE` 替換成正確的密碼

```bash
  gpg --quiet --batch --yes --decrypt --passphrase="$DEV_CONFIGS_PASSPHRASE" \
    --output dev_configs.zip dev_configs.zip.gpg && sh scripts/unzip_dev_configs.sh
```

## 如何貢獻
1. `Fork` 此專案到你的 GitHub 帳號.
2. 挑選一個你想解決的 [issue](https://github.com/NKUST-ITC/NKUST-AP-Flutter/issues).
3. 創建一個分支(Branch)以該問題命名.
```console
$ git branch feature/issue-short-name
```
例如, 如果挑選的問題是 [改善課表介面](https://github.com/NKUST-ITC/NKUST-AP-Flutter/issues/46). 分支可命名 `feature/improve-course-layout`.

4. 提出 [Pull Reqeust](https://github.com/NKUST-ITC/NKUST-AP-Flutter/pulls) 從 `你的分支` to `NKUST-ITC/NKUST-AP-Flutter/master分支` .
5. 等待功能合併或者提出後續問題
