//dio
import 'dart:io';

import 'package:ap_common/models/private_cookies_manager.dart';
//overwrite origin Cookie Manager.
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:html/parser.dart' show parse;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nkust_ap/api/ap_helper.dart';
//parser
import 'package:nkust_ap/api/parser/leave_parser.dart';
//Config
import 'package:nkust_ap/config/constants.dart';
//model
import 'package:nkust_ap/models/leave_data.dart';
import 'package:nkust_ap/models/leave_submit_data.dart';
import 'package:nkust_ap/models/leave_submit_info_data.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/models/mobile_cookies_data.dart';
import 'package:nkust_ap/pages/leave_nkust_page.dart';

import 'ap_status_code.dart';
import 'helper.dart';

class LeaveHelper {
  LeaveHelper() {
    dioInit();
  }

  static const BASE_PATH = 'https://leave.nkust.edu.tw/';
  static const HOME = '${BASE_PATH}masterindex.aspx';

  static LeaveHelper? _instance;

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
        (client) {
      client.findProxy = (uri) {
        return "PROXY " + proxyIP;
      };
    };
  }

  void dioInit() {
    // Use PrivateCookieManager to overwrite origin CookieManager, because
    // Cookie name of the NKUST ap system not follow the RFC6265. :(
    dio = Dio();
    dio.interceptors.add(PrivateCookieManager(WebApHelper.instance.cookieJar));
    dio.options.headers['user-agent'] =
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36';

    dio.options.headers.addAll({
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
    dio.options.connectTimeout = Constants.TIMEOUT_MS;
    dio.options.receiveTimeout = Constants.TIMEOUT_MS;
  }

  void setCookieFromData(MobileCookiesData data) {
    if (data != null) {
      cookiesData = data;
      data.cookies.forEach((element) {
        Cookie _tempCookie = Cookie(element.name, element.value);
        _tempCookie.domain = element.domain;
        cookieJar.saveFromResponse(
          Uri.parse(element.path),
          [_tempCookie],
        );
      });
    }
  }

  void setCookie(
    String url, {
    required String cookieName,
    required String cookieValue,
    String? cookieDomain,
  }) {
    Cookie _tempCookie = Cookie(cookieName, cookieValue);
    _tempCookie.domain = cookieDomain;
    cookieJar.saveFromResponse(
      Uri.parse(url),
      [_tempCookie],
    );
  }

  Future<bool> isCookieAlive() async {
    try {
      //TODO check cookies is expire
      var res = await dio.get('');
      return res.data == 'alive';
    } catch (e) {}
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
      MaterialPageRoute(
        builder: (_) => LeaveNkustPage(
          username: username,
          password: password,
          clearCache: clearCache,
        ),
      ),
    );
    if (result ?? false)
      return LoginResponse();
    else
      throw GeneralResponse(statusCode: ApStatusCode.CANCEL, message: 'cancel');
  }

  /// Since 2021/07 School add Google re-captcha in leave system crawler login not working
  @deprecated
  Future<bool> leaveLogin() async {
    if (Helper.username == null || Helper.password == null) {
      throw NullThrownError;
    }

    //Get base hidden data.
    Response<String> res = await dio.get<String>(
      "https://leave.nkust.edu.tw/LogOn.aspx",
    );
    var requestData = hiddenInputGet(res.data);
    requestData[r"Login1$UserName"] = Helper.username;
    requestData[r"Login1$Password"] = Helper.password;
    requestData[r"Login1$LoginButton"] = "登入";
    requestData[r"HiddenField1"] = "";
    try {
      await dio.post(
        "https://leave.nkust.edu.tw/LogOn.aspx",
        data: requestData,
        options: Options(
            followRedirects: false,
            contentType: Headers.formUrlEncodedContentType),
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
    Response<String> res = await dio.get<String>(
      "https://leave.nkust.edu.tw/AK002MainM.aspx",
    );
    var requestData = allInputValueParser(res.data);
    requestData[r'ctl00$ContentPlaceHolder1$SYS001$DropDownListYms'] =
        "$year-$semester";
    requestData[r"ctl00$ContentPlaceHolder1$Button1	"] = "確定送出";
    requestData.remove(r"ctl00$ButtonLogOut");
    Response<String> queryRequest = await dio.post<String>(
      "https://leave.nkust.edu.tw/AK002MainM.aspx",
      data: requestData,
      options: Options(
          followRedirects: false,
          contentType: Headers.formUrlEncodedContentType),
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
      "https://leave.nkust.edu.tw/CK001MainM.aspx",
    );
    var requestData = hiddenInputGet(res.data);
    requestData[r"ctl00$ContentPlaceHolder1$CK001$ButtonEnter"] = "進入請假作業";

    res = await dio.post(
      "https://leave.nkust.edu.tw/CK001MainM.aspx",
      data: requestData,
      options: Options(
          followRedirects: false,
          contentType: Headers.formUrlEncodedContentType),
    );
    String fakeDate =
        "${DateTime.now().year - 1911}/${DateTime.now().month}/${DateTime.now().day}";
    requestData = hiddenInputGet(res.data, removeTdElement: true);
    requestData[r"ctl00$ContentPlaceHolder1$CK001$DateUCCBegin$text1"] =
        fakeDate;
    requestData[r"ctl00$ContentPlaceHolder1$CK001$DateUCCEnd$text1"] = fakeDate;
    requestData[r"ctl00$ContentPlaceHolder1$CK001$ButtonCommit"] = "下一步";
    res = await dio.post(
      "https://leave.nkust.edu.tw/CK001MainM.aspx",
      data: requestData,
      options: Options(
          followRedirects: false,
          contentType: Headers.formUrlEncodedContentType),
    );
    return LeaveSubmitInfoData.fromJson(leaveSubmitInfoParser(res.data)!);
  }

  Future<Response?> leavesSubmit(LeaveSubmitData data,
      {PickedFile? proofImage}) async {
    //force relogin to aviod error.
    await WebApHelper.instance.loginToLeave();

    Response<String> res = await dio.get<String>(
      "https://leave.nkust.edu.tw/CK001MainM.aspx",
    );

    var requestData = hiddenInputGet(res.data);
    requestData[r"ctl00$ContentPlaceHolder1$CK001$ButtonEnter"] = "進入請假作業";

    res = await dio.post(
      "https://leave.nkust.edu.tw/CK001MainM.aspx",
      data: requestData,
      options: Options(
          followRedirects: false,
          contentType: Headers.formUrlEncodedContentType),
    );

    requestData = hiddenInputGet(res.data, removeTdElement: true);
    var dateFormate = DateFormat("yyyy/MM/dd");
    var beginDate = dateFormate.parse(data.days[0].day!);
    var endDate = dateFormate.parse(data.days[data.days.length - 1].day!);

    requestData[r"ctl00$ContentPlaceHolder1$CK001$DateUCCBegin$text1"] =
        "${beginDate.year - 1911}/${beginDate.month}/${beginDate.day}";

    requestData[r"ctl00$ContentPlaceHolder1$CK001$DateUCCEnd$text1"] =
        "${endDate.year - 1911}/${endDate.month}/${endDate.day}";

    requestData[r"ctl00$ContentPlaceHolder1$CK001$ButtonCommit"] = "下一步";
    res = await dio.post(
      "https://leave.nkust.edu.tw/CK001MainM.aspx",
      data: requestData,
      options: Options(
          followRedirects: false,
          contentType: Headers.formUrlEncodedContentType),
    );
    if (res.data.toString().indexOf("alert(") > -1) {
      return null;
    }
    var submitData = leaveSubmitInfoParser(res.data.toString());
    print("on submit main page.");
    print("Change leave type");
    Map<String, dynamic> globalRequestData = {};

    globalRequestData[r"ctl00$ContentPlaceHolder1$CK001$TextBoxReason"] =
        data.reasonText;
    globalRequestData[r"ctl00$ContentPlaceHolder1$CK001$ddlTeach"] =
        data.teacherId;
    globalRequestData[
            r"ctl00$ContentPlaceHolder1$CK001$RadioButtonListOption"] =
        data.leaveTypeId;
    if (data.delayReasonText != null &&
        res.data.toString().indexOf("延遲理由") > -1) {
      globalRequestData[r"ctl00$ContentPlaceHolder1$CK001$TextBoxDelayReason"] =
          data.delayReasonText;
    }
    var document = parse(res.data.toString());

    print("generate need click button list");
    var trObj =
        document.getElementsByClassName("mGrid")[0].getElementsByTagName("tr");
    if (trObj.length < 2) {
      print("Error: not found leave days options");
      return null;
    }
    List<String?> _clickList = [];
    for (int i = 1; i < trObj.length; i++) {
      var td = trObj[i].getElementsByTagName("td");
      var _leaveDays = data.days[i - 1].dayClass!;
      for (int l = 0; l < _leaveDays.length; l++) {
        _clickList.add(td[(submitData!["timeCodes"] as List<dynamic>)
                    .indexOf(_leaveDays[l]) +
                3]
            .getElementsByTagName("input")[0]
            .attributes["name"]);
      }
    }
    print("click leave class");

    for (int i = 0; i < _clickList.length; i++) {
      var requestData = hiddenInputGet(res.data.toString());
      requestData.addAll(globalRequestData);

      requestData[_clickList[i]] = "";
      res = await dio.post(
        "https://leave.nkust.edu.tw/CK001MainM.aspx",
        data: requestData,
        options: Options(
            followRedirects: false,
            contentType: Headers.formUrlEncodedContentType),
      );
      //click covid-19 alert.

    }
    requestData = hiddenInputGet(res.data.toString());
    requestData.addAll(globalRequestData);
    if (res.data.toString().indexOf("ContentPlaceHolder1_CK001_cbFlag") > -1) {
      requestData[r"ctl00$ContentPlaceHolder1$CK001$cbFlag"] = "on";
    }
    requestData[r'ctl00$ContentPlaceHolder1$CK001$ButtonCommit2'] = '下一步';
    res = await dio.post(
      "https://leave.nkust.edu.tw/CK001MainM.aspx",
      data: requestData,
      options: Options(
          followRedirects: false,
          contentType: Headers.formUrlEncodedContentType),
    );

    print("End submit page");
    print("Submit and add leave proof image.");
    requestData = hiddenInputGet(res.data.toString());
    requestData[r"ctl00$ContentPlaceHolder1$CK001$ButtonSend"] = '存檔';
    if (proofImage != null) {
      print("Add proof image");
      requestData[r'ctl00$ContentPlaceHolder1$CK001$FileUpload1'] =
          await MultipartFile.fromFile(proofImage.path,
              filename: "proof_image.jpg",
              contentType: MediaType.parse("image/jpeg"));
    }

    FormData formData = FormData.fromMap(requestData as Map<String, dynamic>);

    dio.options.headers["Content-Type"] =
        "multipart/form-data; boundary=${formData.boundary}";
    res = await dio.post("https://leave.nkust.edu.tw/CK001MainM.aspx",
        data: formData);

    if (res.data.toString().indexOf("假單存檔成功") > -1) {
      return res;
    }

    return null;
  }
}
