[![Codemagic build status](https://api.codemagic.io/apps/5c24676757670e0009de0003/5c24676757670e0009de0002/status_badge.svg)](https://codemagic.io/apps/5c24676757670e0009de0003/5c24676757670e0009de0002/latest_build)  
<a href='https://play.google.com/store/apps/details?id=com.kuas.ap&hl=zh_TW'><img alt='Get it on the App Store' src='screenshots/google_play.png' height='48px'/></a>
<a href='https://itunes.apple.com/us/app/%E9%AB%98%E7%A7%91%E6%A0%A1%E5%8B%99%E9%80%9A/id1439751462?mt=8'><img alt='Get it on the App Store' src='screenshots/app_store.png' height='48px'/></a>
# 高科校務通(NKUST AP)

高雄科技大學校務系統App，使用由Goolge開發的UI框架[Flutter](https://flutter.dev/)開發

# 支援平台

- [X] [Android](https://play.google.com/store/apps/details?id=com.kuas.ap&hl=zh_TW)
- [X] [iOS](https://itunes.apple.com/us/app/%E9%AB%98%E7%A7%91%E6%A0%A1%E5%8B%99%E9%80%9A/id1439751462?mt=8)
- [X] [Web(Beta)](https://nkust-ap-flutter.firebaseapp.com)
- [X] [Windows(Pre-Dev)](https://drive.google.com/file/d/1rgzx7p_kNRpJyGOkwXF_PLBkWUVGhM3J/view?usp=sharing)
- [X] [MacOS(Beta)](https://drive.google.com/open?id=1ag3fsRN6pQv47T01Aa0EqTY2has83xPV)
- [X] [Linux(Alpha)](https://drive.google.com/file/d/1JGuuWjjBYjzofB24GrgNjpJ1EYA3GcBd/view?usp=sharing)

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

## 步驟
1. `Fork` 此專案到你的 GitHub 帳號.
2. 挑選一個你想解決的 [issue](https://github.com/NKUST-ITC/NKUST-AP-Flutter/issues).
3. 創建一個分支(Branch)以該問題命名.
```console
$ git branch feature/issue-short-name
```
例如, 如果挑選的問題是 [改善課表介面](https://github.com/NKUST-ITC/NKUST-AP-Flutter/issues/46). 分支可命名 `feature/improve-course-layout`.

4. 提出 [Pull Reqeust](https://github.com/NKUST-ITC/NKUST-AP-Flutter/pulls) 從 `你的分支` to `NKUST-ITC/NKUST-AP-Flutter/master分支` .
5. 等待功能合併或者提出後續問題
