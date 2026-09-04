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
  Future<ZuvioSession> login({
    required String email,
    required String password,
  }) async {
    await cookieJar.deleteAll();
    _session = null;

    final String account =
        email.contains('@') ? email.trim() : '${email.trim()}@nkust.edu.tw';

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

    return _refreshSession();
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

  void logout() {
    _session = null;
    cookieJar.deleteAll();
  }

  /// GET an HTML page, returning its body.
  Future<String> getHtml(String path, {Map<String, dynamic>? headers}) async {
    final Response<dynamic> res = await _guard(
      () => dio.get<dynamic>(
        path,
        options: headers == null ? null : Options(headers: headers),
      ),
    );
    return res.data?.toString() ?? '';
  }

  /// POST to an `app_v2/*` JSON endpoint. [data] is merged with the
  /// session's `user_id` + `accessToken`.
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> data,
  ) async {
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
    return _decode(res.data);
  }

  /// GET a JSON endpoint (`course/listStudentFullCourses` etc.) with the
  /// session tokens as query parameters.
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
  }) async {
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
    return _decode(res.data);
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
