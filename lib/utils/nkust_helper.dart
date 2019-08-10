import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:html/parser.dart';
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
    final client = HttpClient();
    List<int> bodyBytes = utf8.encode("uid=$rocId"); // utf8 encode
    final request = await client.postUrl(
      Uri.parse('https://webap.nkust.edu.tw/nkust/system/getuid_1.jsp'),
    );
    request.headers.add('Connection', 'keep-alive');
    request.headers.add('Content-Length', "uid=$rocId".length.toString());
    request.headers.add('Content-Type', 'application/x-www-form-urlencoded');
    request.add(bodyBytes);
    final response = await request.close();
    var text = await utf8.decoder.bind(response).first;
    var document = parse(text);
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
