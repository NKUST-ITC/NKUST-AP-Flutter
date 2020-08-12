import 'dart:async';
import 'dart:convert';

import 'package:ap_common/models/user_info.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:nkust_ap/models/notification_data.dart';

class NKUSTHelper {
  static NKUSTHelper _instance;

  static NKUSTHelper get instance {
    if (_instance == null) {
      _instance = NKUSTHelper();
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

  //experiment for flutter web
  Future<NotificationsData> getNotifications(int page) async {
    try {
      var response = await http.get(
        Uri.encodeFull("https://nkust.taki.dog/news/school?page=$page"),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36',
          'Cache-Control': 'no-cache',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3',
          'Connection': 'keep-alive',
          'Host': 'nkust.taki.dog',
          'Accept-Encoding': 'gzip, deflate',
          'Access-Control-Allow-Origin': '*',
          'Referer': '',
        },
      );
      var text = utf8.decode(response.bodyBytes);
      var map = jsonDecode(text);
      return NotificationsData.fromJson(map);
    } catch (e) {
      throw e;
    }
  }
}
