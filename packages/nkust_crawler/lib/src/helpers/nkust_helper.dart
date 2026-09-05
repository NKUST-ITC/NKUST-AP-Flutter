import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:ap_common_core/ap_common_core.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:nkust_crawler/src/abstractions/captcha_solver.dart';
import 'package:nkust_crawler/src/config/api_config.dart';
import 'package:nkust_crawler/src/exceptions/api_exception.dart';
import 'package:nkust_crawler/src/parsers/nkust_parser.dart';
import 'package:sprintf/sprintf.dart';

class NKUSTHelper {
  static NKUSTHelper? _instance;

  late Dio dio;
  late CookieJar cookieJar;

  /// Captcha solver injected by the host app (defaults to a stub that
  /// always throws — host must wire a real implementation before login
  /// flows that need a captcha).
  CaptchaSolver? captchaSolver;

  /// acad's mobile list endpoint no longer paginates server-side — it
  /// hands back the whole (~200 row) list in one response and 302s for
  /// `Page >= 2` — so the full list is fetched once, deduped, and
  /// windowed client-side. Without this, an infinite-scroll list would
  /// re-download and re-parse the entire feed for every page turn.
  List<Map<String, dynamic>>? _acadCache;
  DateTime? _acadCachedAt;
  static const Duration _acadCacheTtl = Duration(minutes: 10);

  /// The academic-affairs announcement category (`Rcg`). It changed once
  /// already (232 -> 2072) and broke this feed, so keep it in one place.
  static const int _acadRcg = 2072;

  //ignore: prefer_constructors_over_static_methods
  static NKUSTHelper get instance {
    return _instance ??= NKUSTHelper();
  }

  NKUSTHelper() {
    dioInit();
  }

  void setProxy(String proxyIP) {
    ApiConfig.setProxy(dio, proxyIP);
  }

  void dioInit() {
    final (:dio, :cookieJar) = ApiConfig.createScraperDio();
    this.dio = dio;
    this.cookieJar = cookieJar;
  }

  Future<Uint8List?> getUidValidationImage() async {
    final Response<Uint8List> response = await dio.get<Uint8List>(
      'https://webap.nkust.edu.tw/nkust/validateCode_foruid.jsp',
      options: Options(
        responseType: ResponseType.bytes,
        headers: <String, dynamic>{
          'Referer': 'https://webap.nkust.edu.tw/',
        },
      ),
    );
    return response.data;
  }

  Future<UserInfo> getUsername({
    required String rocId,
    required DateTime birthday,
    int retryCounts = 5,
  }) async {
    final String birthdayText = sprintf('%03i%02i%02i', <int>[
      birthday.year - 1911,
      birthday.month,
      birthday.day,
    ]);

    assert(retryCounts >= 0, 'retryCounts must be >= 0');

    Object? lastError;

    for (int i = 0; i < retryCounts; i++) {
      try {
        final Uint8List? imageBytes = await getUidValidationImage();

        if (imageBytes == null) {
          continue;
        }

        final solver = captchaSolver;
        if (solver == null) {
          throw StateError(
            'NKUSTHelper.captchaSolver is not configured. '
            'Wire a CaptchaSolver implementation at app bootstrap.',
          );
        }
        final String captchaCode = await solver.solve(imageBytes);

        final List<Cookie> cookies = await cookieJar
            .loadForRequest(Uri.parse('https://webap.nkust.edu.tw'));
        final String cookieHeader = cookies
            .map((Cookie cookie) => '${cookie.name}=${cookie.value}')
            .join('; ');

        final http.Response response = await http.post(
          Uri(
            scheme: 'https',
            host: 'webap.nkust.edu.tw',
            path: '/nkust/system/getuid_1.jsp',
            queryParameters: <String, String>{
              'uid': rocId,
              'bir': birthdayText,
              'Text3': captchaCode,
              'kind': '2',
            },
          ),
          headers: <String, String>{
            'Connection': 'close',
            'Content-Type': 'application/x-www-form-urlencoded',
            'Referer': 'https://webap.nkust.edu.tw/',
            'Cookie': cookieHeader,
          },
        );

        if (!response.body.contains('驗證碼')) {
          final Document document = parse(response.body);
          final List<Element> elements = document.getElementsByTagName('b');

          if (elements.length >= 4) {
            final UserInfo userInfo = UserInfo(
              id: elements[4].text.replaceAll(' ', ''),
              name: elements[2].text,
              className: '',
              department: '',
            );
            return userInfo;
          } else if (elements.length == 1) {
            throw ServerException(
              httpStatusCode: 404,
              message: elements[0].text,
            );
          } else {
            throw ServerException(
              message: 'unexpected element count in username lookup response',
            );
          }
        }
      } on ApException {
        rethrow;
      } on SocketException catch (e, s) {
        // package:http wraps transport errors as SocketException /
        // HandshakeException; translate immediately so the UI shows
        // "沒有網路連線" rather than the generic "未知錯誤" that _call
        // would otherwise wrap this as.
        throw NetworkException(
          message: e.message,
          cause: e,
          causeStackTrace: s,
        );
      } on HandshakeException catch (e, s) {
        throw NetworkException(
          message: e.message,
          cause: e,
          causeStackTrace: s,
        );
      } on http.ClientException catch (e, s) {
        throw NetworkException(
          message: e.message,
          cause: e,
          causeStackTrace: s,
        );
      } catch (error) {
        lastError = error;

        if (i == retryCounts - 1) {
          rethrow;
        }
      }
    }

    throw CaptchaException(
      attempts: retryCounts,
      message: lastError == null
          ? 'captcha failed after $retryCounts attempts'
          : 'captcha failed: $lastError',
    );
  }

  Future<NotificationsData> getNotifications(int page) async {
    const int pageSize = 15;

    // page 1 is both the initial load and pull-to-refresh — always
    // refetch. Later pages (infinite scroll) reuse the cached list
    // unless it has gone stale.
    final bool stale = _acadCache == null ||
        _acadCachedAt == null ||
        DateTime.now().difference(_acadCachedAt!) > _acadCacheTtl;
    final List<Map<String, dynamic>> all;
    if (page > 1 && !stale) {
      all = _acadCache!;
    } else {
      all = await _fetchAcadNotifications();
      _acadCache = all;
      _acadCachedAt = DateTime.now();
    }

    final int start = (page - 1) * pageSize;
    final List<Map<String, dynamic>> acadData = start >= all.length
        ? <Map<String, dynamic>>[]
        : all.sublist(
            start,
            start + pageSize > all.length ? all.length : start + pageSize,
          );
    return NotificationsData.fromJson(<String, dynamic>{
      'data': <String, dynamic>{
        'page': page + 1,
        'notification': acadData,
      },
    });
  }

  /// Fetches, parses and dedups the whole acad announcement list. The
  /// endpoint 302s for `Page >= 2` and returns everything for `Page 0`.
  Future<List<Map<String, dynamic>>> _fetchAcadNotifications() async {
    const int maxRetries = 3;
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      final Response<String> res = await dio.post<String>(
        'https://acad.nkust.edu.tw/app/index.php?Action=mobilercglist',
        data: <String, dynamic>{
          'Rcg': _acadRcg,
          'Op': 'getpartlist',
          'Page': 0,
        },
        options:
            Options(contentType: Headers.formUrlEncodedContentType, headers: {
          'Referer': 'https://acad.nkust.edu.tw/p/403-1063-'
              '$_acadRcg-1.php?Lang=zh-tw',
        }),
      );
      if (res.statusCode == 200 && res.data != null) {
        final String? content = _acadContent(res.data!);
        if (content == null) {
          // 200 but the body wasn't the expected `{"content": "..."}`
          // JSON (e.g. an HTML error page): retry, then give up with a
          // clean ServerException the UI layer already handles.
          continue;
        }
        final List<Map<String, dynamic>> parsed =
            acadParser(html: content, baseIndex: 0);
        final Set<String> seen = <String>{};
        return <Map<String, dynamic>>[
          for (final Map<String, dynamic> n in parsed)
            if (n['link'] != null &&
                '${n['link']}'.isNotEmpty &&
                seen.add('${n['link']}'))
              n,
        ];
      }
    }
    throw ServerException(
      message: 'notifications request returned no usable response',
    );
  }

  /// Pulls the HTML fragment out of acad's `{"content": "..."}` reply,
  /// or null if the body isn't that shape (rather than letting a raw
  /// FormatException escape past the UI's `ApException` handler).
  static String? _acadContent(String body) {
    try {
      final Object? decoded = json.decode(body);
      if (decoded is Map<String, dynamic> && decoded['content'] is String) {
        return decoded['content'] as String;
      }
    } on FormatException {
      // fall through
    }
    return null;
  }
}
