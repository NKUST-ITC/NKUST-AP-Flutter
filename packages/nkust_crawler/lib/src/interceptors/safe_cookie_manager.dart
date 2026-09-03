import 'dart:developer';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

/// Drop-in replacement for [PrivateCookieManager] that survives the
/// non-RFC `Set-Cookie` headers webap occasionally emits.
///
/// Specifically, webap ships responses where two cookies got
/// concatenated into one `Set-Cookie` header value with a comma
/// separator instead of being split into two separate headers. e.g.:
///
/// ```text
/// Set-Cookie: name=val; Path=/; Max-Age=3600,jsessionid=aaakmp…
/// ```
///
/// [PrivateCookieManager] (and the dart:io stdlib parser it copies
/// from) treat `;` as the only attribute terminator, so it slurps the
/// entire tail starting at `3600` into the `Max-Age` value and then
/// `int.parse` throws `FormatException`, killing the whole interceptor
/// chain. That bubbles up as `NetworkException` on the Dio side and
/// the user sees a "no network" toast on a perfectly good login
/// response — exactly the symptom we hit:
///
///     Unhandled Exception: NetworkException(5000): FormatException:
///       Invalid radix-10 number (at character 3)
///     3600,jsessionid=aaakmpr9y1lhidnpzaqeqa
///       ^
///
/// This class pre-splits each `Set-Cookie` value at any comma that
/// looks like a cookie boundary (i.e. the comma is followed by an
/// optional space and then `<name>=`, where `<name>` contains no `=`,
/// `;` or `,`). Commas inside `Expires=Wed, 09 Jun 2021 …` dates do
/// not match because `09 Jun …` has no `=` before the next attribute
/// terminator, so they pass through unchanged.
///
/// As defence-in-depth we also `try`/`catch` per cookie, log + skip
/// the malformed one instead of failing the whole batch — losing one
/// cookie is worse than losing all of them.
class SafeCookieManager extends Interceptor {
  SafeCookieManager(this.cookieJar);

  final CookieJar cookieJar;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    _attachCookies(options).whenComplete(() => handler.next(options));
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _saveCookiesSafely(response).whenComplete(() => handler.next(response));
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      _saveCookiesSafely(err.response!).whenComplete(() => handler.next(err));
    } else {
      handler.next(err);
    }
  }

  Future<void> _attachCookies(RequestOptions options) async {
    try {
      final List<Cookie> cookies = await cookieJar.loadForRequest(options.uri);
      if (cookies.isEmpty) return;
      // dart:io Cookie.toString() emits the full Set-Cookie form
      // (with Path/Expires/etc.), which is wrong for outbound Cookie
      // headers — servers only want `name=value; name=value`.
      options.headers[HttpHeaders.cookieHeader] =
          cookies.map((Cookie c) => '${c.name}=${c.value}').join('; ');
    } catch (e) {
      log('[cookie] loadForRequest failed: $e');
    }
  }

  Future<void> _saveCookiesSafely(Response<dynamic> response) async {
    final List<String>? rawHeaders =
        response.headers[HttpHeaders.setCookieHeader];
    if (rawHeaders == null || rawHeaders.isEmpty) return;

    final List<Cookie> cookies = <Cookie>[];
    for (final String raw in rawHeaders) {
      for (final String segment in splitMalformedSetCookie(raw)) {
        try {
          cookies.add(Cookie.fromSetCookieValue(segment));
        } catch (e) {
          log('[cookie] skip malformed Set-Cookie segment: '
              '${_preview(segment)} ($e)');
        }
      }
    }

    if (cookies.isEmpty) return;
    try {
      await cookieJar.saveFromResponse(response.requestOptions.uri, cookies);
    } catch (e, st) {
      log('[cookie] saveFromResponse failed: $e\n$st');
    }
  }

  static String _preview(String s) =>
      s.length > 80 ? '${s.substring(0, 80)}…' : s;
}

/// Splits a `Set-Cookie` header value at any comma that is immediately
/// followed by `<optional space><name>=`, treating that comma as a
/// cookie boundary. Commas within `Expires=Wed, 09 Jun 2021 …` dates
/// are left intact because the substring after them never reaches a
/// `=` before the next `;`.
///
/// Public for unit testing; callers in this file should still go
/// through [SafeCookieManager].
List<String> splitMalformedSetCookie(String raw) {
  final List<String> out = <String>[];
  int start = 0;
  for (int i = 0; i < raw.length; i++) {
    if (raw[i] != ',') continue;
    int j = i + 1;
    while (j < raw.length && raw[j] == ' ') {
      j++;
    }
    // Read potential cookie name characters until we hit `=`, `;`,
    // another `,` or whitespace.
    int nameEnd = j;
    while (nameEnd < raw.length) {
      final String c = raw[nameEnd];
      if (c == '=' || c == ';' || c == ',' || c == ' ') break;
      nameEnd++;
    }
    if (nameEnd > j && nameEnd < raw.length && raw[nameEnd] == '=') {
      out.add(raw.substring(start, i));
      start = j;
    }
  }
  out.add(raw.substring(start));
  return out;
}
