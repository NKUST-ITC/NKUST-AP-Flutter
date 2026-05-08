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
