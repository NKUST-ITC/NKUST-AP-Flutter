import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ap_common_core/ap_common_core.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:nkust_crawler/src/config/api_config.dart';
import 'package:nkust_crawler/src/exceptions/api_exception.dart';
import 'package:nkust_crawler/src/parsers/nkust_parser.dart';

class NKUSTHelper {
  static NKUSTHelper? _instance;

  late Dio dio;
  late CookieJar cookieJar;

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
