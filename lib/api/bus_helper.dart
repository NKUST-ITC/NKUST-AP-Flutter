//dio
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:cookie_jar/cookie_jar.dart';

//overwrite origin Cookie Manager.
import 'package:ap_common/models/private_cookies_manager.dart';

//parser
import 'package:nkust_ap/api/parser/bus_parser.dart';

//model
import 'package:nkust_ap/models/booking_bus_data.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/models/cancel_bus_data.dart';
import 'package:nkust_ap/models/bus_data.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';

import 'package:nkust_ap/api/parser/api_tool.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'helper.dart';

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}

class BusEncrypt {
  //0 is from first, 1 is from last.
  static int seedDirection;

  static String seedValue;

  BusEncrypt({String jsCode}) {
    jsEncryptCodeParser(jsCode);
  }

  void jsEncryptCodeParser(String content) {
    // http://bus.kuas.edu.tw/API/Scripts/a1
    RegExp seedFromFirstRegex = new RegExp(r"encA2\('((\d|\w){0,32})'");
    RegExp seedFromLastRegex =
        new RegExp(r"encA2\(e(\w|\d|\s|\W){0,3}'((\d|\w){0,32})'\)");

    var firstMatches = seedFromFirstRegex.allMatches(content);
    var lastMatches = seedFromLastRegex.allMatches(content);
    String seedFromFirst;
    String seedFromLast;

    if (firstMatches.length > 0) {
      seedFromFirst = firstMatches.toList()[firstMatches.length - 1].group(1);
    }
    if (lastMatches.length > 0) {
      seedFromLast = lastMatches.toList()[lastMatches.length - 1].group(2);
    }
    findEndString(content, seedFromFirst);
    if (findEndString(content, seedFromFirst) >
        findEndString(content, seedFromLast)) {
      seedDirection = 0;
      seedValue = seedFromFirst;
      return;
    }
    seedDirection = 1;
    seedValue = seedFromLast;
  }

  String encA1(String value) {
    if (seedDirection == null || seedValue == null) {
      throw Exception("Seed get error");
    }
    if (seedDirection == 0) {
      return generateMd5("$seedValue$value");
    }
    return generateMd5("$value$seedValue");
  }

  String loginEncrypt(String username, String password) {
    var g = "419191959";
    var i = "930672927";
    var j = "1088434686";
    var k = "260123741";

    g = generateMd5("J$g");
    i = generateMd5("E$i");
    j = generateMd5("R$j");
    k = generateMd5("Y$k");
    username = generateMd5(username + encA1(g));
    password = generateMd5(username + password + "JERRY" + encA1(i));

    var l = generateMd5(username + password + "KUAS" + encA1(j));
    l = generateMd5(l + username + encA1("ITALAB") + encA1(k));
    l = generateMd5(l + password + "MIS" + k);

    return json.encode({"a": l, "b": g, "c": i, "d": j, "e": k, "f": password});
  }

  int findEndString(String content, String targetString) {
    if (targetString == null) {
      return -1;
    }
    int index = -1;
    int res = 0;
    while (res != -1) {
      res = content.indexOf(targetString, res);
      if (res != -1) {
        index = res;
        res += 1;
      }
    }
    return index;
  }
}

class BusHelper {
  static Dio dio;
  static DioCacheManager _manager;
  static BusHelper _instance;
  static CookieJar cookieJar;

  static int reLoginReTryCountsLimit = 5;
  static int reLoginReTryCounts = 0;

  bool isLogin = false;

  static String userTimeTableSelectCacheKey;
  static String userRecordsCacheKey = "${Helper.username}_busUserRecords";
  static String userViolationRecordsCacheKey =
      "${Helper.username}_busViolationRecords";
  static BusEncrypt busEncryptObject;
  static String busHost = "http://bus.kuas.edu.tw/";

  static BusHelper get instance {
    if (_instance == null) {
      _instance = BusHelper();
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
    if (Helper.isSupportCacheData) {
      _manager =
          DioCacheManager(CacheConfig(baseUrl: "http://bus.kuas.edu.tw"));
      dio.interceptors.add(_manager.interceptor);
      _manager.clearAll();
    }

    cookieJar = CookieJar();
    dio.interceptors.add(PrivateCookieManager(cookieJar));
    dio.options.headers['user-agent'] =
        'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36';
    dio.options.headers['Connection'] = 'close';
    dio.options.connectTimeout = 5000;
    dio.options.receiveTimeout = 5000;
  }

  Future<void> loginPrepare() async {
    // Get global cookie. Only cookies get from the root directory can be used.
    await dio.head(busHost);
    // This function will download encrypt js bus login required.
    var res = await dio.get("http://bus.kuas.edu.tw/API/Scripts/a1");
    busEncryptObject = new BusEncrypt(jsCode: res.data);
  }

  Future<Map<String, dynamic>> busLogin() async {
    /*
    Return type Map<String, dynamic>(from Json)
    response data (from NKUST)
    {
      "success": true,
      "code": 200,
      "message": "User Name",
      "count": 1,
      "data": {}
    }
    Code:
    200: Login success.
    400: Wrong campus or not found user.
    302: Wrong password.
    */
    if (Helper.username == null || Helper.password == null) {
      throw NullThrownError;
    }

    await loginPrepare();

    Response res = await dio.post("${busHost}API/Users/login",
        data: {
          "account": Helper.username,
          "password": Helper.password,
          "n": busEncryptObject.loginEncrypt(Helper.username, Helper.password)
        },
        options: Options(contentType: Headers.formUrlEncodedContentType));

    if (res.data["code"] == 200 && res.data["success"] == true) {
      isLogin = true;
    }
    return res.data;
  }

  Future<BusData> timeTableQuery({
    DateTime fromDateTime,
    String year,
    String month,
    String day,
  }) async {
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw NullThrownError;
    }

    if (!isLogin) {
      await busLogin();
    }
    if (fromDateTime != null) {
      year = fromDateTime.year.toString();
      month = fromDateTime.month.toString();
      day = fromDateTime.day.toString();
    }
    Future<BusReservationsData> userRecord = busReservations();

    userTimeTableSelectCacheKey =
        "${Helper.username}_busCacheTimTable$year$month$day";
    Options _options;
    dynamic _requestData;
    if (!Helper.isSupportCacheData) {
      _requestData = {
        "data": json.encode({"y": year, "m": month, "d": day}),
        'operation': "全部",
        'page': 1,
        'start': 0,
        'limit': 90
      };
      _options = Options(contentType: Headers.formUrlEncodedContentType);
    } else {
      dio.options.headers["Content-Type"] = "application/x-www-form-urlencoded";
      _requestData = formUrlEncoded({
        "data": json.encode({"y": year, "m": month, "d": day}),
        'operation': "全部",
        'page': 1,
        'start': 0,
        'limit': 90
      });
      _options = buildCacheOptions(
        Duration(seconds: 60),
        primaryKey: userTimeTableSelectCacheKey,
      );
    }
    Response res = await dio.post(
      "${busHost}API/Frequencys/getAll",
      data: _requestData,
      options: _options,
    );

    if (res.data["code"] == 400 &&
        res.data["message"].indexOf("未登入或是登入逾") > -1) {
      // Remove fail cache.
      if (Helper.isSupportCacheData) _manager.delete(userTimeTableSelectCacheKey);
      reLoginReTryCounts += 1;
      await busLogin();
      return timeTableQuery(year: year, month: month, day: day);
    }
    reLoginReTryCounts = 0;
    return BusData.fromJson(
      busTimeTableParser(res.data, busReservations: await userRecord),
    );
  }

  Future<BookingBusData> busBook({String busId}) async {
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw NullThrownError;
    }

    if (!isLogin) {
      await busLogin();
    }
    if (Helper.isSupportCacheData) {
      _manager.delete(userRecordsCacheKey);
      _manager.delete(userTimeTableSelectCacheKey);
    }

    Response res = await dio.post(
      "${busHost}API/Reserves/add",
      data: {
        "busId": int.parse(busId),
      },
    );

    if (res.data["code"] == 400 &&
        res.data["message"].indexOf("未登入或是登入逾") > -1) {
      reLoginReTryCounts += 1;
      await busLogin();
      return busBook(busId: busId);
    }
    return BookingBusData.fromJson(res.data);
  }

  Future<CancelBusData> busUnBook({String busId}) async {
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw NullThrownError;
    }

    if (!isLogin) {
      await busLogin();
    }
    Response res = await dio.post(
      "${busHost}API/Reserves/remove",
      data: {
        "reserveId": int.parse(busId),
      },
    );

    if (res.data["code"] == 400 &&
        res.data["message"].indexOf("未登入或是登入逾") > -1) {
      reLoginReTryCounts += 1;
      await busLogin();
      return busUnBook(busId: busId);
    }
    // Clear all cookie, because we can't sure user on which page.
    // two page can cencel bus.
    if (Helper.isSupportCacheData) _manager.clearAll();

    return CancelBusData.fromJson(res.data);
  }

  Future<BusReservationsData> busReservations() async {
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw NullThrownError;
    }

    if (!isLogin) {
      await busLogin();
    }
    Options _options;
    dynamic _requestData;
    if (!Helper.isSupportCacheData) {
      _requestData = {'page': 1, 'start': 0, 'limit': 90};
      _options = Options(contentType: Headers.formUrlEncodedContentType);
    } else {
      dio.options.headers["Content-Type"] = "application/x-www-form-urlencoded";
      _requestData = formUrlEncoded({'page': 1, 'start': 0, 'limit': 90});
      _options = buildCacheOptions(
        Duration(seconds: 60),
        primaryKey: userRecordsCacheKey,
      );
    }

    Response res = await dio.post(
      "${busHost}API/Reserves/getOwn",
      data: _requestData,
      options: _options,
    );

    if (res.data["code"] == 400 &&
        res.data["message"].indexOf("未登入或是登入逾") > -1) {
      if (Helper.isSupportCacheData) _manager.delete(userRecordsCacheKey);
      reLoginReTryCounts += 1;
      await busLogin();
      return busReservations();
    }
    reLoginReTryCounts = 0;
    return BusReservationsData.fromJson(
      busReservationsParser(res.data),
    );
  }

  Future<BusViolationRecordsData> busViolationRecords() async {
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw NullThrownError;
    }

    if (!isLogin) {
      await busLogin();
    }
    Options _options;
    dynamic _requestData;
    if (!Helper.isSupportCacheData) {
      _requestData = {'page': 1, 'start': 0, 'limit': 200};
      _options = Options(contentType: Headers.formUrlEncodedContentType);
    } else {
      dio.options.headers["Content-Type"] = "application/x-www-form-urlencoded";
      _requestData = formUrlEncoded({'page': 1, 'start': 0, 'limit': 200});
      _options = buildCacheOptions(
        Duration(seconds: 60),
        primaryKey: userViolationRecordsCacheKey,
      );
    }

    Response res = await dio.post("${busHost}API/Illegals/getOwn",
        data: _requestData, options: _options);

    if (res.data["code"] == 400 &&
        res.data["message"].indexOf("未登入或是登入逾") > -1) {
      if (Helper.isSupportCacheData) _manager.delete(userViolationRecordsCacheKey);
      reLoginReTryCounts += 1;
      await busLogin();
      return busViolationRecords();
    }
    reLoginReTryCounts = 0;
    return BusViolationRecordsData.fromJson(
      busViolationRecordsParser(res.data),
    );
  }
}
