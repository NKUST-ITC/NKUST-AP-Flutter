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
    const int pageSize = 15;
    const int maxRetries = 3;
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      final Response<String> res = await dio.post<String>(
        'https://acad.nkust.edu.tw/app/index.php?Action=mobilercglist',
        data: <String, dynamic>{
          'Rcg': 2072,
          'Op': 'getpartlist',
          // The revamped endpoint only serves Page 0 (Page >= 2 now 302s)
          // and returns the whole list, so always ask for 0 and window
          // the result below.
          'Page': 0,
        },
        options:
            Options(contentType: Headers.formUrlEncodedContentType, headers: {
          'Referer':
              'https://acad.nkust.edu.tw/p/403-1063-2072-1.php?Lang=zh-tw'
        }),
      );
      if (res.statusCode == 200 && res.data != null) {
        // The revamped endpoint returns the whole list in one shot (and
        // 302s for Page >= 2), so parse it all, drop any repeated link,
        // then slice the requested window client-side.
        final List<Map<String, dynamic>> parsed = acadParser(
          html: (json.decode(res.data!) as Map<String, dynamic>)['content']
              as String,
          baseIndex: 0,
        );
        final Set<String> seen = <String>{};
        final List<Map<String, dynamic>> all = <Map<String, dynamic>>[
          for (final Map<String, dynamic> n in parsed)
            if (seen.add('${n['link']}')) n,
        ];
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
    }
    throw ServerException(
      message: 'notifications request returned no usable response',
    );
  }
}
