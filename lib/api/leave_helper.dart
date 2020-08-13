//dio
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
//overwrite origin Cookie Manager.
import 'package:nkust_ap/api/private_cookie_manager.dart';
//Config
import 'package:nkust_ap/config/constants.dart';
//parser
import 'package:nkust_ap/api/parser/leave_parser.dart';
//model
import 'package:nkust_ap/models/leave_data.dart';

import 'helper.dart';

class LeaveHelper {
  static Dio dio;
  static LeaveHelper _instance;
  static CookieJar cookieJar;

  static int reLoginReTryCountsLimit = 3;
  static int reLoginReTryCounts = 0;

  bool isLogin;
  static LeaveHelper get instance {
    if (_instance == null) {
      _instance = LeaveHelper();
      dioInit();
    }
    return _instance;
  }

  void setProxy(String proxyIP) {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.findProxy = (uri) {
        return "PROXY " + proxyIP;
      };
    };
  }

  static dioInit() {
    // Use PrivateCookieManager to overwrite origin CookieManager, because
    // Cookie name of the NKUST ap system not follow the RFC6265. :(
    dio = Dio();
    cookieJar = CookieJar();
    dio.interceptors.add(PrivateCookieManager(cookieJar));
    dio.options.headers['user-agent'] =
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36';

    dio.options.headers.addAll({
      'Origin': 'http://leave.nkust.edu.tw',
      'Upgrade-Insecure-Requests': '1',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
      'Referer': 'http://leave.nkust.edu.tw/LogOn.aspx',
      'Accept-Encoding': 'gzip, deflate',
      'Accept-Language': 'zh-TW,zh;q=0.9,en-US;q=0.8,en;q=0.7,ja;q=0.6'
    });

    dio.options.headers['Connection'] = 'close';
    dio.options.connectTimeout = Constants.TIMEOUT_MS;
    dio.options.receiveTimeout = Constants.TIMEOUT_MS;
  }

  Future<bool> leaveLogin() async {
    if (Helper.username == null || Helper.password == null) {
      throw NullThrownError;
    }

    //Get base hidden data.
    Response res = await dio.get(
      "http://leave.nkust.edu.tw/LogOn.aspx",
    );
    var requestData = hiddenInputGet(res.data);
    requestData[r"Login1$UserName"] = Helper.username;
    requestData[r"Login1$Password"] = Helper.password;
    requestData[r"Login1$LoginButton"] = "登入";
    requestData[r"HiddenField1"] = "";
    try {
      Response login = await dio.post(
        "http://leave.nkust.edu.tw/LogOn.aspx",
        data: requestData,
        options: Options(
            followRedirects: false,
            contentType: Headers.formUrlEncodedContentType),
      );
      //login fail
      return false;
    } on DioError catch (e) {
      if (e.type == DioErrorType.RESPONSE && e.response.statusCode == 302) {
        //Use 302 to mean login success, nice...
        await dio.get('http://leave.nkust.edu.tw/masterindex.aspx');
        isLogin = true;
        return true;
      }
    }
    return false;
  }

  Future<LeaveData> getLeaves({String year, String semester}) async {
    if (Helper.username == null || Helper.password == null) {
      throw NullThrownError;
    }
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw NullThrownError;
    }
    if (isLogin == false || isLogin == null) {
      await leaveLogin();
      reLoginReTryCounts++;
    }
    Response res = await dio.get(
      "http://leave.nkust.edu.tw/AK002MainM.aspx",
    );
    var requestData = allInputValueParser(res.data);
    requestData[r'ctl00$ContentPlaceHolder1$SYS001$DropDownListYms'] =
        "${year}-${semester}";
    requestData[r"ctl00$ContentPlaceHolder1$Button1	"] = "確定送出";
    requestData.remove(r"ctl00$ButtonLogOut");
    Response queryRequest = await dio.post(
      "http://leave.nkust.edu.tw/AK002MainM.aspx",
      data: requestData,
      options: Options(
          followRedirects: false,
          contentType: Headers.formUrlEncodedContentType),
    );

    return LeaveData.fromJson(leaveQueryParser(queryRequest.data));
  }
}
