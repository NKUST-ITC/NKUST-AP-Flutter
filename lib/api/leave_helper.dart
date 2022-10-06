import 'dart:developer';
import 'dart:io';

import 'package:ap_common/models/private_cookies_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' show parse;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nkust_ap/api/ap_helper.dart';
import 'package:nkust_ap/api/ap_status_code.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/api/parser/leave_parser.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/leave_data.dart';
import 'package:nkust_ap/models/leave_submit_data.dart';
import 'package:nkust_ap/models/leave_submit_info_data.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/models/mobile_cookies_data.dart';
import 'package:nkust_ap/pages/leave_nkust_page.dart';

class LeaveHelper {
  LeaveHelper() {
    dioInit();
  }

  static const String basePath = 'https://leave.nkust.edu.tw/';
  static const String home = '${basePath}masterindex.aspx';

  static LeaveHelper? _instance;

  //ignore: prefer_constructors_over_static_methods
  static LeaveHelper get instance {
    return _instance ??= LeaveHelper();
  }

  int reLoginReTryCountsLimit = 3;
  int reLoginReTryCounts = 0;

  bool? isLogin;

  late Dio dio;
  late CookieJar cookieJar;

  MobileCookiesData? cookiesData;

  void setProxy(String proxyIP) {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
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
    dio.interceptors.add(PrivateCookieManager(WebApHelper.instance.cookieJar));
    dio.options.headers['user-agent'] =
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36';

    dio.options.headers.addAll(<String, String>{
      'Origin': 'http://leave.nkust.edu.tw',
      'Upgrade-Insecure-Requests': '1',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
      'Referer': 'https://leave.nkust.edu.tw/LogOn.aspx',
      'Accept-Encoding': 'gzip, deflate',
      'Accept-Language': 'zh-TW,zh;q=0.9,en-US;q=0.8,en;q=0.7,ja;q=0.6'
    });

    dio.options.headers['Connection'] = 'close';
    dio.options.connectTimeout = Constants.timeoutMs;
    dio.options.receiveTimeout = Constants.timeoutMs;
  }

  void setCookieFromData(MobileCookiesData data) {
    cookiesData = data;
    for (final MobileCookies element in data.cookies) {
      final Cookie tempCookie = Cookie(element.name, element.value);
      tempCookie.domain = element.domain;
      cookieJar.saveFromResponse(
        Uri.parse(element.path),
        <Cookie>[tempCookie],
      );
    }
  }

  void setCookie(
    String url, {
    required String cookieName,
    required String cookieValue,
    String? cookieDomain,
  }) {
    final Cookie tempCookie = Cookie(cookieName, cookieValue);
    tempCookie.domain = cookieDomain;
    cookieJar.saveFromResponse(
      Uri.parse(url),
      <Cookie>[tempCookie],
    );
  }

  Future<bool> isCookieAlive() async {
    try {
      //TODO check cookies is expire
      final Response<dynamic> res = await dio.get('');
      return res.data == 'alive';
    } catch (_) {}
    return false;
  }

  Future<LoginResponse> login({
    required BuildContext context,
    required String username,
    required String password,
    bool clearCache = false,
  }) async {
    // final data = MobileCookiesData.load();
    // if (data != null && !clearCache) {
    //   MobileNkustHelper.instance.setCookieFromData(data);
    //   final isCookieAlive = await MobileNkustHelper.instance.isCookieAlive();
    //   if (isCookieAlive) {
    //     final now = DateTime.now();
    //     final lastTime = Preferences.getInt(
    //       Constants.MOBILE_COOKIES_LAST_TIME,
    //       now.microsecondsSinceEpoch,
    //     );
    //     FirebaseAnalyticsUtils.analytics.logEvent(
    //       name: 'cookies_persistence_time',
    //       parameters: {
    //         'time': now.microsecondsSinceEpoch - lastTime,
    //       },
    //     );
    //     return LoginResponse();
    //   }
    // }
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => LeaveNkustPage(
          username: username,
          password: password,
          clearCache: clearCache,
        ),
      ),
    );
    if (result ?? false) {
      return LoginResponse();
    } else {
      throw GeneralResponse(statusCode: ApStatusCode.cancel, message: 'cancel');
    }
  }

  @Deprecated(
    'Since 2021/07 School add Google re-captcha in leave system crawler login not working',
  )
  Future<bool> leaveLogin() async {
    if (Helper.username == null || Helper.password == null) {
      throw NullThrownError;
    }

    //Get base hidden data.
    final Response<String> res = await dio.get<String>(
      'https://leave.nkust.edu.tw/LogOn.aspx',
    );
    final Map<String?, dynamic> requestData = hiddenInputGet(res.data);
    requestData[r'Login1$UserName'] = Helper.username;
    requestData[r'Login1$Password'] = Helper.password;
    requestData[r'Login1$LoginButton'] = '登入';
    requestData['HiddenField1'] = '';
    try {
      await dio.post(
        'https://leave.nkust.edu.tw/LogOn.aspx',
        data: requestData,
        options: Options(
          followRedirects: false,
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      //login fail
      return false;
    } on DioError catch (e) {
      if (e.type == DioErrorType.response && e.response!.statusCode == 302) {
        //Use 302 to mean login success, nice...
        await dio.get('https://leave.nkust.edu.tw/masterindex.aspx');
        isLogin = true;
        return true;
      }
    }
    return false;
  }

  Future<LeaveData> getLeaves({String? year, String? semester}) async {
    if (Helper.username == null || Helper.password == null) {
      throw NullThrownError;
    }
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw NullThrownError;
    }
    if (!(isLogin ?? false)) {
      await WebApHelper.instance.loginToLeave();
      reLoginReTryCounts++;
    }
    final Response<String> res = await dio.get<String>(
      'https://leave.nkust.edu.tw/AK002MainM.aspx',
    );
    final Map<String?, dynamic> requestData = allInputValueParser(res.data);
    requestData[r'ctl00$ContentPlaceHolder1$SYS001$DropDownListYms'] =
        '$year-$semester';
    requestData[r'ctl00$ContentPlaceHolder1$Button1	'] = '確定送出';
    requestData.remove(r'ctl00$ButtonLogOut');
    final Response<String> queryRequest = await dio.post<String>(
      'https://leave.nkust.edu.tw/AK002MainM.aspx',
      data: requestData,
      options: Options(
        followRedirects: false,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    return LeaveData.fromJson(leaveQueryParser(queryRequest.data));
  }

  Future<LeaveSubmitInfoData> getLeavesSubmitInfo() async {
    if (Helper.username == null || Helper.password == null) {
      throw NullThrownError;
    }
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw NullThrownError;
    }
    if (!(isLogin ?? false)) {
      await WebApHelper.instance.loginToLeave();
      reLoginReTryCounts++;
    }
    Response<String> res = await dio.get<String>(
      'https://leave.nkust.edu.tw/CK001MainM.aspx',
    );
    Map<String?, dynamic> requestData = hiddenInputGet(res.data);
    requestData[r'ctl00$ContentPlaceHolder1$CK001$ButtonEnter'] = '進入請假作業';

    res = await dio.post(
      'https://leave.nkust.edu.tw/CK001MainM.aspx',
      data: requestData,
      options: Options(
        followRedirects: false,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    final String fakeDate =
        '${DateTime.now().year - 1911}/${DateTime.now().month}/${DateTime.now().day}';
    requestData = hiddenInputGet(res.data, removeTdElement: true);
    requestData[r'ctl00$ContentPlaceHolder1$CK001$DateUCCBegin$text1'] =
        fakeDate;
    requestData[r'ctl00$ContentPlaceHolder1$CK001$DateUCCEnd$text1'] = fakeDate;
    requestData[r'ctl00$ContentPlaceHolder1$CK001$ButtonCommit'] = '下一步';
    res = await dio.post(
      'https://leave.nkust.edu.tw/CK001MainM.aspx',
      data: requestData,
      options: Options(
        followRedirects: false,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    return LeaveSubmitInfoData.fromJson(leaveSubmitInfoParser(res.data)!);
  }

  Future<Response<dynamic>?> leavesSubmit(
    LeaveSubmitData data, {
    PickedFile? proofImage,
  }) async {
    //force relogin to aviod error.
    await WebApHelper.instance.loginToLeave();

    Response<String> res = await dio.get<String>(
      'https://leave.nkust.edu.tw/CK001MainM.aspx',
    );

    Map<String?, dynamic> requestData = hiddenInputGet(res.data);
    requestData[r'ctl00$ContentPlaceHolder1$CK001$ButtonEnter'] = '進入請假作業';

    res = await dio.post(
      'https://leave.nkust.edu.tw/CK001MainM.aspx',
      data: requestData,
      options: Options(
        followRedirects: false,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    requestData = hiddenInputGet(res.data, removeTdElement: true);
    final DateFormat dateFormate = DateFormat('yyyy/MM/dd');
    final DateTime beginDate = dateFormate.parse(data.days[0].day!);
    final DateTime endDate =
        dateFormate.parse(data.days[data.days.length - 1].day!);

    requestData[r'ctl00$ContentPlaceHolder1$CK001$DateUCCBegin$text1'] =
        '${beginDate.year - 1911}/${beginDate.month}/${beginDate.day}';

    requestData[r'ctl00$ContentPlaceHolder1$CK001$DateUCCEnd$text1'] =
        '${endDate.year - 1911}/${endDate.month}/${endDate.day}';

    requestData[r'ctl00$ContentPlaceHolder1$CK001$ButtonCommit'] = '下一步';
    res = await dio.post(
      'https://leave.nkust.edu.tw/CK001MainM.aspx',
      data: requestData,
      options: Options(
        followRedirects: false,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    if (res.data.toString().contains('alert(')) {
      return null;
    }
    final Map<String, dynamic>? submitData =
        leaveSubmitInfoParser(res.data.toString());
    log('on submit main page.');
    log('Change leave type');
    final Map<String, dynamic> globalRequestData = <String, dynamic>{};

    globalRequestData[r'ctl00$ContentPlaceHolder1$CK001$TextBoxReason'] =
        data.reasonText;
    globalRequestData[r'ctl00$ContentPlaceHolder1$CK001$ddlTeach'] =
        data.teacherId;
    globalRequestData[
            r'ctl00$ContentPlaceHolder1$CK001$RadioButtonListOption'] =
        data.leaveTypeId;
    if (data.delayReasonText != null && res.data.toString().contains('延遲理由')) {
      globalRequestData[r'ctl00$ContentPlaceHolder1$CK001$TextBoxDelayReason'] =
          data.delayReasonText;
    }
    final html.Document document = parse(res.data.toString());

    log('generate need click button list');
    final List<html.Element> trObj =
        document.getElementsByClassName('mGrid')[0].getElementsByTagName('tr');
    if (trObj.length < 2) {
      log('Error: not found leave days options');
      return null;
    }
    final List<String?> clickList = <String?>[];
    for (int i = 1; i < trObj.length; i++) {
      final List<html.Element> td = trObj[i].getElementsByTagName('td');
      final List<String> leaveDays = data.days[i - 1].dayClass!;
      for (int l = 0; l < leaveDays.length; l++) {
        clickList.add(
          td[(submitData!['timeCodes'] as List<dynamic>).indexOf(leaveDays[l]) +
                  3]
              .getElementsByTagName('input')[0]
              .attributes['name'],
        );
      }
    }
    log('click leave class');

    for (int i = 0; i < clickList.length; i++) {
      final Map<String?, dynamic> requestData =
          hiddenInputGet(res.data.toString());
      requestData.addAll(globalRequestData);

      requestData[clickList[i]] = '';
      res = await dio.post(
        'https://leave.nkust.edu.tw/CK001MainM.aspx',
        data: requestData,
        options: Options(
          followRedirects: false,
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      //click covid-19 alert.

    }
    requestData = hiddenInputGet(res.data.toString());
    requestData.addAll(globalRequestData);
    if (res.data.toString().contains('ContentPlaceHolder1_CK001_cbFlag')) {
      requestData[r'ctl00$ContentPlaceHolder1$CK001$cbFlag'] = 'on';
    }
    requestData[r'ctl00$ContentPlaceHolder1$CK001$ButtonCommit2'] = '下一步';
    res = await dio.post(
      'https://leave.nkust.edu.tw/CK001MainM.aspx',
      data: requestData,
      options: Options(
        followRedirects: false,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    log('End submit page');
    log('Submit and add leave proof image.');
    requestData = hiddenInputGet(res.data.toString());
    requestData[r'ctl00$ContentPlaceHolder1$CK001$ButtonSend'] = '存檔';
    if (proofImage != null) {
      log('Add proof image');
      requestData[r'ctl00$ContentPlaceHolder1$CK001$FileUpload1'] =
          await MultipartFile.fromFile(
        proofImage.path,
        filename: 'proof_image.jpg',
        contentType: MediaType.parse('image/jpeg'),
      );
    }

    final FormData formData =
        FormData.fromMap(requestData as Map<String, dynamic>);

    dio.options.headers['Content-Type'] =
        'multipart/form-data; boundary=${formData.boundary}';
    res = await dio.post(
      'https://leave.nkust.edu.tw/CK001MainM.aspx',
      data: formData,
    );

    if (res.data.toString().contains('假單存檔成功')) {
      return res;
    }

    return null;
  }
}
