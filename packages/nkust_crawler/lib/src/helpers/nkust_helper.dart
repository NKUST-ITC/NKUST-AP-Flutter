import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ap_common_core/ap_common_core.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
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

  /// webap only sets the session cookie the captcha is bound to once
  /// index_main.html has been fetched. Without this prime, getuid_1.jsp
  /// rejects every code as a bad captcha even when the OCR is correct
  /// (the login flow hits the same quirk in WebApHelper).
  Future<void> _primeHomepage() async {
    try {
      await dio.get<dynamic>(
        'https://webap.nkust.edu.tw/nkust/index_main.html',
      );
    } catch (_) {}
  }

  Future<Uint8List?> getUidValidationImage() async {
    final Response<Uint8List> response = await dio.get<Uint8List>(
      'https://webap.nkust.edu.tw/nkust/validateCode_foruid.jsp',
      options: Options(
        responseType: ResponseType.bytes,
        headers: <String, dynamic>{
          'Referer': 'https://webap.nkust.edu.tw/nkust/index_main.html',
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

    await _primeHomepage();

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

        // Submit through the shared [dio] client so the session cookie the
        // captcha is bound to (set on the validateCode response) rides
        // along — on iOS that cookie lives in URLSession's own store and
        // never reaches a separate package:http client.
        final Response<dynamic> response = await dio.post<dynamic>(
          'https://webap.nkust.edu.tw/nkust/system/getuid_1.jsp',
          data: <String, String>{
            'uid': rocId,
            'bir': birthdayText,
            'Text3': captchaCode,
            'kind': '2',
          },
          options: Options(
            responseType: ResponseType.plain,
            contentType: Headers.formUrlEncodedContentType,
            headers: <String, String>{
              'Referer': 'https://webap.nkust.edu.tw/nkust/index_main.html',
              'Origin': 'https://webap.nkust.edu.tw',
            },
          ),
        );

        final String body = response.data?.toString() ?? '';
        if (!body.contains('驗證碼')) {
          final Document document = parse(body);
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
      } on DioException catch (e) {
        throw e.toApException();
      } catch (_) {
        // Captcha OCR / segmentation failure — retry with a fresh image.
      }
    }

    throw CaptchaException(
      attempts: retryCounts,
      message: 'captcha failed after $retryCounts attempts',
    );
  }

  Future<NotificationsData> getNotifications(int page) async {
    final int baseIndex = (page - 1) * 15;
    const int maxRetries = 3;
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      final Response<String> res = await dio.post<String>(
        'https://acad.nkust.edu.tw/app/index.php?Action=mobilercglist',
        data: <String, dynamic>{
          'Rcg': 232,
          'Op': 'getpartlist',
          'Page': page - 1,
        },
        options:
            Options(contentType: Headers.formUrlEncodedContentType, headers: {
          'Referer':
              'https://acad.nkust.edu.tw/p/403-1004-232-1.php?Lang=zh-tw'
        }),
      );
      if (res.statusCode == 200 && res.data != null) {
        final List<Map<String, dynamic>> acadData = acadParser(
          html: (json.decode(res.data!) as Map<String, dynamic>)['content']
              as String,
          baseIndex: baseIndex,
        );
        return NotificationsData.fromJson(<String, dynamic>{
          'data': <String, dynamic>{
            'page': page + 1,
            'notification': acadData,
          },
        });
      }
    }
    throw ServerException(
      message: 'notifications request returned no usable response',
    );
  }
}
