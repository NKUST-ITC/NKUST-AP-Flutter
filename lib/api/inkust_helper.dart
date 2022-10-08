//dio
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ap_common/models/course_data.dart';
//overwrite origin Cookie Manager.
import 'package:ap_common/models/private_cookies_manager.dart';
import 'package:ap_common/models/semester_data.dart';
import 'package:ap_common/models/user_info.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:http_parser/http_parser.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/api/parser/inkust_parser.dart';
import 'package:nkust_ap/models/booking_bus_data.dart';
import 'package:nkust_ap/models/bus_data.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/models/cancel_bus_data.dart';
import 'package:nkust_ap/models/leave_data.dart';
import 'package:nkust_ap/models/leave_submit_data.dart';
import 'package:nkust_ap/models/leave_submit_info_data.dart';

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
  static String loginApiKey = '';
  static String inkustHost = 'inkusts.nkust.edu.tw';

  static String get coursetableCacheKey =>
      '${Helper.username}_coursetableCacheKey';

  static String get busUserRecordsCacheKey =>
      '${Helper.username}_busUserRecords';
  static String userViolationRecordsCacheKey =
      '${Helper.username}_busViolationRecords';

  static String get userLeaveSubmitInfoCacheKey =>
      '${Helper.username}_userLeaveSubmitInfo';

  static String get userLeaveTutorsCacheKey =>
      '${Helper.username}_userLeaveTutors';
  static Map<String, String?> ueserRequestData = <String, String?>{
    'apiKey': null,
    'userId': null,
  };
  static List<String> leavesTimeCode = <String>[
    'A',
    '1',
    '2',
    '3',
    '4',
    'B',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13'
  ];

  bool isLogin = false;

  //ignore: prefer_constructors_over_static_methods
  static InkustHelper get instance {
    return _instance ??= InkustHelper();
  }

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
    dio = Dio();
    cookieJar = CookieJar();
    if (Helper.isSupportCacheData) {
      _manager = DioCacheManager(CacheConfig(baseUrl: 'https://$inkustHost'));
      dio.interceptors.add(_manager.interceptor as Interceptor);
    }

    dio.interceptors.add(PrivateCookieManager(cookieJar));

    final List<String> headerRandom = <String>[
      '13_6',
      '12_4',
      '14_0',
      '13_1',
      '13_5'
    ];
    final Random random = Random();

    dio.options.headers['user-agent'] =
        'Mozilla/5.0 (iPhone; CPU iPhone OS ${headerRandom[random.nextInt(headerRandom.length)]} like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148';
  }

  Future<Map<String, dynamic>?> login({
    required String? username,
    required String? password,
  }) async {
    if (Helper.username == null || Helper.password == null) {
      throw NullThrownError;
    }
    final Response<Map<String, dynamic>> res =
        await dio.post<Map<String, dynamic>>(
      'https://$inkustHost/User/DoLogin2',
      data: <String, dynamic>{
        'apiKey': loginApiKey,
        'userId': username,
        'userPw': password,
        'userKeep': 0
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    if (res.statusCode == 200 && res.data!['success'] == true) {
      isLogin = true;
      final Map<String, dynamic> dataMap =
          res.data!['data'] as Map<String, dynamic>;
      ueserRequestData['apiKey'] = dataMap['userKey'] as String;
      ueserRequestData['userId'] = dataMap['userIdEncrypt'] as String;
    }
    return res.data;
  }

  Future<Map<String, dynamic>?> checkLogin() async {
    return isLogin
        ? null
        : await login(username: Helper.username, password: Helper.password);
  }

  Future<CourseData?> courseTable(String years, String semesterValue) async {
    await checkLogin();
    Options options;
    options = Options(contentType: Headers.formUrlEncodedContentType);
    if (Helper.isSupportCacheData) {
      options = buildConfigurableCacheOptions(
        options: options,
        maxAge: const Duration(hours: 1),
        primaryKey: '${coursetableCacheKey}_${years}_$semesterValue',
      );
    }

    final Map<String, String?> requestData =
        Map<String, String?>.from(ueserRequestData);
    requestData.addAll(<String, String>{
      'academicYear': years,
      'academicSms': semesterValue,
    });
    final Response<Map<String, dynamic>> res =
        await dio.post<Map<String, dynamic>>(
      'https://$inkustHost/Course/GetStuCourse2',
      data: requestData,
      options: options,
    );
    if (res.data!['success'] == false) {
      return null;
    }
    return CourseData.fromJson(inkustCourseTableParser(res.data!));
  }

  Future<BusData?> inkustBusTimeTableQuery({
    required DateTime fromDateTime,
  }) async {
    await checkLogin();
    final String year = fromDateTime.year.toString();
    String month = fromDateTime.month.toString();
    String day = fromDateTime.day.toString();
    for (int i = 0; month.length < 2; i++) {
      month = '0$month';
    }
    for (int i = 0; day.length < 2; i++) {
      day = '0$day';
    }
    final Future<BusReservationsData> userRecords = inkustBusUserRecord();
    Options options;
    options = Options(contentType: Headers.formUrlEncodedContentType);
    if (Helper.isSupportCacheData) {
      final String userTimeTableSelectCacheKey =
          '${Helper.username}_busCacheTimTable$year$month$day';
      options = buildConfigurableCacheOptions(
        options: options,
        maxAge: const Duration(minutes: 5),
        primaryKey: userTimeTableSelectCacheKey,
      );
    }
    final Map<String, String> requestData =
        Map<String, String>.from(ueserRequestData);
    requestData.addAll(<String, String>{'driveDate': '$year/$month/$day'});

    final Response<Map<String, dynamic>> timeQuery =
        await dio.post<Map<String, dynamic>>(
      'https://$inkustHost/Bus/GetTimetableAndReserve',
      options: options,
      data: requestData,
    );
    if (!(timeQuery.data!['success'] as bool)) {
      return null;
    }
    return BusData.fromJson(
      inkustBusTimeTableParser(
        '$year/$month/$day',
        timeQuery.data!['data'] as List<dynamic>,
        await userRecords,
      ),
    );
  }

  Future<BusReservationsData> inkustBusUserRecord() async {
    await checkLogin();

    Options optionsForDataType;
    optionsForDataType =
        Options(contentType: Headers.formUrlEncodedContentType);

    final List<List<String>> queryData = <List<String>>[
      <String>['燕巢', '建工'],
      <String>['建工', '燕巢'],
      <String>['建工', '第一'],
      <String>['第一', '建工']
    ];
    final List<Future<Response<dynamic>>> responseList =
        <Future<Response<dynamic>>>[];
    for (final List<String> element in queryData) {
      final Map<String, String> requestData =
          Map<String, String>.from(ueserRequestData);
      requestData.addAll(<String, String>{
        'state': '0',
        'startStation': element[0],
        'endStation': element[1],
        'page': '1',
        'start': '0',
        'limit': '99'
      });
      if (Helper.isSupportCacheData) {
        optionsForDataType = buildConfigurableCacheOptions(
          options: optionsForDataType,
          maxAge: const Duration(minutes: 5),
          primaryKey: '${busUserRecordsCacheKey}_${element[0]}_${element[1]}',
        );
      }
      final Future<Response<dynamic>> req = dio.post(
        'https://$inkustHost/Bus/GetUserReserve3',
        options: optionsForDataType,
        data: requestData,
      );
      responseList.add(req);
    }

    return BusReservationsData.fromJson(
      await inkustBusUserRecordsParser(responseList),
    );
  }

  Future<BookingBusData> busBook({
    required String busId,
  }) async {
    await checkLogin();
    final Map<String, String?> requestData =
        Map<String, String?>.from(ueserRequestData);

    requestData.addAll(
      <String, String>{
        'busId': busId,
      },
    );
    final Response<dynamic> request = await dio.post<dynamic>(
      'https://$inkustHost/Bus/CreateUserReserve',
      data: requestData,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    Map<String, dynamic>? data;

    if (request.data is String &&
        request.headers['Content-Type']![0].contains('text/html')) {
      data = jsonDecode(request.data as String) as Map<String, dynamic>;
    } else if (request.data is Map<String, dynamic>) {
      data = request.data as Map<String, dynamic>;
    }
    if (data!['success'] as bool && data['message'] == '預約成功') {
      if (Helper.isSupportCacheData) _manager.clearAll();
      return BookingBusData(success: true);
    }
    return BookingBusData(success: false);
  }

  Future<CancelBusData> busUnBook({
    required String busId,
  }) async {
    await checkLogin();
    final Map<String, String?> requestData =
        Map<String, String?>.from(ueserRequestData);

    requestData.addAll(<String, String>{'resId': busId});
    final Response<dynamic> request = await dio.post<dynamic>(
      'https://$inkustHost/Bus/CancelUserReserve',
      data: requestData,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    Map<String, dynamic>? data;

    if (request.data is String &&
        request.headers['Content-Type']![0].contains('text/html')) {
      data = jsonDecode(request.data as String) as Map<String, dynamic>;
    } else if (request.data is Map<String, dynamic>) {
      data = request.data as Map<String, dynamic>;
    }
    if ((data!['success'] as bool) && data['message'] == '取消成功') {
      if (Helper.isSupportCacheData) _manager.clearAll();
      return CancelBusData(success: true);
    }
    return CancelBusData(success: false);
  }

  Future<BusViolationRecordsData> busViolationRecords() async {
    await checkLogin();

    final Map<String, dynamic> requestData =
        Map<String, dynamic>.from(ueserRequestData);
    Options options;
    options = Options(contentType: Headers.formUrlEncodedContentType);
    if (Helper.isSupportCacheData) {
      options = buildConfigurableCacheOptions(
        options: options,
        maxAge: const Duration(minutes: 5),
        primaryKey: userViolationRecordsCacheKey,
      );
    }

    requestData.addAll(
      <String, int>{
        'paid': 1,
        'page': 1,
        'start': 0,
        'limit': 100,
      },
    );
    final Response<dynamic> request = await dio.post<dynamic>(
      'https://$inkustHost/Bus/GetUserIllegal2',
      data: requestData,
      options: options,
    );
    Map<String, dynamic>? data;

    if (request.data is String &&
        request.headers['Content-Type']![0].contains('text/html')) {
      data = jsonDecode(request.data as String) as Map<String, dynamic>;
    } else if (request.data is Map<String, dynamic>) {
      data = request.data as Map<String, dynamic>;
    }
    return BusViolationRecordsData.fromJson(
      inkustBusViolationRecordsParser(data!),
    );
  }

  Future<LeaveData> getAbsentRecords({
    required String year,
    required String semester,
  }) async {
    await checkLogin();

    final Map<String, dynamic> requestData =
        Map<String, dynamic>.from(ueserRequestData);

    requestData.addAll(<String, String>{
      'academicYear': year,
      'academicSms': semester,
    });
    final Response<dynamic> request = await dio.post<dynamic>(
      'https://$inkustHost/Leave/GetStuApply',
      data: requestData,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    Map<String, dynamic>? data;

    if (request.data is String &&
        request.headers['Content-Type']![0].contains('text/html')) {
      data = jsonDecode(request.data as String) as Map<String, dynamic>;
    } else if (request.data is Map<String, dynamic>) {
      data = request.data as Map<String, dynamic>;
    }

    return LeaveData.fromJson(
      inkustgetAbsentRecordsParser(data!, timeCodes: leavesTimeCode),
    );
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
        maxAge: const Duration(hours: 24),
        primaryKey: userLeaveSubmitInfoCacheKey,
      );
      totorRecordsOptions = buildConfigurableCacheOptions(
        options: totorRecordsOptions,
        maxAge: const Duration(hours: 24),
        primaryKey: userLeaveTutorsCacheKey,
      );
    }
    final Map<String, dynamic> requestData =
        Map<String, dynamic>.from(ueserRequestData);

    final Response<dynamic> leaveTypeOptionRequest = await dio.post(
      'https://$inkustHost/Leave/GetInsertInfo',
      data: requestData,
      options: leaveTypeOptions,
    );
    final Response<dynamic> totorRequest = await dio.post<dynamic>(
      'https://$inkustHost/Leave/GetTeacher2',
      data: requestData,
      options: totorRecordsOptions,
    );

    Map<String, dynamic>? leaveTypeOptionData;
    Map<String, dynamic>? totorRecordsData;

    if (leaveTypeOptionRequest.data is String &&
        leaveTypeOptionRequest.headers['Content-Type']![0]
            .contains('text/html')) {
      leaveTypeOptionData = jsonDecode(leaveTypeOptionRequest.data as String)
          as Map<String, dynamic>;
    } else if (leaveTypeOptionRequest.data is Map<String, dynamic>) {
      leaveTypeOptionData = leaveTypeOptionRequest.data as Map<String, dynamic>;
    }
    if (totorRequest.data is String &&
        totorRequest.headers['Content-Type']![0].contains('text/html')) {
      totorRecordsData =
          jsonDecode(totorRequest.data as String) as Map<String, dynamic>;
    } else if (totorRequest.data is Map<String, dynamic>) {
      totorRecordsData = totorRequest.data as Map<String, dynamic>;
    }

    return LeaveSubmitInfoData.fromJson(
      inkustGetLeaveSubmitInfoParser(
        leaveTypeOptionData,
        totorRecordsData!,
        leavesTimeCode,
      ),
    );
  }

  Future<Response<dynamic>?> leavesSubmit(
    LeaveSubmitData data, {
    PickedFile? proofImage,
  }) async {
    await checkLogin();

    final UserInfo? userInfo = await Helper.instance.getUsersInfo();
    final SemesterData? nowSemester = await Helper.instance.getSemester();
    bool proofImageExists = false;
    if (proofImage != null) {
      proofImageExists = true;
    }

    final List<Map<String, dynamic>> requestDataList = inkustLeaveDataParser(
      submitDatas: data,
      semester: nowSemester,
      stdId: userInfo!.id,
      proofImageExists: proofImageExists,
      timeCode: leavesTimeCode,
    );
    Response<dynamic>? res;
    if (proofImageExists) {
      for (int i = 0; i < requestDataList.length; i++) {
        final Map<String, dynamic> requestData =
            Map<String, dynamic>.from(ueserRequestData);
        requestData['insertData'] = json.encode(requestDataList[i]);

        requestData['file'] = await MultipartFile.fromFile(
          proofImage!.path,
          filename: 'proof.jpg',
          contentType: MediaType.parse('image/jpeg'),
        );

        final FormData formData = FormData.fromMap(requestData);
        res = await dio.post(
          'https://$inkustHost/Leave/DoSaveApply2',
          data: formData,
        );
      }
    } else {
      for (int i = 0; i < requestDataList.length; i++) {
        final Map<String, dynamic> requestData =
            Map<String, dynamic>.from(ueserRequestData);
        requestData['insertData'] = json.encode(requestDataList[i]);
        res = await dio.post(
          'https://$inkustHost/Leave/DoSaveApply2',
          data: requestData,
          options: Options(contentType: Headers.formUrlEncodedContentType),
        );
      }
    }

    return res;
  }
}
