import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ap_common/ap_common.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:nkust_ap/api/ap_helper.dart';
import 'package:nkust_ap/api/ap_status_code.dart';
import 'package:nkust_ap/api/api_config.dart';
import 'package:nkust_ap/api/parser/mobile_nkust_parser.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/booking_bus_data.dart';
import 'package:nkust_ap/models/bus_data.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/models/cancel_bus_data.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';
import 'package:nkust_ap/models/mobile_cookies_data.dart';
import 'package:nkust_ap/api/capability/bus_provider.dart';
import 'package:nkust_ap/api/capability/course_provider.dart';
import 'package:nkust_ap/api/capability/score_provider.dart';
import 'package:nkust_ap/api/capability/user_info_provider.dart';
import 'package:nkust_ap/pages/mobile_nkust_page.dart';

class MobileNkustHelper
    implements CourseProvider, ScoreProvider, UserInfoProvider, BusProvider {
  static const String baseUrl = 'https://mobile.nkust.edu.tw/';
  static const String busBaseUrl = 'https://vms.nkust.edu.tw/';

  static const String loginUrl = baseUrl;
  static const String homeUrl = '${baseUrl}Home/Index';
  static const String courseUrl = '${baseUrl}Student/Course';
  static const String scoreUrl = '${baseUrl}Student/Grades';
  static const String pictureUrl = '${baseUrl}Common/GetStudentPhoto';
  static const String midAlertsUrl = '${baseUrl}Student/Grades/MidWarning';
  static const String studentLeavePageUrl = '${baseUrl}Student/Leave';
  static const String mobileBusTimetablePageUrl = '${baseUrl}Bus/Timetable';
  static const String busTimetablePageUrl = '${busBaseUrl}Bus/Bus/Timetable';
  static const String busTimetableApiUrl =
      '${busBaseUrl}Bus/Bus/GetTimetableGrid';
  static const String busBookApiUrl = '${busBaseUrl}Bus/Bus/CreateReserve';
  static const String busUnbookApiUrl = '${busBaseUrl}Bus/Bus/CancelReserve';
  static const String busUserRecordPageUrl = '${busBaseUrl}Bus/Bus/Reserve';
  static const String busUserRecordApiUrl =
      '${busBaseUrl}Bus/Bus/GetReserveGrid';
  static const String busViolationRecordsPageUrl =
      '${busBaseUrl}Bus/Bus/Illegal';
  static const String busViolationRecordsApiUrl =
      '${busBaseUrl}Bus/Bus/GetIllegalGrid';
  static const String checkExpireUrl = '${baseUrl}Account/CheckExpire';

  static MobileNkustHelper? _instance;

  static bool get isSupport =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  late Dio dio;
  late CookieJar cookieJar;

  MobileCookiesData? cookiesData;

  static List<String> userAgentList = <String>[
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Safari/605.1.15',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:120.0) Gecko/20100101 Firefox/120.0',
  ];

  String? get userAgent => dio.options.headers['user-agent'] as String?;

  MobileNkustHelper() {
    _initDio();
  }

  static MobileNkustHelper get instance => _instance ??= MobileNkustHelper();

  void _initDio() {
    final random = Random();
    final userAgent = userAgentList[random.nextInt(userAgentList.length)];

    dio = Dio(
      BaseOptions(
        followRedirects: false,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: <String, String>{
          'user-agent': userAgent,
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Encoding': 'gzip, deflate, br',
          'Accept-Language': 'zh-TW,zh;q=0.9,en-US;q=0.8,en;q=0.7',
          'Connection': 'keep-alive',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS || Platform.isAndroid)) {
      dio.httpClientAdapter = NativeAdapter();
    }

    _initCookiesJar();
  }

  void _initCookiesJar() {
    cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
    dio.interceptors.add(PrivateCookieManager(WebApHelper.instance.cookieJar));
    cookieJar.loadForRequest(Uri.parse(baseUrl));
  }

  void setProxy(String proxyIP) {
    if (kIsWeb) return;

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.findProxy = (uri) => 'PROXY $proxyIP';
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };
  }

  void setCookieFromData(MobileCookiesData data) {
    cookiesData = data;
    for (final element in data.cookies) {
      final tempCookie = Cookie(element.name, element.value)
        ..domain = element.domain;
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
    final tempCookie = Cookie(cookieName, cookieValue)..domain = cookieDomain;
    cookieJar.saveFromResponse(Uri.parse(url), <Cookie>[tempCookie]);
  }

  Future<bool> isCookieAlive() async {
    try {
      final res = await dio.get<dynamic>(
        checkExpireUrl,
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return res.data == 'alive';
    } catch (_) {
      return false;
    }
  }

  Future<Response<dynamic>> _request(
    String url, {
    Map<String, dynamic>? headers,
    String? postUrl,
    Map<String, dynamic>? postHeaders,
    Map<String, dynamic>? data,
  }) async {
    var response = await dio.get<dynamic>(
      url,
      options: Options(headers: headers),
    );

    if (data != null && postUrl != null) {
      final requestData = <String, dynamic>{
        '__RequestVerificationToken': MobileNkustParser.getCSRF(response.data),
        ...data,
      };

      response = await dio.post<dynamic>(
        postUrl,
        data: requestData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: postHeaders,
        ),
      );
    }

    return response;
  }

  Future<void> loginVms({
    required String username,
    required String password,
  }) async {
    try {
      await _request(
        busBaseUrl,
        postUrl: busBaseUrl,
        data: <String, dynamic>{
          'Account': username,
          'Password': password,
          'RememberMe': 'true',
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode != 302) rethrow;
    }
  }

  Future<LoginResponse> login({
    required BuildContext context,
    required String username,
    required String password,
    bool clearCache = false,
  }) async {
    final data = MobileCookiesData.load();
    if (data != null && !clearCache) {
      setCookieFromData(data);
      if (await isCookieAlive()) {
        final now = DateTime.now();
        final lastTime = PreferenceUtil.instance.getInt(
          Constants.mobileCookiesLastTime,
          now.microsecondsSinceEpoch,
        );
        AnalyticsUtil.instance.logEvent(
          'cookies_persistence_time',
          parameters: <String, Object>{
            'time': now.microsecondsSinceEpoch - lastTime,
          },
        );
        return LoginResponse();
      }
    }

    if (!context.mounted) return LoginResponse();

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => MobileNkustPage(
          username: username,
          password: password,
          clearCache: clearCache,
        ),
      ),
    );

    if (result ?? false) {
      return LoginResponse();
    }

    throw GeneralResponse(statusCode: ApStatusCode.cancel, message: 'cancel');
  }

  @override
  Future<CourseData> getCourseTable({String? year, String? semester}) async {
    Response<dynamic> response;

    if (year == null || semester == null) {
      response = await _request(
        courseUrl,
        headers: <String, String>{'Referer': homeUrl},
      );
    } else {
      response = await _request(
        courseUrl,
        data: <String, String>{'Yms': '$year-$semester'},
        headers: <String, String>{'Referer': courseUrl},
      );
    }

    return MobileNkustParser.courseTable(response.data);
  }

  Future<MidtermAlertsData> getMidAlerts({
    String? year,
    String? semester,
  }) async {
    Response<dynamic> response;

    if (year == null || semester == null) {
      response = await _request(
        midAlertsUrl,
        headers: <String, String>{'Referer': homeUrl},
      );
    } else {
      response = await _request(
        midAlertsUrl,
        data: <String, String>{'Yms': '$year-$semester'},
        headers: <String, String>{'Referer': midAlertsUrl},
      );
    }

    return MobileNkustParser.midtermAlerts(response.data);
  }

  @override
  Future<ScoreData> getScores({required String year, required String semester}) async {
    final response = await _request(
      scoreUrl,
      data: <String, String>{'Yms': '$year-$semester'},
      headers: <String, String>{'Referer': scoreUrl},
    );

    return MobileNkustParser.scores(response.data);
  }

  @override
  Future<UserInfo> getUserInfo() async {
    final response = await _request(
      homeUrl,
      headers: <String, String>{'Referer': homeUrl},
    );
    return MobileNkustParser.userInfo(response.data);
  }

  @override
  Future<Uint8List?> getUserPicture([String? _]) async {
    final response = await dio.get<Uint8List>(
      pictureUrl,
      options: Options(
        responseType: ResponseType.bytes,
        headers: <String, String>{
          'Referer': homeUrl,
          'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
        },
      ),
    );
    return response.data;
  }

  Future<BusData> busTimeTableQuery({required DateTime fromDateTime}) async {
    final year = fromDateTime.year.toString();
    final month = fromDateTime.month.toString().padLeft(2, '0');
    final day = fromDateTime.day.toString().padLeft(2, '0');
    final dateStr = '$year/$month/$day';

    final pageResponse = await dio.get<String>(
      busTimetablePageUrl,
      options: Options(headers: <String, String>{'Referer': homeUrl}),
    );

    final busInfo = MobileNkustParser.busInfo(pageResponse.data);
    final csrf = MobileNkustParser.getCSRF(pageResponse.data);

    final routes = <List<String>>[
      <String>['建工', '燕巢'],
      <String>['燕巢', '建工'],
      <String>['第一', '建工'],
      <String>['建工', '第一'],
    ];

    final futures = routes.map((route) async {
      final response = await dio.post<dynamic>(
        busTimetableApiUrl,
        data: <String, String>{
          'driveDate': dateStr,
          'beginStation': route[0],
          'endStation': route[1],
          '__RequestVerificationToken': csrf,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: <String, String>{'Referer': busTimetablePageUrl},
        ),
      );
      return MobileNkustParser.busTimeTable(
        response.data,
        time: dateStr,
        startStation: route[0],
        endStation: route[1],
      );
    });

    final results = await Future.wait(futures);
    final allBuses = results.expand((list) => list).toList();

    return BusData.fromJson(<String, dynamic>{
      'data': allBuses,
      ...busInfo,
    });
  }

  Future<BookingBusData> busBook({required String busId}) async {
    final response = await _request(
      busTimetablePageUrl,
      postUrl: busBookApiUrl,
      data: <String, String>{'busId': busId},
      headers: <String, String>{'Referer': homeUrl},
      postHeaders: <String, String>{'Referer': busTimetablePageUrl},
    );

    final data = _parseJsonResponse(response);
    return BookingBusData(
      success: (data['success'] as bool) && data['title'] == '預約成功',
    );
  }

  Future<CancelBusData> busUnBook({required String busId}) async {
    final response = await _request(
      busTimetablePageUrl,
      postUrl: busUnbookApiUrl,
      data: <String, String>{'reserveId': busId},
      headers: <String, String>{'Referer': homeUrl},
      postHeaders: <String, String>{'Referer': busTimetablePageUrl},
    );

    final data = _parseJsonResponse(response);
    return CancelBusData(
      success: (data['success'] as bool) && data['title'] == '取消成功',
    );
  }

  Future<BusReservationsData> busUserRecord() async {
    final pageResponse = await dio.get<dynamic>(
      busUserRecordPageUrl,
      options: Options(headers: <String, String>{'Referer': homeUrl}),
    );

    final csrf = MobileNkustParser.getCSRF(pageResponse.data);

    final routes = <List<String>>[
      <String>['建工', '燕巢'],
      <String>['燕巢', '建工'],
      <String>['第一', '建工'],
      <String>['建工', '第一'],
    ];

    final futures = routes.map((route) async {
      final response = await dio.post<dynamic>(
        busUserRecordApiUrl,
        data: <String, dynamic>{
          'reserveStateCode': 0,
          'beginStation': route[0],
          'endStation': route[1],
          'pageNum': 1,
          'pageSize': 99,
          '__RequestVerificationToken': csrf,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: <String, String>{'Referer': busUserRecordPageUrl},
        ),
      );
      return MobileNkustParser.busUserRecords(
        '<table>${response.data}</table>',
        startStation: route[0],
        endStation: route[1],
      );
    });

    final results = await Future.wait(futures);
    final allRecords = results.expand((list) => list).toList();

    return BusReservationsData.fromJson(<String, dynamic>{'data': allRecords});
  }

  Future<BusViolationRecordsData> busViolationRecords() async {
    final paidFuture = _request(
      busViolationRecordsPageUrl,
      postUrl: busViolationRecordsApiUrl,
      data: <String, dynamic>{'paid': true, 'pageNum': 1, 'pageSize': 100},
      headers: <String, String>{'Referer': homeUrl},
      postHeaders: <String, String>{'Referer': busViolationRecordsPageUrl},
    );

    final notPaidFuture = _request(
      busViolationRecordsPageUrl,
      postUrl: busViolationRecordsApiUrl,
      data: <String, dynamic>{'paid': false, 'pageNum': 1, 'pageSize': 100},
      headers: <String, String>{'Referer': homeUrl},
      postHeaders: <String, String>{'Referer': busViolationRecordsPageUrl},
    );

    final responses = await Future.wait([paidFuture, notPaidFuture]);

    final result = <Map<String, dynamic>>[
      ...MobileNkustParser.busViolationRecords(
        '<table>${responses[0].data}</table>',
        paidStatus: true,
      ),
      ...MobileNkustParser.busViolationRecords(
        '<table>${responses[1].data}</table>',
        paidStatus: false,
      ),
    ];

    return BusViolationRecordsData.fromJson(
      <String, dynamic>{'reservation': result},
    );
  }

  Map<String, dynamic> _parseJsonResponse(Response<dynamic> response) {
    if (response.data is String &&
        response.headers['Content-Type']?[0].contains('text/html') == true) {
      return jsonDecode(response.data as String) as Map<String, dynamic>;
    }
    return response.data as Map<String, dynamic>;
  }

  // -- BusProvider interface --

  @override
  Future<BusData> getTimeTable({required DateTime dateTime}) =>
      busTimeTableQuery(fromDateTime: dateTime);

  @override
  Future<BookingBusData> bookBus({required String busId}) =>
      busBook(busId: busId);

  @override
  Future<CancelBusData> cancelBus({required String busId}) =>
      busUnBook(busId: busId);

  @override
  Future<BusReservationsData> getReservations() => busUserRecord();

  @override
  Future<BusViolationRecordsData> getViolationRecords() =>
      busViolationRecords();
}
