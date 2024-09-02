import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ap_common/models/notification_data.dart';
import 'package:ap_common/models/private_cookies_manager.dart';
import 'package:ap_common/models/user_info.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/io.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/api/parser/nkust_parser.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/utils/captcha_utils.dart';
import 'package:sprintf/sprintf.dart';

import 'package:nkust_ap/api/ap_status_code.dart';

class NKUSTHelper {
  static NKUSTHelper? _instance;

  late Dio dio;
  late DioCacheManager _manager;
  late CookieJar cookieJar;

  static int reTryCountsLimit = 3;
  static int reTryCounts = 0;

  //ignore: prefer_constructors_over_static_methods
  static NKUSTHelper get instance {
    return _instance ??= NKUSTHelper();
  }

  NKUSTHelper() {
    dioInit();
  }

  void setProxy(String proxyIP) {
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final HttpClient client = HttpClient();
      client.findProxy = (Uri uri) {
        return 'PROXY $proxyIP';
      };
      return client;
    };
  }

  void dioInit() {
    // Use PrivateCookieManager to overwrite origin CookieManager, because
    // Cookie name of the NKUST ap system not follow the RFC6265. :(
    dio = Dio();
    cookieJar = CookieJar();
    if (Helper.isSupportCacheData) {
      _manager = DioCacheManager(
        CacheConfig(baseUrl: 'https://webap.nkust.edu.tw'),
      );
      dio.interceptors.add(_manager.interceptor as Interceptor);
    }
    dio.interceptors.add(PrivateCookieManager(cookieJar));
    dio.options.headers['user-agent'] =
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36';
    dio.options.headers['Connection'] = 'close';
    dio.options.connectTimeout = const Duration(
      milliseconds: Constants.timeoutMs,
    );
    dio.options.receiveTimeout = const Duration(
      milliseconds: Constants.timeoutMs,
    );
    if (Platform.isIOS || Platform.isMacOS || Platform.isAndroid) {
      dio.httpClientAdapter = NativeAdapter();
    }
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

  Future<void> getUsername({
    required String rocId,
    required DateTime birthday,
    required GeneralCallback<UserInfo> callback,
  }) async {
    final String birthdayText = sprintf('%03i%02i%02i', <int>[
      birthday.year - 1911,
      birthday.month,
      birthday.day,
    ]);

    for (int i = 0; i < 5; i++) {
      final String captchaCode = await CaptchaUtils.extractByTfLite(
        bodyBytes: (await getUidValidationImage())!,
      );

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
          callback.onSuccess(userInfo);
        } else if (elements.length == 1) {
          callback.onError(
            GeneralResponse(
              statusCode: 404,
              message: elements[0].text,
            ),
          );
        } else {
          callback.onError(
            GeneralResponse.unknownError(),
          );
        }

        return;
      }
    }

    throw GeneralResponse(
      statusCode: ApStatusCode.unknownError,
      message: 'captcha error or unknown error',
    );
  }

  Future<NotificationsData> getNotifications(int page) async {
    final int baseIndex = (page - 1) * 15;
    if (reTryCounts > reTryCountsLimit) {
      throw 'NullThrownError';
    }
    final Response<String> res = await dio.post<String>(
      'https://acad.nkust.edu.tw/app/index.php?Action=mobilercglist',
      data: <String, dynamic>{
        'Rcg': 232,
        'Op': 'getpartlist',
        'Page': page - 1,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    List<Map<String, dynamic>> acadData;
    if (res.statusCode == 200 && res.data != null) {
      acadData = acadParser(
        html: (json.decode(res.data!) as Map<String, dynamic>)['content']
            as String,
        baseIndex: baseIndex,
      );
      reTryCounts = 0;
    } else {
      reTryCounts++;
      return getNotifications(page);
    }
    return NotificationsData.fromJson(<String, dynamic>{
      'data': <String, dynamic>{
        'page': page + 1,
        'notification': acadData,
      },
    });
  }
}
