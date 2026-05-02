# 把 Flutter app 的爬蟲層抽成純 Dart package：實戰指南

> 寫於 2026-05-02。以 nkust_ap（高科大校務通 Flutter app）的 crawler 抽出為 `nkust_crawler` 為例，整理實際做下來的流程、踩到的坑、以及最後達到的形狀，給之後做類似事情的人省去重做調查的時間。
>
> 對象讀者：手上有一個 Flutter 跨平台 app，裡面有一坨「業務邏輯」（爬蟲、API client、parser、模型）想抽出共用 / 拿去 server-side 跑 / 寫 CLI / 寫第二個 native client，但實作裡面散著各種 Flutter SDK 依賴。

## TL;DR — 七步走完

1. **盤點 Flutter 依賴的「橫切點」** — kIsWeb、rootBundle、Crashlytics、PreferenceUtil、ImagePicker.XFile、BuildContext、native_dio_adapter、Firebase 之類。
2. **介面化（in-place，不搬檔）** — 為每個橫切點抽 interface（CrashReporter / KeyValueStore / CaptchaSolver / CaptchaTemplateProvider / PdfTextExtractor 等），預設 no-op，host app bootstrap 時注入真實實作。
3. **檢查 model layer 有沒有 UI helper** — `getColorState(BuildContext)` 之類的方法應該搬到 extension，不要混在資料模型裡。
4. **建 package skeleton + 第一次 `git mv`** — 把已經介面化的 abstraction 移進 package。
5. **批次 `git mv` 業務邏輯** — exceptions → models → parsers → helpers → façade，每批一個 commit，每個檔案是 R rename 不是 modify+add。
6. **更新 consumer，不留 shim** — 把 `lib/pages/`、`lib/widgets/`、`lib/utils/` 等等對 `package:your_app/api/...` 的 import 直接改成 `package:your_crawler/your_crawler.dart`。不要保留 shim 檔，否則 GitHub diff 會充滿假 deletion。
7. **Pure-Dart 測試 + 可選 live test** — `dart test` 跑 hermetic unit；用 `dart_test.yaml` presets 把打真站的 integration test 隔離成 opt-in。

之後你的 package 可以 `dart test` 跑（不用 flutter）、可以拿去 server-side、可以 publish 到 pub.dev、可以給其他 app fork 使用。

---

## 1. 為什麼值得做

| 收益 | 具體狀況 |
|---|---|
| **server-side 重用** | 排程跑爬蟲推 webhook、CI 健檢、報表自動化、Cloud Function |
| **單元測試免 flutter_test** | `dart test` 比 `flutter test` 快很多、CI 容易跑、不需要 widget binding |
| **跨 app 共用** | 同學校 / 同生態系的 second app（例如 iOS native 版）能直接用 |
| **dependency 樹變短** | 主 app 不再 transitively 拉 dio / html / image，size 略降 |
| **架構乾淨** | 模型層強迫脫離 UI、helper 層強迫脫離 Crashlytics 之類橫切點 |

不適用情境：

- 你的「爬蟲」其實只是一個 fetch + json decode，沒幾百行 → 不值得這樣搞
- 你的目標只有 Flutter app，沒有 server-side / CLI / 第二客戶端的需求
- 業務邏輯跟 UI 高度耦合且短期不會變（例如資料抓回來直接餵 widget，沒中間 model）

---

## 2. Pre-flight checklist：開工前的盤點

把以下指令跑一遍，把結果存下來作為改動範圍評估：

```bash
# Flutter SDK 依賴點
grep -rE "^import 'package:flutter/(material|cupertino|widgets|services|foundation)\.dart" lib/api lib/models

# kIsWeb / Platform.is*
grep -rE "kIsWeb|Platform\.is(IOS|Android|MacOS|Windows|Linux|Web)" lib/api lib/models

# rootBundle
grep -rE "rootBundle\.load|PlatformAssetBundle" lib/api lib/models lib/utils

# Firebase / Crashlytics
grep -rE "FirebaseCrashlytics|CrashlyticsUtil|FirebaseAnalytics" lib/api lib/models

# 任何 ApCommonPlugin / 自家 Flutter plugin
grep -rE "ApCommonPlugin|MethodChannel" lib/api lib/models

# image_picker / XFile / file_picker
grep -rE "XFile|ImagePicker|FilePicker" lib/api lib/models

# PreferenceUtil / SharedPreferences / 其他 storage
grep -rE "PreferenceUtil|SharedPreferences|HiveBox|FlutterSecureStorage" lib/api lib/models

# BuildContext / Navigator 在 helper / model 層出現
grep -rE "BuildContext|Navigator\.(push|pop)" lib/api lib/models

# Flutter-only 第三方 plugin（要靠 dart:ui 的，不是真的 pure dart）
# 常見大坑：syncfusion_flutter_pdf、flutter_inappwebview、native_dio_adapter
grep -rE "syncfusion_flutter|flutter_inappwebview|native_dio_adapter|webview_flutter" lib/api lib/models pubspec.yaml
```

每個 hit 都要有對應的處理計畫。沒有 hit 的話，恭喜你。

---

## 3. 建立的抽象介面（cookbook）

我們最後沉澱出 5 個介面，handle 大部分 Flutter 橫切。任何類似專案都會碰到其中至少 3 個。

### 3.1 CrashReporter

幾乎所有 helper / parser 在 catch 裡會直接 `CrashlyticsUtil.recordError(...)`。介面化：

```dart
abstract interface class CrashReporter {
  void recordError(Object error, StackTrace stack, {String? reason});
}

class NoOpCrashReporter implements CrashReporter {
  const NoOpCrashReporter();
  @override
  void recordError(Object error, StackTrace stack, {String? reason}) {}
}
```

Host app 提供 Firebase 版本：

```dart
class FirebaseCrashReporter implements CrashReporter {
  const FirebaseCrashReporter();
  @override
  void recordError(Object error, StackTrace stack, {String? reason}) {
    if (!FirebaseCrashlyticsUtils.isSupported) return;
    CrashlyticsUtil.instance.recordError(error, stack, reason: reason);
  }
}
```

每個 parser / helper 拿一個 `CrashReporter reporter = const NoOpCrashReporter();` 欄位，bootstrap 時 host 換掉。

### 3.2 KeyValueStore

Model 裡的 `save(tag)` / `load(tag)` 通常走 `SharedPreferences` / 你家自己的 PreferenceUtil。介面化：

```dart
abstract interface class KeyValueStore {
  String getString(String key, String fallback);
  void setString(String key, String value);
}

KeyValueStore? _crawlerStorage;

KeyValueStore get crawlerStorage {
  final s = _crawlerStorage;
  if (s == null) {
    throw StateError(
      'crawlerStorage is not configured. '
      'Call configureCrawlerStorage(store) at app startup.',
    );
  }
  return s;
}

void configureCrawlerStorage(KeyValueStore store) {
  _crawlerStorage = store;
}
```

Model 內：

```dart
static const String _prefKey = 'pref_my_data';

void save(String tag) {
  crawlerStorage.setString('${_prefKey}_$tag', toRawJson());
}

static MyData? load(String tag) {
  final raw = crawlerStorage.getString('${_prefKey}_$tag', '');
  return raw.isEmpty ? null : MyData.fromRawJson(raw);
}
```

註：原本散在 main app `Constants.X` 裡的 pref key 字串要 inline 到 model 裡（package 不應該依賴主專案的 Constants 類）。

### 3.3 CaptchaSolver + CaptchaTemplateProvider（如果有 OCR captcha）

```dart
abstract interface class CaptchaSolver {
  Future<String> solve(Uint8List imageBytes);
}

abstract interface class CaptchaTemplateProvider {
  Future<Uint8List> loadTemplate(String char);
}
```

Helper 內：

```dart
CaptchaSolver? captchaSolver;

// 在 login() loop 內：
final solver = captchaSolver;
if (solver == null) {
  throw StateError('captchaSolver not configured');
}
final code = await solver.solve(imageBytes);
```

Host app 端：

```dart
class AssetCaptchaTemplateProvider implements CaptchaTemplateProvider {
  const AssetCaptchaTemplateProvider();
  @override
  Future<Uint8List> loadTemplate(String char) async {
    final data = await rootBundle.load('assets/eucdist/$char.bmp');
    return data.buffer.asUint8List();
  }
}

WebApHelper.instance.captchaSolver =
    EuclideanCaptchaSolver(const AssetCaptchaTemplateProvider());
```

關鍵：演算法（Euclidean distance、CNN 推論等）在 package 裡是 pure Dart；只有「templates 從哪裡來」是 host 注入的。

### 3.4 PdfTextExtractor（如果有 PDF 解析）

我們踩到的坑：`syncfusion_flutter_pdf` 名字看起來 pure（只是 PDF 解析），但 transitively 依賴 `dart:ui`（用 `Rect` / `Offset` 做 bounding box），**裝在 pure-Dart package 裡跑 `dart test` 會 fail**。

解法：抽介面，host app 提供實作。

```dart
abstract interface class PdfTextExtractor {
  String extract(Uint8List bytes);
}

class SyncfusionPdfTextExtractor implements PdfTextExtractor {
  const SyncfusionPdfTextExtractor();
  @override
  String extract(Uint8List bytes) {
    final document = sf.PdfDocument(inputBytes: bytes);
    try {
      return sf.PdfTextExtractor(document).extractText();
    } finally {
      document.dispose();
    }
  }
}
```

### 3.5 onLogout callback（widget cache 之類的清理）

如果 `clearSetting()` / `logout()` 會呼叫 widget plugin（例如 `ApCommonPlugin.clearCourseWidget()`），那是 host app 的責任，不是 crawler 的：

```dart
void Function() onLogout = _noopOnLogout;

static Future<void> clearSetting() async {
  // ... reset state ...
  instance.onLogout();
}

void _noopOnLogout() {}
```

Host：

```dart
Helper.instance.onLogout = () {
  ApCommonPlugin.clearCourseWidget();
  ApCommonPlugin.clearUserInfoWidget();
};
```

---

## 4. Phase plan：建議的 8 階段

每個 phase 是一個 commit（或一小組 commits）。順序很重要，後面的依賴前面的。

### Phase 0 — 在主 repo 內介面化（不搬檔）

- 0.1 解循環依賴（parser ↔ helper、model ↔ helper 等）
- 0.2 把 model 裡的 UI helper（getColorState、l10n-routed string 等）搬到 `lib/extensions/X_ui_extension.dart`
- 0.3 替掉 `kIsWeb` / `Platform.is*` —— 改成 caller 注入 HttpClientAdapter
- 0.4 替掉 `XFile` —— 介面收 `({Uint8List bytes, String filename, String mime})`
- 0.5 抽 `CrashReporter` 介面 —— 把 `CrashlyticsUtil.instance.recordError(...)` 全部換成 `reporter.recordError(...)`
- 0.6 抽 `onLogout` callback —— widget plugin 呼叫從 helper 移到 main bootstrap
- 0.7 抽 `apiHost` 注入 —— `Helper.bootstrap(apiHost: PreferenceUtil.getString(...))`
- 0.8 刪 dead code（特別注意 `BuildContext`-bound 的方法是不是其實沒人 call）

每步 `flutter analyze` + 跑既有 test 確保沒退化。整個 Phase 0 完成時，`lib/api/` 應該已經沒有任何 `import 'package:flutter/material'` / `cupertino` / `widgets` / `services`，也沒有 `Crashlytics` / `ApCommonPlugin` / `XFile` 直接呼叫。

### Phase 1 — Package skeleton + 第一次 `git mv`

```bash
mkdir -p packages/your_crawler/{lib/src/abstractions,test}
# pubspec.yaml: pure Dart, 沒有 flutter SDK 依賴
```

關鍵：**第一個搬進去的東西要用 `git mv`**，否則 git 看不到 rename。例如把 Phase 0.5 創建的 `lib/api/crash_reporter.dart` 搬進去：

```bash
git mv lib/api/crash_reporter.dart packages/your_crawler/lib/src/abstractions/crash_reporter.dart
# 編輯內容（如果需要 import 路徑調整）
git checkout HEAD -- ...  # 或直接 sed
```

新加的 abstraction 介面（CaptchaSolver / KeyValueStore / PdfTextExtractor 之類）就直接 add 進 package（這些是真的新檔，不是 rename）。

### Phase 2 — 純資料 / 介面層搬遷

一個 commit 把 exceptions、session_state、relogin_mixin、cookie_manager、registry、capabilities、models 全部 `git mv` 進 package。**重點是同一個 commit 也要更新所有 consumer 的 import**，不留 shim 檔。

```bash
# 對每組 (old, new):
git mv "$old" "$new"
# 應用內容修改（import 路徑從 your_app → your_crawler）
sed -i '' "s|package:your_app/api/...|package:your_crawler/your_crawler.dart|" "$new"

# 同時更新 consumer
grep -rlE "package:your_app/api/X" lib/pages lib/widgets lib/extensions lib/utils \
  | xargs sed -i '' "s|package:your_app/api/X|package:your_crawler/your_crawler.dart|"
```

### Phase 3 — Parsers

跟 Phase 2 同模式，搬全部 parser。

### Phase 4 — Helpers + façade

helper.dart 是最大的，可能還有 `BuildContext`-bound 的 extension（例如 `GeneralResponseExtension.getGeneralMessage(BuildContext)`）—— 這個 extension 留主 app（裡面用 l10n / theme），但 helper 本體搬走。

### Phase 5 — Captcha / 其他二進位處理

如果有 captcha OCR / PDF 解析等需要 asset 的：抽 `*TemplateProvider` / `*Extractor`，演算法搬 package，asset loader 留 host。

### Phase 6 — Bootstrap

寫一個 `bootstrapCrawler()` 函式集中所有 wiring（CrashReporter、KeyValueStore、CaptchaSolver、PdfTextExtractor、onLogout、platform adapter、apiHost）。`main.dart` 啟動只多一行：

```dart
await PreferenceUtil.init(...);
bootstrapCrawler();
runApp(MyApp());
```

### Phase 7 — Pure-Dart unit test + opt-in live test

見 §6。

---

## 5. Git rename 機制：兩個關鍵規則

### 規則 1：`modify + add` 不會被偵測為 rename

最常見的錯：
```bash
# ❌ 這樣 git 看不到 rename
cp lib/api/foo.dart packages/your_crawler/lib/src/foo.dart
echo "export '...';" > lib/api/foo.dart  # 改成 shim
git add -A
git commit
```

Git 看到的是：`lib/api/foo.dart` 被 modify 成 1 行，`packages/.../foo.dart` 被 add。Git 的 rename detection 只看 `delete + add` 配對，不看 `modify + add`。`git log` 預設、GitHub blame、`git log --diff-filter=R` 都看不到 rename。

正確做法：
```bash
# ✅ 這樣會被偵測為 rename
git mv lib/api/foo.dart packages/your_crawler/lib/src/foo.dart
sed -i '' 's|package:your_app|package:your_crawler|' packages/your_crawler/lib/src/foo.dart
# 不在這個 commit 創建 lib/api/foo.dart 的 shim
git commit
```

如果你 *一定* 要保留 shim（例如不想一次改一堆 consumer），就分兩個 commit：第一個是 `git mv`、第二個再 add shim。

### 規則 2：consumer 不要等到最後才更新

Consumer（lib/pages、lib/widgets 等）的 import 越早改成 `package:your_crawler/...`，shim 越早可以省掉。**如果 shim 從來沒被創建過，git 看到的就是純 R rename，沒有「修改成 1 行」的雜訊**。

這個我們來回試了三次：
1. 第一輪：用 modify + add 做 shim → 40+ 個 R 變不見
2. 第二輪：split commit (move + 後面再 add shim) → R 出現了，但 PR diff 多了 8 個 shim-only commit
3. 第三輪：consumer 直接 import package + 不留 shim → 最乾淨，~30 commits 結尾，63 個 R rename

第三輪是正解。

### 額外：跨檔名 rename（filename A → filename B）的相似度門檻

我們有一個 `lib/utils/captcha_utils.dart` → `packages/.../captcha/captcha_solver_impl.dart` 的搬動。內容變太多（從 `class CaptchaUtils._() static method` 改寫成 `class EuclideanCaptchaSolver implements CaptchaSolver`），git 的相似度算下來 < 20%，**即使用 `git mv` 也不會被識別為 rename**。

如果這個檔案 history 對你重要，分兩個 commit：
1. 先 `git mv` rename（內容不變）
2. 再 commit content rewrite（modify）

如果不重要（例如只是個 utility），就接受 `delete + add` 是誠實的紀錄。

---

## 6. 測試策略

### 6.1 Hermetic unit test（package 內，不用 Flutter）

```dart
// packages/your_crawler/test/abstractions_test.dart
import 'package:your_crawler/your_crawler.dart';
import 'package:test/test.dart';

void main() {
  test('NoOpCrashReporter swallows errors silently', () {
    const reporter = NoOpCrashReporter();
    expect(
      () => reporter.recordError(Exception('boom'), StackTrace.current),
      returnsNormally,
    );
  });
}
```

跑：`cd packages/your_crawler && dart test`

如果你的 package 有用到 asset（例如 captcha templates），用 `FileSystemTemplateProvider` 從 disk 讀，繞過 `rootBundle`：

```dart
class FileSystemTemplateProvider implements CaptchaTemplateProvider {
  FileSystemTemplateProvider(this.directory);
  final Directory directory;
  @override
  Future<Uint8List> loadTemplate(String char) =>
      File('${directory.path}/$char.bmp').readAsBytes();
}
```

### 6.2 Live integration test（打真站）

用 `dart_test.yaml` 把 live test 隔離成 opt-in preset：

```yaml
exclude_tags: "live || live-anonymous"

presets:
  live:
    exclude_tags: "__never__"
  live-anonymous:
    exclude_tags: "__never__"
    include_tags: "live-anonymous"

tags:
  live:
  live-anonymous:
  __never__:
```

Test 檔頂端：

```dart
@Tags(<String>['live'])
@TestOn('vm')
library;
```

跑：
```bash
# 預設不跑
dart test

# 只跑無帳密的
dart test -P live-anonymous

# 全部 live test（讀 env vars）
USERNAME=... PASSWORD=... dart test -P live -r expanded
```

`-r expanded` 讓 `print()` 輸出 inline 顯示，方便看每一步打了哪個 endpoint、回什麼。

帳密讀 env：
```dart
final username = Platform.environment['NKUST_USER'] ?? '';
final hasCreds = username.isNotEmpty;
test('...', () {...},
  skip: hasCreds ? false : 'NKUST_USER not set');
```

### 6.3 主 app 的 `flutter test`

主 app 的 test 也得改 import 路徑（從 `package:your_app/api/...` → `package:your_crawler/your_crawler.dart`）。fixture 檔案（assets_test/）通常不變。

---

## 7. Force-push 與 rebase 的決策

要不要 rewrite history 取決於：

| 狀況 | 建議 |
|---|---|
| Branch 還沒 review、沒人在上面開 sub-branch | 力推 force-push 整理乾淨 |
| 已經 review 中 / 有 reviewer comment | 不要 rewrite，新增「fixup」commit 即可，最後 squash |
| Branch 是 protected / 有 CI artifact 綁住 commit hash | 完全不能 rewrite |

決定 force-push 的話：

```bash
# 永遠先存 backup
git branch refactor/X-backup

# 重做完
git push --force-with-lease  # 不要用 --force，會吞掉別人 push 的東西
```

我們做了三輪 rewrite：第一輪原始實作、第二輪 split commit 修 rename、第三輪移除 shim。每輪都先 branch 一個 backup。

---

## 8. 我們踩到的具體坑（避免重複）

| 坑 | 解法 |
|---|---|
| `kDebugMode` 來自 `flutter/foundation` | 自己寫個 `build_mode.dart` 用 `bool.fromEnvironment('dart.vm.product')` |
| `native_dio_adapter` 是 Flutter plugin（用 NSURLSession） | `ApiConfig.platformAdapterFactory = NativeAdapter.new` 由 host 注入 |
| `syncfusion_flutter_pdf` 名字看起來 pure 但要 `dart:ui` | 抽 `PdfTextExtractor` 介面 |
| Model 裡有 `getColorState(BuildContext)` 之類 UI helper | 搬到 `lib/extensions/X_ui_extension.dart` |
| `XFile` 從 `image_picker` 帶進 helper signature | 改用 `({Uint8List bytes, String filename, String mime})` |
| `BuildContext` 在 helper.login 出現（Navigator.push webview） | 整個 method 移出 helper，host 端寫 `LoginCoordinator.show(context)` 拿 cookies 後注回 |
| `lib/api/foo.dart` 在 git 看到是 modify 不是 rename | 用 `git mv` + 不創建 shim（或 split 兩個 commit） |
| Cross-name rename 相似度太低 | 若 history 重要：split 兩個 commit；不重要就接受 D+A |
| `flutter test` 從 repo root 跑會撈到 package 的 test | `flutter test test/` 限定路徑 |
| `git rebase -i` 跨 merge commit 麻煩 | 用 `--rebase-merges` 或乾脆 `git reset --hard master` 重來 |
| 跑 build_runner 生成的 `.g.dart` 文件搬 package 後找不到 part | 把 `.dart` + `.g.dart` 一起 `git mv`（兩個都會被識別 R100） |

---

## 9. 落地後的形狀（成功標準）

跑這幾個指令，如果都過了，抽取成功：

```bash
# 1. Package 自己能跑（pure Dart）
cd packages/your_crawler
dart pub get
dart analyze   # 0 errors
dart test      # 全綠

# 2. 主 app 還在跑
cd ../..
flutter analyze lib/   # 0 errors
flutter test test/     # 全綠

# 3. 主 app 啟動 + 走過幾個關鍵 flow（手動 / e2e）
flutter run

# 4. PR diff 大部分是 R rename
git -c diff.renames=true log --diff-filter=R --format='%h' BASE..HEAD \
  | xargs -I{} git -c diff.renames=true show --diff-filter=R --name-only --format= {} \
  | wc -l
# 期待數字 > 主要 phase × 平均檔案數（我們 5 個 phase × ~12 = 預期 > 50）
```

`lib/api/` 應該幾乎清空，只留 host-only 的東西（l10n message mapping、Flutter UI 包裝等）。

---

## 10. 開工 checklist（複製去用）

開新 PR 前確認：

- [ ] 已開 backup branch
- [ ] Phase 0 清完所有 Flutter 橫切（grep 七個指令都沒 hit）
- [ ] 抽好 5 個 abstraction（CrashReporter、KeyValueStore、CaptchaSolver、CaptchaTemplateProvider、PdfTextExtractor，視情況增減）
- [ ] Model 已經沒有 `BuildContext` 參數
- [ ] Package pubspec **沒有** `flutter:` SDK section
- [ ] Package pubspec 沒有 `syncfusion_flutter_*`、`flutter_inappwebview`、`native_dio_adapter`、`image_picker` 等 Flutter-only 依賴
- [ ] `dart test` 在 package 目錄能跑（不需要 `flutter` 命令）
- [ ] consumer（pages、widgets）的 import 都是 `package:your_crawler/...`，不是 `package:your_app/api/...`
- [ ] `lib/api/`、`lib/models/` 幾乎清空
- [ ] `dart_test.yaml` 把 live test 隔離成 opt-in
- [ ] PR description 列出 R rename 數、phase 結構、保留的 host-only 檔案

---

## 附錄：實際的 phase 順序（nkust_crawler 案例）

供對照：

```
Phase 0.1  解 parser→helper 循環 import
Phase 0.2  bus model UI helper 搬到 extension
Phase 0.3  kIsWeb / Platform.is* 注入
Phase 0.4  XFile → bytes tuple
Phase 0.5  CrashReporter 介面化
Phase 0.6  onLogout callback
Phase 0.7  apiHost 注入
Phase 0.8  drop dead BuildContext code
[merge master]
Phase 1    Package skeleton + git mv crash_reporter
Phase 2    git mv data layer (exceptions/session/registry/capabilities/models)
Phase 3    git mv parsers + build_mode shim
Phase 4    git mv helpers + facade + CaptchaSolver/PdfTextExtractor seams
Phase 5    git mv captcha (eucdist + utils→solver_impl)
Phase 6    bootstrapCrawler() 集中 wiring
Phase 7    tests + post-fix + live integration test
```

最終結果：32 commits、63 個 R rename、`lib/api/` 只剩 1 個 Flutter-bound l10n 檔。

完整紀錄見 `docs/crawler-package-migration-plan.md`（這次案例專屬）以及 git log 上每個 phase 的 commit message。
