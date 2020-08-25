import 'dart:async';
import 'dart:convert';

import 'package:ap_common/models/notification_data.dart';
import 'package:ap_common/models/user_info.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:nkust_ap/api/parser/nkust_parser.dart';

class NKUSTHelper {
  static NKUSTHelper _instance;
  static Dio dio;

  static NKUSTHelper get instance {
    if (_instance == null) {
      _instance = NKUSTHelper();
      dio = Dio();
    }
    return _instance;
  }

  Future<UserInfo> getUsername(String rocId) async {
    var response = await http.get(
      Uri(
        scheme: 'https',
        host: 'webap.nkust.edu.tw',
        path: '/nkust/system/getuid_1.jsp',
        queryParameters: {
          'uid': rocId,
          'kind': '2',
        },
      ),
      headers: {
        'Connection': 'close',
      },
    );
    var document = parse(response.body);
    var elements = document.getElementsByTagName('b');
    if (elements.length >= 4)
      return UserInfo(
        id: elements[4].text.replaceAll(' ', ''),
        name: elements[2].text,
      );
    else
      return null;
  }

  Future<NotificationsData> getNotifications(int page) async {
    page -= 1;
    int baseIndex = page * 15;
    Response res = await dio.post(
        "https://acad.nkust.edu.tw/app/index.php?Action=mobilercglist",
        data: {
          'Rcg': 232,
          'Op': 'getpartlist',
          'Page': page,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ));
    if (res.statusCode == 200) {
      var acadData = acadParser(
        html: json.decode(res.data)["content"],
        baseIndex: baseIndex,
      );

      return NotificationsData.fromJson({
        "data": {
          "page": page + 1,
          "notification": acadData,
        }
      });
    }
  }
}
