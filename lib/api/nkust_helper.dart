import 'dart:async';
import 'dart:convert';

import 'package:ap_common/models/notification_data.dart';
import 'package:ap_common/models/user_info.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/api/parser/nkust_parser.dart';
import 'package:sprintf/sprintf.dart';

class NKUSTHelper {
  NKUSTHelper();

  static NKUSTHelper get instance {
    return _instance ??= NKUSTHelper();
  }

  static NKUSTHelper? _instance;

  static int reTryCountsLimit = 3;
  static int reTryCounts = 0;

  Dio dio = Dio();

  Future<void> getUsername({
    String? rocId,
    required DateTime birthday,
    required GeneralCallback<UserInfo> callback,
  }) async {
    String? birthdayText = sprintf("%03i%02i%02i", [
      birthday.year - 1911,
      birthday.month,
      birthday.day,
    ]);
    var response = await http.get(
      Uri(
        scheme: 'https',
        host: 'webap.nkust.edu.tw',
        path: '/nkust/system/getuid_1.jsp',
        queryParameters: {
          'uid': rocId,
          'bir': birthdayText,
          'kind': '2',
        },
      ),
      headers: {
        'Connection': 'close',
      },
    );
    var document = parse(response.body);
    var elements = document.getElementsByTagName('b');
    if (elements.length >= 4) {
      var userInfo = UserInfo(
        id: elements[4].text.replaceAll(' ', ''),
        name: elements[2].text,
        className: '',
        department: '',
      );
      return callback == null ? userInfo : callback.onSuccess(userInfo);
    } else if (elements.length == 1)
      callback.onError(
        GeneralResponse(
          statusCode: 404,
          message: elements[0].text,
        ),
      );
    else
      callback.onError(
        GeneralResponse.unknownError(),
      );
  }

  Future<NotificationsData> getNotifications(int page) async {
    page -= 1;
    int baseIndex = page * 15;
    if (reTryCounts > reTryCountsLimit) {
      throw NullThrownError;
    }
    Response<String> res = await dio.post<String>(
        "https://acad.nkust.edu.tw/app/index.php?Action=mobilercglist",
        data: {
          'Rcg': 232,
          'Op': 'getpartlist',
          'Page': page,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ));
    List<Map<String, dynamic>> acadData;
    if (res.statusCode == 200 && res.data != null) {
      acadData = acadParser(
        html: json.decode(res.data!)["content"] as String,
        baseIndex: baseIndex,
      );
      reTryCounts = 0;
    } else {
      reTryCounts++;
      return getNotifications(page);
    }
    return NotificationsData.fromJson({
      "data": {
        "page": page + 1,
        "notification": acadData,
      }
    });
  }
}
