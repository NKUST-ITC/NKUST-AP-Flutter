import 'dart:async';
import 'dart:convert';

import 'package:ap_common/models/notification_data.dart';
import 'package:ap_common/models/user_info.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/api/parser/nkust_parser.dart';
import 'package:sprintf/sprintf.dart';

class NKUSTHelper {
  NKUSTHelper();

  //ignore: prefer_constructors_over_static_methods
  static NKUSTHelper get instance {
    return _instance ??= NKUSTHelper();
  }

  static NKUSTHelper? _instance;

  static int reTryCountsLimit = 3;
  static int reTryCounts = 0;

  Dio dio = Dio();

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
    final http.Response response = await http.get(
      Uri(
        scheme: 'https',
        host: 'webap.nkust.edu.tw',
        path: '/nkust/system/getuid_1.jsp',
        queryParameters: <String, String>{
          'uid': rocId,
          'bir': birthdayText,
          'kind': '2',
        },
      ),
      headers: <String, String>{
        'Connection': 'close',
      },
    );
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
  }

  Future<NotificationsData> getNotifications(int page) async {
    final int baseIndex = (page - 1) * 15;
    if (reTryCounts > reTryCountsLimit) {
      throw NullThrownError;
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
      }
    });
  }
}
