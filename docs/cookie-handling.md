# Cookie 處理與 RFC 合規性

> 對應實作：`lib/api/safe_cookie_manager.dart`
> 修復脈絡：#411 / #412

這份文件解釋為什麼專案有自己的 `SafeCookieManager` 而不直接用 `dio_cookie_manager` 的 `CookieManager`，並順便當作對讀 codebase 的學弟妹的 cookie 入門。

## TL;DR

- **學校 webap server 偶爾送出非 RFC 的 `Set-Cookie` header**（把多支 cookie 用逗號黏成一個 header value）
- **標準 cookie parser 遇到這種輸入會 throw `FormatException`**，整條 interceptor 鏈陣亡，使用者看到「沒有網路」吐司
- **`SafeCookieManager` 在丟給標準 parser 前先做防禦性切分**，並對每支 cookie 做 try/catch，壞掉一支不會連累整批
- **背後的工程原則是 Postel's Law**：「送的時候嚴格、收的時候寬容」

## 1. RFC 怎麼說

### `Set-Cookie` header（server → client）

RFC 6265 §3 + RFC 7230 §3.2.2 定義：

> 多個 cookie **必須以多筆獨立的 `Set-Cookie:` header line** 送出，
> **不可以**用逗號折疊（folding）成單一 header value。

合規範例：

```http
HTTP/1.1 200 OK
Set-Cookie: a=1; Path=/
Set-Cookie: b=2; Path=/; HttpOnly
```

不合規範例（webap 偶爾這樣做）：

```http
HTTP/1.1 200 OK
Set-Cookie: a=1; Path=/; Max-Age=3600,b=2; Path=/; HttpOnly
                                     ^^ RFC 明文禁止
```

### 為什麼 RFC 要明文禁止逗號折疊？

因為 **逗號可以合法出現在 cookie 屬性內**：

```
Set-Cookie: sid=xyz; Expires=Wed, 09 Jun 2021 10:18:14 GMT; Path=/
                            ^^^
                            這個逗號是 HTTP-date 格式的一部分
```

如果允許用逗號折疊多個 cookie，就**無法可靠地分辨**哪個逗號是 cookie 邊界、哪個是日期格式的一部分。RFC 因此一刀切禁止。`Set-Cookie` 也是 RFC 7230 §3.2.2 對「同名 header 必須能用逗號合併」這條規則**唯一明文列出的例外**。

### `Cookie` header（client → server）

相對單純，RFC 6265 §5.4：

```http
GET /something HTTP/1.1
Cookie: a=1; b=2; c=3
```

- `name=value` 用 `; ` 分隔
- 全部塞進**單一** `Cookie:` header
- 不送 `Path` / `Domain` / `Expires` 等屬性（那些是 server 才會用的）

`SafeCookieManager.onRequest` 與其他手動拼 cookie header 的地方（例如 `nkust_helper.dart` 用 `package:http` 的部分）都遵守這格式。

## 2. webap 的非合規行為

實際抓到的 Set-Cookie：

```
Set-Cookie: name=val; Path=/; Max-Age=3600,jsessionid=aaakmpr9y1lhidnpzaqeqa
```

兩個 cookie（`name`、`jsessionid`）違規地用逗號黏在同一個 header value 裡。

### 標準 parser 看到這串會發生什麼

`dart:io` 的 `Cookie.fromSetCookieValue` 嚴格按 RFC，把 `;` 當屬性分隔符：

1. 切出 cookie pair：`name=val`
2. 屬性 1：`Path=/`
3. 屬性 2：`Max-Age=3600,jsessionid=aaakmpr9y1lhidnpzaqeqa`
4. 對 Max-Age 屬性的值做 `int.parse('3600,jsessionid=...')` → 💥 `FormatException`

```mermaid
sequenceDiagram
    participant App
    participant Dio
    participant CookieMgr as PrivateCookieManager
    participant Parser as Cookie.fromSetCookieValue
    participant ErrIntcp as ErrorInterceptor

    App->>Dio: dio.post(perchk.jsp)
    Dio-->>App: 200 OK + Set-Cookie: a=1; Max-Age=3600,b=2
    Dio->>CookieMgr: onResponse(response)
    CookieMgr->>Parser: parse("a=1; Max-Age=3600,b=2")
    Parser-->>CookieMgr: 💥 FormatException
    CookieMgr-->>Dio: rethrow
    Dio->>ErrIntcp: onError(...)
    ErrIntcp-->>App: NetworkException(5000) "沒有網路"
    Note over App: UI 顯示假性網路錯誤<br/>但登入其實成功了
```

## 3. SafeCookieManager 的設計

### 策略

在丟進標準 parser **之前**，先把可疑的逗號折疊切開：

```dart
List<String> splitMalformedSetCookie(String raw) {
  // 找到 `,<optional space><name>=` 模式的逗號當 cookie 邊界。
  // Expires 日期裡的 `, 09 Jun 2021` 因為 `09 Jun` 後面遇到 ` `
  // 而非 `=`，所以不會被當邊界 — 安全。
}
```

### 三層職責

```dart
class SafeCookieManager extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // (1) 從 jar 載出符合 uri 的 cookie，拼成 Cookie header 送出去
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // (2) 收到回應，先 splitMalformedSetCookie 再解析
    // (3) 對每支 cookie try/catch 確保壞掉一支不會連累整批
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 如果錯誤回應裡也帶了 Set-Cookie，照樣存（很多 server 在 4xx 也 set 新 session）
  }
}
```

### 為什麼這樣不算「自己違反 RFC」

**Robustness Principle / Postel's Law**（RFC 1958 §3.9）：

> Be conservative in what you do, be liberal in what you accept from others.
> 送出時嚴格按標準，接收時對對方違規盡量寬容。

對應到本實作：
- **送出**：`Cookie:` header 完全按 RFC 6265 §5.4 拼，沒有自創格式
- **接收**：對 server 違規輸入做 best-effort 復原，**但不主動產生違規格式**

我們沒有「發明非標準格式」，只是讓 client 在收到違規輸入時不崩。這跟瀏覽器行為一致——Chrome、Firefox 都會盡量解析破格 cookie，否則整個 web 就會被某些破爛 server 弄到不能用。

## 4. 常見坑（讀 codebase 的人請注意）

### Cronet vs Dio cookieJar

App 在 Android 透過 `native_dio_adapter` 走 Cronet，iOS / macOS 走 URLSession。這些 native HTTP stack 自己也有 cookie 機制。

**目前約定**：cookie 全部由 Dio 的 `SafeCookieManager` 管，native stack 的 cookie store 預設應為 disabled（Cronet 的 CookieManager 預設就不啟用）。如果哪天遇到「Dio jar 看到的 cookie 跟實際發出去的對不上」這種詭異現象，**第一個檢查這條**。

### 手動拼 `Cookie:` header（e.g. `nkust_helper.dart`）

部分 helper 用 `package:http`（不是 Dio），手動從 jar 載 cookie 拼進 `Cookie:` header：

```dart
final String cookieHeader = cookies
    .map((Cookie c) => '${c.name}=${c.value}')
    .join('; ');
```

**這格式是合規的**，符合 RFC 6265 §5.4。但要注意兩個雷：

1. 用的是 `${c.name}=${c.value}`，**不是** `c.toString()`——後者輸出完整的 Set-Cookie 格式（含 Path/Expires/HttpOnly），那是 server → client 用的格式，反向送會讓 server 解不出來
2. Path/Domain/Expires 的過濾要靠 `cookieJar.loadForRequest(uri)` 幫你篩，不能 `loadAll` 全送（會把不符合 path 的 cookie 也送出去，可能洩漏資訊或讓 server 困惑）

### 為什麼 `dart:io` 的 `Cookie.toString()` 不能直接放進 `Cookie:` header

`Cookie.toString()` 輸出的是 **Set-Cookie** 格式：

```
JSESSIONID=abc123; Path=/; HttpOnly; Expires=Wed, 09 Jun 2021 10:18:14 GMT
```

那是 server → client 用的。Client → server 的 `Cookie:` header 只要：

```
JSESSIONID=abc123
```

混用 = 送出去的 header 包含 server 永遠不會懂的 `Path=/; HttpOnly; Expires=...`，server 可能整支 cookie 直接拒收。

## 5. 測試

`test/safe_cookie_manager_test.dart` 覆蓋 `splitMalformedSetCookie` 的行為：

| 測試 | 驗證 |
|---|---|
| `Max-Age=N,name=val` | 切成兩段，各自能 round-trip 過 `Cookie.fromSetCookieValue` |
| `Expires=Wed, 09 Jun 2021 …` | **不切**（日期內的逗號保留） |
| 純 RFC 合規的 `a=1; Path=/` | 不變動 |
| 三個 cookie 用兩個逗號黏 | 切成三段 |
| Trailing 逗號（後面沒有 `name=`）| 不切 |

跑：

```bash
fvm flutter test test/safe_cookie_manager_test.dart
```

## 6. 給未來維護者的建議

如果哪天又遇到「登入莫名其妙失敗」，依本次踩雷經驗，按代價排除順序：

1. **抓 cURL 跟現有實作對比 header**——Referer / Origin / User-Agent / Cookie
2. **看 server 真正回了什麼 HTML**（不是看包過的 Exception 訊息）——webap 的錯誤訊息常藏在 `<script>alert(...)</script>` 裡
3. **檢查 cookie 流向**——validateCode.jsp 拿到的 JSESSIONID 是否真的有跟著 perchk.jsp 送出去？interceptor 有沒有同時實作 `onRequest` 和 `onResponse`？
4. **預熱 session**——很多 JSP 系統的 captcha / CSRF token 是綁在 homepage 載入時 set 的 cookie 上，直接跳到子頁面不會綁

## 參考

- [RFC 6265 — HTTP State Management Mechanism](https://datatracker.ietf.org/doc/html/rfc6265)
- [RFC 7230 §3.2.2 — Field Order](https://datatracker.ietf.org/doc/html/rfc7230#section-3.2.2)
- [RFC 1958 §3.9 — Robustness Principle](https://datatracker.ietf.org/doc/html/rfc1958#section-3.9)
- 修復脈絡：#411 / #412
- 爬蟲整體架構：[crawler-architecture.md](./crawler-architecture.md)
