//dio
import 'dart:convert';

import 'package:ap_common/models/course_data.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:cookie_jar/cookie_jar.dart';

//overwrite origin Cookie Manager.
import 'package:nkust_ap/api/private_cookie_manager.dart';
import "dart:math";
import 'helper.dart';
import 'package:nkust_ap/api/parser/inkust_parser.dart';

import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/models/bus_data.dart';
import 'package:nkust_ap/models/booking_bus_data.dart';
import 'package:nkust_ap/models/cancel_bus_data.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/models/leave_data.dart';
import 'package:nkust_ap/models/leave_submit_info_data.dart';

class InkustHelper {
  static Dio dio;
  static DioCacheManager _manager;
  static InkustHelper _instance;
  static CookieJar cookieJar;

  static int reLoginReTryCountsLimit = 3;
  static int reLoginReTryCounts = 0;
  static String loginApiKey = "";
  static String host = "inkusts.nkust.edu.tw";
  static String get coursetableCacheKey =>
      "${Helper.username}_coursetableCacheKey";
  static String get busUserRecordsCacheKey =>
      "${Helper.username}_busUserRecords";
  static String userViolationRecordsCacheKey =
      "${Helper.username}_busViolationRecords";
  static String get userLeaveSubmitInfoCacheKey =>
      "${Helper.username}_userLeaveSubmitInfo";
  static String get userLeaveTutorsCacheKey =>
      "${Helper.username}_userLeaveTutors";
  static Map<String, String> ueserRequestData = {
    "apiKey": null,
    "userId": null,
  };

  bool isLogin = false;

  static InkustHelper get instance {
    if (_instance == null) {
      _instance = InkustHelper();
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
    dio = Dio();
    cookieJar = CookieJar();
    if (Helper.isSupportCacheData) {
      _manager = DioCacheManager(CacheConfig(baseUrl: "https://${host}"));
      dio.interceptors.add(_manager.interceptor);
    }

    dio.interceptors.add(PrivateCookieManager(cookieJar));

    var headerRandom = ['13_6', '12_4', '14_0', '13_1', '13_5'];
    final _random = new Random();

    dio.options.headers['user-agent'] =
        'Mozilla/5.0 (iPhone; CPU iPhone OS ${headerRandom[_random.nextInt(headerRandom.length)]} like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148';
  }

  Future<Map<String, dynamic>> inkustLogin() async {
    if (Helper.username == null || Helper.password == null) {
      throw NullThrownError;
    }
    Response res = await dio.post("https://${host}/User/DoLogin2",
        data: {
          "apiKey": loginApiKey,
          "userId": Helper.username,
          "userPw": Helper.password,
          "userKeep": 0
        },
        options: Options(contentType: Headers.formUrlEncodedContentType));

    if (res.statusCode == 200 && res.data["success"] == true) {
      isLogin = true;
      ueserRequestData['apiKey'] = res.data['data']["userKey"];
      ueserRequestData['userId'] = res.data['data']["userIdEncrypt"];
    }
    return res.data;
  }

  Future<CourseData> courseTable(String years, String semesterValue) async {
    if (isLogin != true) {
      await inkustLogin();
    }
    Options _options;
    _options = Options(contentType: Headers.formUrlEncodedContentType);
    if (Helper.isSupportCacheData) {
      _options = buildConfigurableCacheOptions(
          options: _options,
          maxAge: Duration(hours: 1),
          primaryKey: "${coursetableCacheKey}_${years}_${semesterValue}");
    }

    var requestData = new Map<String, String>.from(ueserRequestData);
    requestData.addAll({
      'academicYear': years,
      'academicSms': semesterValue,
    });
    Response res = await dio.post("https://${host}/Course/GetStuCourse2",
        data: requestData, options: _options);
    if (res.data['success'] == false) {
      return null;
    }
    return CourseData.fromJson(inkustCourseTableParser(res.data));
  }

  Future<BusData> inkustBusTimeTableQuery({
    DateTime fromDateTime,
    String year,
    String month,
    String day,
  }) async {
    if (isLogin != true) {
      await inkustLogin();
    }
    if (fromDateTime != null) {
      year = fromDateTime.year.toString();
      month = fromDateTime.month.toString();
      day = fromDateTime.day.toString();
    }
    for (int i = 0; month.length < 2; i++) {
      month = "0" + month;
    }
    for (int i = 0; day.length < 2; i++) {
      day = "0" + day;
    }
    Future<BusReservationsData> userRecords = inkustBusUserRecord();
    Options _options;
    _options = Options(contentType: Headers.formUrlEncodedContentType);
    if (Helper.isSupportCacheData) {
      String userTimeTableSelectCacheKey =
          "${Helper.username}_busCacheTimTable$year$month$day";
      _options = buildConfigurableCacheOptions(
          options: _options,
          maxAge: Duration(minutes: 5),
          primaryKey: userTimeTableSelectCacheKey);
    }
    var _requestData = new Map<String, String>.from(ueserRequestData);
    _requestData.addAll({'driveDate': '$year/$month/$day'});

    var timeQuery = await dio.post(
      'https://inkusts.nkust.edu.tw/Bus/GetTimetableAndReserve',
      options: _options,
      data: _requestData,
    );
    if (!timeQuery.data['success']) {
      return null;
    }
    return BusData.fromJson(
      inkustBusTimeTableParser(
          '$year/$month/$day', timeQuery.data['data'], await userRecords),
    );
  }

  Future<BusReservationsData> inkustBusUserRecord() async {
    if (isLogin != true) {
      await inkustLogin();
    }

    Options _optionsForDataType;
    _optionsForDataType =
        Options(contentType: Headers.formUrlEncodedContentType);

    List<List<String>> queryData = [
      ['燕巢', '建工'],
      ['建工', '燕巢'],
      ['建工', '第一'],
      ['第一', '建工']
    ];
    List<Future<Response>> responseList = [];
    queryData.forEach((element) {
      var _requestData = new Map<String, String>.from(ueserRequestData);
      _requestData.addAll({
        'state': '0',
        'startStation': element[0],
        'endStation': element[1],
        'page': '1',
        'start': '0',
        'limit': '99'
      });
      if (Helper.isSupportCacheData) {
        _optionsForDataType = buildConfigurableCacheOptions(
            options: _optionsForDataType,
            maxAge: Duration(minutes: 5),
            primaryKey:
                "${busUserRecordsCacheKey}_${element[0]}_${element[1]}");
      }
      Future<Response<dynamic>> _req = dio.post(
        'https://inkusts.nkust.edu.tw/Bus/GetUserReserve3',
        options: _optionsForDataType,
        data: _requestData,
      );
      responseList.add(_req);
    });

    return BusReservationsData.fromJson(
      await inkustBusUserRecordsParser(responseList),
    );
  }

  Future<BookingBusData> busBook({String busId}) async {
    if (isLogin != true) {
      await inkustLogin();
    }
    var _requestData = new Map<String, String>.from(ueserRequestData);

    _requestData.addAll({"busId": busId});
    var request = await dio.post(
      "https://inkusts.nkust.edu.tw/Bus/CreateUserReserve",
      data: _requestData,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    Map<String, dynamic> data;

    if (request.data is String &&
        request.headers['Content-Type'][0].indexOf("text/html") > -1) {
      data = jsonDecode(request.data);
    } else if (request.data is Map<String, dynamic>) {
      data = request.data;
    }
    if (data['success'] && data['message'] == "預約成功") {
      if (Helper.isSupportCacheData) _manager.clearAll();
      return BookingBusData(success: true);
    }
    return BookingBusData(success: false);
  }

  Future<CancelBusData> busUnBook({String busId}) async {
    if (isLogin != true) {
      await inkustLogin();
    }
    var _requestData = new Map<String, String>.from(ueserRequestData);

    _requestData.addAll({"resId": busId});
    var request = await dio.post(
      "https://inkusts.nkust.edu.tw/Bus/CancelUserReserve",
      data: _requestData,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    Map<String, dynamic> data;

    if (request.data is String &&
        request.headers['Content-Type'][0].indexOf("text/html") > -1) {
      data = jsonDecode(request.data);
    } else if (request.data is Map<String, dynamic>) {
      data = request.data;
    }
    if (data['success'] && data['message'] == "取消成功") {
      if (Helper.isSupportCacheData) _manager.clearAll();
      return CancelBusData(success: true);
    }
    return CancelBusData(success: false);
  }

  Future<BusViolationRecordsData> busViolationRecords() async {
    if (isLogin != true) {
      await inkustLogin();
    }

    var _requestData = new Map<String, dynamic>.from(ueserRequestData);
    Options _options;
    _options = Options(contentType: Headers.formUrlEncodedContentType);
    if (Helper.isSupportCacheData) {
      _options = buildConfigurableCacheOptions(
          options: _options,
          maxAge: Duration(minutes: 5),
          primaryKey: userViolationRecordsCacheKey);
    }

    _requestData.addAll({'paid': 1, 'page': 1, 'start': 0, 'limit': 100});
    var request = await dio.post(
      "https://inkusts.nkust.edu.tw/Bus/GetUserIllegal2",
      data: _requestData,
      options: _options,
    );
    Map<String, dynamic> data;

    if (request.data is String &&
        request.headers['Content-Type'][0].indexOf("text/html") > -1) {
      data = jsonDecode(request.data);
    } else if (request.data is Map<String, dynamic>) {
      data = request.data;
    }
    return BusViolationRecordsData.fromJson(
      inkustBusViolationRecordsParser(data),
    );
  }

  Future<LeaveData> getAbsentRecords({String year, String semester}) async {
    if (isLogin != true) {
      await inkustLogin();
    }

    var _requestData = new Map<String, dynamic>.from(ueserRequestData);

    _requestData.addAll({
      'academicYear': year,
      'academicSms': semester,
    });
    var request = await dio.post(
      "https://inkusts.nkust.edu.tw/Leave/GetStuApply",
      data: _requestData,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    // TODO: Need flexible solution, remote config?
    List leavesTimeCodes = [
      "A",
      "1",
      "2",
      "3",
      "4",
      "B",
      "5",
      "6",
      "7",
      "8",
      "C",
      "11",
      "12",
      "13",
      "14"
    ];

    Map<String, dynamic> data;

    if (request.data is String &&
        request.headers['Content-Type'][0].indexOf("text/html") > -1) {
      data = jsonDecode(request.data);
    } else if (request.data is Map<String, dynamic>) {
      data = request.data;
    }

    return LeaveData.fromJson(
        inkustgetAbsentRecordsParser(data, timeCodes: leavesTimeCodes));
  }

  Future<LeaveSubmitInfoData> getLeavesSubmitInfo() async {
    if (isLogin != true) {
      await inkustLogin();
    }
    Options leaveTypeOptions =
        Options(contentType: Headers.formUrlEncodedContentType);
    Options totorRecordsOptions =
        Options(contentType: Headers.formUrlEncodedContentType);

    if (Helper.isSupportCacheData) {
      leaveTypeOptions = buildConfigurableCacheOptions(
          options: leaveTypeOptions,
          maxAge: Duration(hours: 24),
          primaryKey: userLeaveSubmitInfoCacheKey);
      totorRecordsOptions = buildConfigurableCacheOptions(
          options: totorRecordsOptions,
          maxAge: Duration(hours: 24),
          primaryKey: userLeaveTutorsCacheKey);
    }
    var _requestData = new Map<String, dynamic>.from(ueserRequestData);

    var leaveTypeOptionRequest = await dio.post(
      "https://inkusts.nkust.edu.tw/Leave/GetInsertInfo",
      data: _requestData,
      options: leaveTypeOptions,
    );
    var totorRequest = await dio.post(
      "https://inkusts.nkust.edu.tw/Leave/GetTeacher2",
      data: _requestData,
      options: totorRecordsOptions,
    );
    // TODO: Need flexible solution, remote config?
    List leavesTimeCodes = [
      "A",
      "1",
      "2",
      "3",
      "4",
      "B",
      "5",
      "6",
      "7",
      "8",
      "C",
      "11",
      "12",
      "13",
      "14"
    ];

    Map<String, dynamic> leaveTypeOptionData;
    Map<String, dynamic> totorRecordsData;

    if (leaveTypeOptionRequest.data is String &&
        leaveTypeOptionRequest.headers['Content-Type'][0].indexOf("text/html") >
            -1) {
      leaveTypeOptionData = jsonDecode(leaveTypeOptionRequest.data);
    } else if (leaveTypeOptionRequest.data is Map<String, dynamic>) {
      leaveTypeOptionData = leaveTypeOptionRequest.data;
    }
    if (totorRequest.data is String &&
        totorRequest.headers['Content-Type'][0].indexOf("text/html") > -1) {
      totorRecordsData = jsonDecode(totorRequest.data);
    } else if (totorRequest.data is Map<String, dynamic>) {
      totorRecordsData = totorRequest.data;
    }

    return LeaveSubmitInfoData.fromJson(
      inkustGetLeaveSubmitInfoParser(
          leaveTypeOptionData, totorRecordsData, leavesTimeCodes),
    );
  }
}
