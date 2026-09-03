import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:nkust_crawler/src/config/api_config.dart';
import 'package:nkust_crawler/src/exceptions/api_exception.dart';
import 'package:nkust_crawler/src/models/student_id_query_result.dart';
import 'package:nkust_crawler/src/parsers/stdsys_parser.dart';
import 'package:sprintf/sprintf.dart';

/// Student-id lookup against `stdsys.nkust.edu.tw/student/QueryStudentId`.
///
/// The page is gated by Cloudflare Turnstile, whose token can only be minted
/// by a real browser engine — the host app runs a WebView for that part and
/// passes the token in. Everything else is a plain form POST done here.
///
/// The Turnstile token is deliberately the *only* thing that crosses over
/// from the WebView: `siteverify` is stateless, so a token minted in one
/// session validates in another, while the ASP.NET antiforgery pair
/// (`__RequestVerificationToken` + the HttpOnly `.AspNetCore.Antiforgery.*`
/// cookie) is fetched here so both halves always belong to the same session.
/// That sidesteps having to read an HttpOnly cookie out of the WebView, which
/// the official webview plugin cannot do.
class StudentIdQueryHelper {
  static const String queryUrl =
      'https://stdsys.nkust.edu.tw/student/QueryStudentId';
  static const String resultUrl =
      'https://stdsys.nkust.edu.tw/student/QueryStudentId/ShowResult';

  /// Turnstile sitekey rendered by the query page. Public by design — it only
  /// selects which widget to draw; the matching secret stays on the server.
  static const String turnstileSiteKey = '0x4AAAAAABrczXF7Y5OJeH_7';

  static StudentIdQueryHelper? _instance;

  // ignore: prefer_constructors_over_static_methods
  static StudentIdQueryHelper get instance {
    return _instance ??= StudentIdQueryHelper();
  }

  /// Runs the lookup with a Turnstile token minted elsewhere.
  ///
  /// Each call gets its own cookie jar: the antiforgery cookie is per-session
  /// and a stale one from a previous attempt fails validation.
  Future<StudentIdQueryResult> query({
    required String rocId,
    required DateTime birthday,
    required String turnstileToken,
  }) async {
    final (:Dio dio, :CookieJar cookieJar) = ApiConfig.createScraperDio();

    final Response<String> form = await dio.get<String>(queryUrl);
    final String? formToken =
        StdsysParser.instance.queryStudentIdFormTokenParser(form.data);

    if (formToken == null) {
      throw ServerException(
        httpStatusCode: form.statusCode,
        message: 'student id query form is missing its antiforgery token',
      );
    }

    final String birthdayText = sprintf('%03i%02i%02i', <int>[
      birthday.year - 1911,
      birthday.month,
      birthday.day,
    ]);

    final Response<String> result = await dio.post<String>(
      resultUrl,
      data: <String, String>{
        'ReturnUrl': '',
        'returnUrlHash': '',
        'IdNo': rocId,
        'Birthday': birthdayText,
        'cf-turnstile-response': turnstileToken,
        '__RequestVerificationToken': formToken,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: <String, dynamic>{
          'Referer': queryUrl,
          'Origin': 'https://stdsys.nkust.edu.tw',
        },
      ),
    );

    return StdsysParser.instance.queryStudentIdResultParser(result.data);
  }
}
