import 'dart:async';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:nkust_ap/models/user_info.dart';

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
        studentId: elements[4].text.replaceAll(' ', ''),
        studentNameCht: elements[2].text,
      );
    else
      return null;
  }
}
