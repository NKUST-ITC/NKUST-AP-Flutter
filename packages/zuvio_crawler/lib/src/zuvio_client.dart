import 'dart:convert';
import 'dart:io' show HttpHeaders;

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import 'package:zuvio_crawler/src/models/models.dart';
import 'package:zuvio_crawler/src/parsers/session_parser.dart';
import 'package:zuvio_crawler/src/zuvio_exception.dart';

/// Owns the HTTP transport + cookie jar for one Zuvio session and knows
/// how to log in. Everything above it (helpers, parsers) is stateless.
class ZuvioClient {
  ZuvioClient({Dio? dio, CookieJar? cookieJar})
      : cookieJar = cookieJar ?? CookieJar(),
        dio = dio ?? Dio() {
    this.dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 30)
      ..followRedirects = true
      ..responseType = ResponseType.plain
      ..headers[HttpHeaders.userAgentHeader] = _userAgent
      ..validateStatus = ((int? code) => code != null && code < 500);
    this.dio.interceptors.add(CookieManager(this.cookieJar));
  }

  static const String baseUrl = 'https://irs.zuvio.com.tw/';

  static const String _userAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15';

  final Dio dio;
  final CookieJar cookieJar;

  ZuvioSession? _session;
  String? _account;
  String? _password;
  Future<ZuvioSession>? _loginInFlight;

  /// Bumped by [logout]. A [_login] attempt that started before a
  /// [logout] call checks this after its network round-trip and, if it
  /// no longer matches, discards its result instead of resurrecting a
  /// session the caller explicitly asked to end — otherwise a slow
  /// login racing a logout (e.g. switching the campus account while
  /// Zuvio auto-login is still in flight) could leave the next person to
  /// open the app looking at the previous user's Zuvio session.
  int _epoch = 0;

  ZuvioSession get session {
    final ZuvioSession? s = _session;
    if (s == null) {
      throw const ZuvioSessionExpiredException('not logged in');
    }
    return s;
  }

  bool get isLogin => _session != null;

  /// Logs in and captures the session tokens from the landing page.
  /// Zuvio has no captcha. A bare NKUST student id (no `@`) is expanded
  /// to `<id>@nkust.edu.tw`.
  ///
  /// Concurrent callers (e.g. two pages that both notice the session
  /// expired at once) share a single in-flight attempt instead of each
  /// wiping the cookie jar out from under the other, which would leave
  /// one of them retrying against a session that was never actually
  /// established.
  Future<ZuvioSession> login({
    required String email,
    required String password,
  }) {
    final Future<ZuvioSession>? inFlight = _loginInFlight;
    if (inFlight != null) return inFlight;
    final Future<ZuvioSession> attempt =
        _login(email: email, password: password);
    _loginInFlight = attempt;
    return attempt.whenComplete(() => _loginInFlight = null);
  }

  Future<ZuvioSession> _login({
    required String email,
    required String password,
  }) async {
    final int epoch = _epoch;
    await cookieJar.deleteAll();
    _session = null;

    final String account =
        email.contains('@') ? email.trim() : '${email.trim()}@nkust.edu.tw';
    _account = account;
    _password = password;

    final Response<dynamic> res = await _guard(
      () => dio.post<dynamic>(
        'irs/submitLogin',
        data: <String, String>{
          'email': account,
          'password': password,
          'encoded_password': base64.encode(utf8.encode(password)),
          'current_language': 'zh-TW',
          'back_url': '',
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: <String, String>{
            'Referer': '${baseUrl}irs/login',
            'Origin': 'https://irs.zuvio.com.tw',
          },
        ),
      ),
    );

    final String body = res.data?.toString() ?? '';
    if (body.contains('id="myform"') || body.contains('submitLogin')) {
      throw const ZuvioAuthException('帳號或密碼錯誤');
    }

    final ZuvioSession session = await _refreshSession();
    if (epoch != _epoch) {
      // logout() ran while this attempt was in flight; don't let a slow
      // login resurrect a session after the caller asked to end one.
      _session = null;
      throw const ZuvioSessionExpiredException('logged out mid-login');
    }
    return session;
  }

  /// Re-scrapes [ZuvioSession] from a known logged-in page. Called after
  /// login and whenever a JSON call reports the token is stale.
  Future<ZuvioSession> _refreshSession() async {
    final Response<dynamic> res =
        await _guard(() => dio.get<dynamic>('student5/irs/allCourses'));
    final String body = res.data?.toString() ?? '';
    final ZuvioSession? parsed = parseSession(body);
    if (parsed == null) {
      throw const ZuvioSessionExpiredException();
    }
    _session = parsed;
    return parsed;
  }

  /// Hits `irs/logout` so Zuvio drops the server-side session too, then
  /// clears the local session, cached credentials and cookie jar. The
  /// network call is best-effort — the local state is cleared even if it
  /// fails.
  Future<void> logout() async {
    // Invalidate any login() attempt already in flight before we touch
    // anything else — see the [_epoch] doc comment.
    _epoch++;
    try {
      await dio.get<dynamic>(
        'irs/logout',
        options: Options(followRedirects: false),
      );
    } catch (_) {
      // Ignore: the local wipe below is what matters for the user.
    }
    _session = null;
    _account = null;
    _password = null;
    await cookieJar.deleteAll();
  }

  /// Zuvio silently redirects an expired session back to the login form
  /// instead of returning an auth error, so we sniff the body for it.
  bool _isLoginPage(String body) =>
      body.contains('id="myform"') || body.contains('irs/submitLogin');

  /// Runs [attempt]; if it reports the session went stale, logs back in
  /// once with the cached credentials and retries.
  Future<T> _retryOnExpiry<T>(Future<T> Function() attempt) async {
    try {
      return await attempt();
    } on ZuvioSessionExpiredException {
      final String? account = _account;
      final String? password = _password;
      if (account == null || password == null) rethrow;
      await login(email: account, password: password);
      return attempt();
    }
  }

  /// Zuvio funnels attachment downloads through `tool/downloadImg` rather
  /// than exposing the storage bucket directly.
  String proxyDownloadUrl(String fileUrl, String name) {
    final int dot = name.lastIndexOf('.');
    final String base = dot > 0 ? name.substring(0, dot) : name;
    return '${baseUrl}tool/downloadImg/'
        '?user_id=${Uri.encodeComponent(session.userId)}'
        '&accessToken=${Uri.encodeComponent(session.accessToken)}'
        '&file_url=${Uri.encodeComponent(fileUrl)}'
        '&file_name=${Uri.encodeComponent(base)}'
        '&origin_name=${Uri.encodeComponent(name)}';
  }

  /// Downloads bytes for a URL built by [proxyDownloadUrl] using this
  /// session's own client. The URL carries `user_id` + `accessToken` in
  /// its query string, so routing the download through here — instead of
  /// handing that URL to an external browser or share sheet — keeps the
  /// token out of browser history and Referer headers.
  ///
  /// [url] must resolve to Zuvio's own host: this method attaches the
  /// live session's tokens to whatever request it's given (via
  /// [proxyDownloadUrl]'s query string, already baked into [url] by the
  /// time it gets here), so it must never be reachable with a caller- or
  /// data-controlled host — that would turn an attachment download into
  /// a way to fire an authenticated, token-bearing request anywhere.
  Future<List<int>> downloadBytes(String url) async {
    final String host = Uri.parse(url).host;
    final String expectedHost = Uri.parse(baseUrl).host;
    if (host != expectedHost) {
      throw ZuvioException('refused to download from unexpected host: $host');
    }
    final Response<List<int>> res = await _guard(
      () => dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      ),
    );
    return res.data ?? const <int>[];
  }

  /// GET an HTML page, returning its body.
  Future<String> getHtml(String path, {Map<String, dynamic>? headers}) {
    return _retryOnExpiry(() async {
      final Response<dynamic> res = await _guard(
        () => dio.get<dynamic>(
          path,
          options: headers == null ? null : Options(headers: headers),
        ),
      );
      final String body = res.data?.toString() ?? '';
      if (_isLoginPage(body)) throw const ZuvioSessionExpiredException();
      return body;
    });
  }

  /// POST to an `app_v2/*` JSON endpoint. [data] is merged with the
  /// session's `user_id` + `accessToken`.
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> data,
  ) {
    return _retryOnExpiry(() async {
      final Response<dynamic> res = await _guard(
        () => dio.post<dynamic>(
          path,
          data: <String, dynamic>{
            'user_id': session.userId,
            'accessToken': session.accessToken,
            ...data,
          },
          options: Options(contentType: Headers.formUrlEncodedContentType),
        ),
      );
      final String raw = res.data?.toString() ?? '';
      if (_isLoginPage(raw)) throw const ZuvioSessionExpiredException();
      return _decode(res.data);
    });
  }

  /// GET a JSON endpoint (`course/listStudentFullCourses` etc.) with the
  /// session tokens as query parameters.
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
  }) {
    return _retryOnExpiry(() async {
      final Response<dynamic> res = await _guard(
        () => dio.get<dynamic>(
          path,
          queryParameters: <String, dynamic>{
            'user_id': session.userId,
            'accessToken': session.accessToken,
            ...?query,
          },
        ),
      );
      final String raw = res.data?.toString() ?? '';
      if (_isLoginPage(raw)) throw const ZuvioSessionExpiredException();
      return _decode(res.data);
    });
  }

  Map<String, dynamic> _decode(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    final Object? parsed = jsonDecode(data.toString());
    if (parsed is Map<String, dynamic>) return parsed;
    throw const ZuvioException('unexpected non-object JSON response');
  }

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        throw ZuvioException(
          'zuvio server error ${e.response?.statusCode}',
          cause: e,
        );
      }
      throw ZuvioNetworkException(e.message ?? 'network error', cause: e);
    }
  }
}
