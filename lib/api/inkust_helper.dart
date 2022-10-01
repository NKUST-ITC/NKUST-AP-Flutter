//dio
import 'dart:convert';
import "dart:math";

import 'package:ap_common/models/course_data.dart';
//overwrite origin Cookie Manager.
import 'package:ap_common/models/private_cookies_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nkust_ap/api/parser/inkust_parser.dart';
import 'package:nkust_ap/models/booking_bus_data.dart';
import 'package:nkust_ap/models/bus_data.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/models/cancel_bus_data.dart';
import 'package:nkust_ap/models/leave_data.dart';
import 'package:nkust_ap/models/leave_submit_data.dart';
import 'package:nkust_ap/models/leave_submit_info_data.dart';

import 'helper.dart';

class InkustHelper {
  InkustHelper() {
    dioInit();
  }

  late Dio dio;
  late DioCacheManager _manager;
  static InkustHelper? _instance;
  late CookieJar cookieJar;

  static int reLoginReTryCountsLimit = 3;
  static int reLoginReTryCounts = 0;
  static String loginApiKey = "";
  static String inkustHost = "inkusts.nkust.edu.tw";

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
  static Map<String, String?> ueserRequestData = {
    "apiKey": null,
    "userId": null,
  };
  static List<String> leavesTimeCode = [
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
    "9",
    "10",
    "11",
    "12",
    "13"
  ];

  bool isLogin = false;

  static InkustHelper get instance {
    return _instance ??= InkustHelper();
  }

  void setProxy(String proxyIP) {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.findProxy = (uri) {
        return "PROXY " + proxyIP;
      };
    };
  }

  void dioInit() {
    dio = Dio();
    cookieJar = CookieJar();
    if (Helper.isSupportCacheData) {
      _manager = DioCacheManager(CacheConfig(baseUrl: "https://$inkustHost"));
      dio.interceptors.add(_manager.interceptor as Interceptor);
    }

    dio.interceptors.add(PrivateCookieManager(cookieJar));

    var headerRandom = ['13_6', '12_4', '14_0', '13_1', '13_5'];
    final _random = new Random();

    dio.options.headers['user-agent'] =
        'Mozilla/5.0 (iPhone; CPU iPhone OS ${headerRandom[_random.nextInt(headerRandom.length)]} like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148';
  }

  Future<Map<String, dynamic>?> login({
    required String? username,
    required String? password,
  }) async {
    if (Helper.username == null || Helper.password == null) {
      throw NullThrownError;
    }
    Response<Map<String, dynamic>> res = await dio.post<Map<String, dynamic>>(
        "https://$inkustHost/User/DoLogin2",
        data: {
          "apiKey": loginApiKey,
          "userId": username,
          "userPw": password,
          "userKeep": 0
        },
        options: Options(contentType: Headers.formUrlEncodedContentType));

    if (res.statusCode == 200 && res.data!["success"] == true) {
      isLogin = true;
      ueserRequestData['apiKey'] = res.data!['data']["userKey"] as String;
      ueserRequestData['userId'] = res.data!['data']["userIdEncrypt"] as String;
    }
    return res.data;
  }

  Future<Map<String, dynamic>?> checkLogin() async {
    return isLogin
        ? null
        : await login(username: Helper.username, password: Helper.password);
  }

  Future<CourseData?> courseTable(String? years, String? semesterValue) async {
    await checkLogin();
    Options _options;
    _options = Options(contentType: Headers.formUrlEncodedContentType);
    if (Helper.isSupportCacheData) {
      _options = buildConfigurableCacheOptions(
          options: _options,
          maxAge: Duration(hours: 1),
          primaryKey: "${coursetableCacheKey}_${years}_$semesterValue");
    }

    var requestData = new Map<String, String?>.from(ueserRequestData);
    requestData.addAll({
      'academicYear': years,
      'academicSms': semesterValue,
    });
    Response<Map<String, dynamic>> res = await dio.post<Map<String, dynamic>>(
        "https://$inkustHost/Course/GetStuCourse2",
        data: requestData,
        options: _options);
    if (res.data!['success'] == false) {
      return null;
    }
    return CourseData.fromJson(inkustCourseTableParser(res.data!));
  }

  Future<BusData?> inkustBusTimeTableQuery({
    DateTime? fromDateTime,
    String? year,
    String? month,
    String? day,
  }) async {
    await checkLogin();
    if (fromDateTime != null) {
      year = fromDateTime.year.toString();
      month = fromDateTime.month.toString();
      day = fromDateTime.day.toString();
    }
    for (int i = 0; month!.length < 2; i++) {
      month = "0" + month;
    }
    for (int i = 0; day!.length < 2; i++) {
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

    Response<Map<String, dynamic>> timeQuery =
        await dio.post<Map<String, dynamic>>(
      'https://$inkustHost/Bus/GetTimetableAndReserve',
      options: _options,
      data: _requestData,
    );
    if (!(timeQuery.data!['success'] as bool)) {
      return null;
    }
    return BusData.fromJson(
      inkustBusTimeTableParser('$year/$month/$day',
          timeQuery.data!['data'] as List<dynamic>, await userRecords),
    );
  }

  Future<BusReservationsData> inkustBusUserRecord() async {
    await checkLogin();

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
        'https://$inkustHost/Bus/GetUserReserve3',
        options: _optionsForDataType,
        data: _requestData,
      );
      responseList.add(_req);
    });

    return BusReservationsData.fromJson(
      await inkustBusUserRecordsParser(responseList),
    );
  }

  Future<BookingBusData> busBook({String? busId}) async {
    await checkLogin();
    var _requestData = new Map<String, String?>.from(ueserRequestData);

    _requestData.addAll({"busId": busId});
    Response<dynamic> request = await dio.post<dynamic>(
      "https://$inkustHost/Bus/CreateUserReserve",
      data: _requestData,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    Map<String, dynamic>? data;

    if (request.data is String &&
        request.headers['Content-Type']![0].indexOf("text/html") > -1) {
      data = jsonDecode(request.data as String) as Map<String, dynamic>;
    } else if (request.data is Map<String, dynamic>) {
      data = request.data as Map<String, dynamic>;
    }
    if (data!['success'] as bool && data['message'] == "預約成功") {
      if (Helper.isSupportCacheData) _manager.clearAll();
      return BookingBusData(success: true);
    }
    return BookingBusData(success: false);
  }

  Future<CancelBusData> busUnBook({String? busId}) async {
    await checkLogin();
    var _requestData = new Map<String, String?>.from(ueserRequestData);

    _requestData.addAll({"resId": busId});
    Response<dynamic> request = await dio.post<dynamic>(
      "https://$inkustHost/Bus/CancelUserReserve",
      data: _requestData,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    Map<String, dynamic>? data;

    if (request.data is String &&
        request.headers['Content-Type']![0].indexOf("text/html") > -1) {
      data = jsonDecode(request.data as String) as Map<String, dynamic>;
    } else if (request.data is Map<String, dynamic>) {
      data = request.data as Map<String, dynamic>;
    }
    if ((data!['success'] as bool) && data['message'] == "取消成功") {
      if (Helper.isSupportCacheData) _manager.clearAll();
      return CancelBusData(success: true);
    }
    return CancelBusData(success: false);
  }

  Future<BusViolationRecordsData> busViolationRecords() async {
    await checkLogin();

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
    Response<dynamic> request = await dio.post<dynamic>(
      "https://$inkustHost/Bus/GetUserIllegal2",
      data: _requestData,
      options: _options,
    );
    Map<String, dynamic>? data;

    if (request.data is String &&
        request.headers['Content-Type']![0].indexOf("text/html") > -1) {
      data = jsonDecode(request.data as String) as Map<String, dynamic>;
    } else if (request.data is Map<String, dynamic>) {
      data = request.data as Map<String, dynamic>;
    }
    return BusViolationRecordsData.fromJson(
      inkustBusViolationRecordsParser(data!),
    );
  }

  Future<LeaveData> getAbsentRecords({String? year, String? semester}) async {
    await checkLogin();

    var _requestData = new Map<String, dynamic>.from(ueserRequestData);

    _requestData.addAll({
      'academicYear': year,
      'academicSms': semester,
    });
    Response<dynamic> request = await dio.post<dynamic>(
      "https://$inkustHost/Leave/GetStuApply",
      data: _requestData,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    Map<String, dynamic>? data;

    if (request.data is String &&
        request.headers['Content-Type']![0].indexOf("text/html") > -1) {
      data = jsonDecode(request.data as String) as Map<String, dynamic>;
    } else if (request.data is Map<String, dynamic>) {
      data = request.data as Map<String, dynamic>;
    }

    return LeaveData.fromJson(
        inkustgetAbsentRecordsParser(data!, timeCodes: leavesTimeCode));
  }

  Future<LeaveSubmitInfoData> getLeavesSubmitInfo() async {
    await checkLogin();
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
      "https://$inkustHost/Leave/GetInsertInfo",
      data: _requestData,
      options: leaveTypeOptions,
    );
    Response<dynamic> totorRequest = await dio.post<dynamic>(
      "https://$inkustHost/Leave/GetTeacher2",
      data: _requestData,
      options: totorRecordsOptions,
    );

    Map<String, dynamic>? leaveTypeOptionData;
    Map<String, dynamic>? totorRecordsData;

    if (leaveTypeOptionRequest.data is String &&
        leaveTypeOptionRequest.headers['Content-Type']![0]
                .indexOf("text/html") >
            -1) {
      leaveTypeOptionData = jsonDecode(leaveTypeOptionRequest.data as String)
          as Map<String, dynamic>;
    } else if (leaveTypeOptionRequest.data is Map<String, dynamic>) {
      leaveTypeOptionData = leaveTypeOptionRequest.data as Map<String, dynamic>;
    }
    if (totorRequest.data is String &&
        totorRequest.headers['Content-Type']![0].indexOf("text/html") > -1) {
      totorRecordsData =
          jsonDecode(totorRequest.data as String) as Map<String, dynamic>;
    } else if (totorRequest.data is Map<String, dynamic>) {
      totorRecordsData = totorRequest.data as Map<String, dynamic>;
    }

    return LeaveSubmitInfoData.fromJson(
      inkustGetLeaveSubmitInfoParser(
          leaveTypeOptionData, totorRecordsData!, leavesTimeCode),
    );
  }

  Future<Response?> leavesSubmit(LeaveSubmitData data,
      {PickedFile? proofImage}) async {
    await checkLogin();

    var userInfo = await Helper.instance.getUsersInfo();
    var nowSemester = await Helper.instance.getSemester();
    bool proofImageExists = false;
    if (proofImage != null) {
      proofImageExists = true;
    }

    var requestDataList = inkustLeaveDataParser(
      submitDatas: data,
      semester: nowSemester,
      stdId: userInfo!.id,
      proofImageExists: proofImageExists,
      timeCode: leavesTimeCode,
    );
    Response<dynamic>? res;
    if (proofImageExists) {
      for (int i = 0; i < requestDataList.length; i++) {
        Map<String, dynamic> _requestData =
            new Map<String, dynamic>.from(ueserRequestData);
        _requestData['insertData'] = json.encode(requestDataList[i]);

        _requestData["file"] = await MultipartFile.fromFile(
          proofImage!.path,
          filename: "proof.jpg",
          contentType: MediaType.parse("image/jpeg"),
        );

        FormData formData = FormData.fromMap(_requestData);
        res = await dio.post(
          "https://$inkustHost/Leave/DoSaveApply2",
          data: formData,
        );
      }
    } else {
      for (int i = 0; i < requestDataList.length; i++) {
        Map<String, dynamic> _requestData =
            new Map<String, dynamic>.from(ueserRequestData);
        _requestData['insertData'] = json.encode(requestDataList[i]);
        res = await dio.post(
          "https://$inkustHost/Leave/DoSaveApply2",
          data: _requestData,
          options: Options(contentType: Headers.formUrlEncodedContentType),
        );
      }
    }

    return res;
  }
}
