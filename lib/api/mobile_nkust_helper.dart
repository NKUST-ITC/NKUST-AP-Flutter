import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ap_common/callback/general_callback.dart';
import 'package:ap_common/models/course_data.dart';
import 'package:ap_common/models/private_cookies_manager.dart';
import 'package:ap_common/models/score_data.dart';
import 'package:ap_common/models/user_info.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common_firebase/utils/firebase_analytics_utils.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/ap_helper.dart';
import 'package:nkust_ap/api/ap_status_code.dart';
import 'package:nkust_ap/api/helper.dart';
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
import 'package:nkust_ap/pages/mobile_nkust_page.dart';

class MobileNkustHelper {
  MobileNkustHelper() {
    final Random random = Random();
    final int i = random.nextInt(userAgentList.length);
    // print('user agnent index = $i');
    dio = Dio(
      BaseOptions(
        followRedirects: false,
        headers: <String, String>{
          'user-agent': userAgentList[i],
        },
      ),
    );
    initCookiesJar();
  }

  static const String baseUrl = 'https://mobile.nkust.edu.tw/';

  static const String loginUrl = baseUrl;
  static const String homeUrl = '${baseUrl}Home/Index';
  static const String courseUrl = '${baseUrl}Student/Course';
  static const String scoreUrl = '${baseUrl}Student/Grades';
  static const String pictureUrl = '${baseUrl}Common/GetStudentPhoto';
  static const String midAlertsUrl = '${baseUrl}Student/Grades/MidWarning';
  static const String busTimetablePageUrl = '${baseUrl}Bus/Timetable';
  static const String busTimetableApiUrl = '${baseUrl}Bus/GetTimetableGrid';
  static const String busBookApiUrl = '${baseUrl}Bus/CreateReserve';
  static const String busUnbookApiUrl = '${baseUrl}Bus/CancelReserve';
  static const String busUserRecordPageUrl = '${baseUrl}Bus/Reserve';
  static const String busUserRecordApiUrl = '${baseUrl}Bus/GetReserveGrid';
  static const String busViolationRecordsPageUrl = '${baseUrl}Bus/Illegal';
  static const String busViolationRecordsApiUrl =
      '${baseUrl}Bus/GetIllegalGrid';

  static const String checkExpireUrl = '${baseUrl}Account/CheckExpire';

  static MobileNkustHelper? _instance;

  static bool get isSupport =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  late Dio dio;

  late CookieJar cookieJar;

  MobileCookiesData? cookiesData;

  static List<String> userAgentList = <String>[
    'Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.16 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.124 Safari/537.36',
    'Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2762.73 Safari/537.36',
    'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2226.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.93 Safari/537.36',
    'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.17 Safari/537.36',
    'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.62 Safari/537.36',
    'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.62 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.93 Safari/537.36',
    'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1623.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML like Gecko) Chrome/44.0.2403.155 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.124 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.93 Safari/537.36'
  ];

  String? get userAgent => dio.options.headers['user-agent'] as String?;

  //ignore: prefer_constructors_over_static_methods
  static MobileNkustHelper get instance {
    return _instance ??= MobileNkustHelper();
  }

  void initCookiesJar() {
    cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
    dio.interceptors.add(PrivateCookieManager(WebApHelper.instance.cookieJar));
    cookieJar.loadForRequest(Uri.parse(baseUrl));
  }

  void setProxy(String proxyIP) {
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final HttpClient client = HttpClient();
      client.findProxy = (Uri uri) {
        return 'PROXY $proxyIP';
      };
      return client;
    };
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
      final Response<dynamic> res = await dio.get(checkExpireUrl);
      return res.data == 'alive';
    } catch (_) {}
    return false;
  }

  Future<Response<dynamic>> generalRequest(
    String url, {
    Map<String, dynamic>? firstRequestHeader,
    String? otherRequestUrl,
    Map<String, dynamic>? otherRequestHeader,
    Map<String, dynamic>? data,
  }) async {
    Response<dynamic> response = await dio.get(
      url,
      options: Options(headers: firstRequestHeader),
    );

    if (data != null) {
      if (otherRequestUrl != null) {
        final Map<String, dynamic> requestData = <String, dynamic>{
          '__RequestVerificationToken': MobileNkustParser.getCSRF(response.data)
        };
        requestData.addAll(data);

        response = await dio.post<dynamic>(
          otherRequestUrl,
          data: requestData,
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            headers: otherRequestHeader,
          ),
        );
      }
    }
    return response;
  }

  Future<LoginResponse> login({
    required BuildContext context,
    required bool mounted,
    required String username,
    required String password,
    bool clearCache = false,
  }) async {
    final MobileCookiesData? data = MobileCookiesData.load();
    if (data != null && !clearCache) {
      MobileNkustHelper.instance.setCookieFromData(data);
      final bool isCookieAlive =
          await MobileNkustHelper.instance.isCookieAlive();
      if (isCookieAlive) {
        final DateTime now = DateTime.now();
        final int lastTime = Preferences.getInt(
          Constants.mobileCookiesLastTime,
          now.microsecondsSinceEpoch,
        );
        FirebaseAnalyticsUtils.instance.logEvent(
          'cookies_persistence_time',
          parameters: <String, dynamic>{
            'time': now.microsecondsSinceEpoch - lastTime,
          },
        );
        return LoginResponse();
      }
    }
    if (!mounted) return LoginResponse();
    final bool? result = await Navigator.push<bool>(
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
    } else {
      throw GeneralResponse(statusCode: ApStatusCode.cancel, message: 'cancel');
    }
  }

  Future<CourseData> getCourseTable({
    String? year,
    String? semester,
  }) async {
    Response<dynamic> response;
    if (year == null || semester == null) {
      response = await generalRequest(
        courseUrl,
        firstRequestHeader: <String, String>{'Referer': homeUrl},
      );
    } else {
      response = await generalRequest(
        courseUrl,
        data: <String, String>{
          'Yms': '$year-$semester',
        },
        firstRequestHeader: <String, String>{'Referer': courseUrl},
      );
    }

    final dynamic rawHtml = response.data;
    // if (kDebugMode) debugPrint(rawHtml);
    final CourseData courseData = MobileNkustParser.courseTable(rawHtml);
    return courseData;
  }

  Future<MidtermAlertsData> getMidAlerts({
    String? year,
    String? semester,
  }) async {
    Response<dynamic> response;
    if (year == null || semester == null) {
      response = await generalRequest(
        midAlertsUrl,
        firstRequestHeader: <String, String>{'Referer': homeUrl},
      );
    } else {
      response = await generalRequest(
        midAlertsUrl,
        data: <String, String>{'Yms': '$year-$semester'},
        firstRequestHeader: <String, String>{'Referer': midAlertsUrl},
      );
    }

    final dynamic rawHtml = response.data;
    // if (kDebugMode) debugPrint(rawHtml);
    final MidtermAlertsData midtermAlertsData =
        MobileNkustParser.midtermAlerts(rawHtml);
    return midtermAlertsData;
  }

  Future<ScoreData> getScores({
    String? year,
    String? semester,
  }) async {
    Response<dynamic> response;
    if (year == null || semester == null) {
      response = await generalRequest(
        scoreUrl,
        firstRequestHeader: <String, String>{'Referer': homeUrl},
      );
    } else {
      response = await generalRequest(
        scoreUrl,
        data: <String, String>{'Yms': '$year-$semester'},
        firstRequestHeader: <String, String>{'Referer': scoreUrl},
      );
    }

    final dynamic rawHtml = response.data;
    // if (kDebugMode) debugPrint(rawHtml);
    final ScoreData courseData = MobileNkustParser.scores(rawHtml);
    return courseData;
  }

  Future<UserInfo> getUserInfo() async {
    final Response<dynamic> response = await generalRequest(
      homeUrl,
      firstRequestHeader: <String, String>{'Referer': homeUrl},
    );
    final dynamic rawHtml = response.data;
    // if (kDebugMode) debugPrint(rawHtml);
    final UserInfo data = MobileNkustParser.userInfo(rawHtml);
    return data;
  }

  Future<Uint8List?> getUserPicture() async {
    dio.options.headers['Accept'] =
        'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8';
    final Response<Uint8List> response = await dio.get<Uint8List>(
      pictureUrl,
      options: Options(
        responseType: ResponseType.bytes,
        headers: <String, String>{'Referer': homeUrl},
      ),
    );
    return response.data;
  }

  Future<BusData> busTimeTableQuery({
    required DateTime fromDateTime,
  }) async {
    // support DateTime or {year,month,day}.
    final String year = fromDateTime.year.toString();
    String month = fromDateTime.month.toString();
    String day = fromDateTime.day.toString();
    for (int i = 0; month.length < 2; i++) {
      month = '0$month';
    }
    for (int i = 0; day.length < 2; i++) {
      day = '0$day';
    }

    //get main CSRF
    final Response<String> request = await dio.get<String>(
      busTimetablePageUrl,
      options: Options(
        headers: <String, String>{
          'Referer': homeUrl,
        },
      ),
    );

    final Map<String, dynamic> busInfo =
        MobileNkustParser.busInfo(request.data);

    final List<Response<dynamic>> requestsList = <Response<dynamic>>[];
    final List<List<String>> requestsDataList = <List<String>>[
      <String>['建工', '燕巢'],
      <String>['燕巢', '建工'],
      <String>['第一', '建工'],
      <String>['建工', '第一'],
    ];
    for (final List<String> requestData in requestsDataList) {
      final Response<dynamic> r = await dio.post(
        busTimetableApiUrl,
        data: <String, String>{
          'driveDate': '$year/$month/$day',
          'beginStation': requestData[0],
          'endStation': requestData[1],
          '__RequestVerificationToken': MobileNkustParser.getCSRF(request.data)
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: <String, String>{'Referer': busTimetablePageUrl},
        ),
      );
      requestsList.add(r);
    }

    final List<Map<String, dynamic>> result = <Map<String, dynamic>>[];

    for (int i = 0; i < requestsList.length; i++) {
      result.addAll(
        MobileNkustParser.busTimeTable(
          await requestsList[i].data,
          time: '$year/$month/$day',
          startStation: requestsDataList[i][0],
          endStation: requestsDataList[i][1],
        ),
      );
    }
    final BusData busData = BusData.fromJson(
      <String, dynamic>{
        'data': result,
        ...busInfo,
      },
    );
    return busData;
  }

  Future<BookingBusData> busBook({
    required String busId,
  }) async {
    final Response<dynamic> request = await generalRequest(
      busTimetablePageUrl,
      otherRequestUrl: busBookApiUrl,
      data: <String, String>{'busId': busId},
      firstRequestHeader: <String, String>{'Referer': homeUrl},
      otherRequestHeader: <String, String>{'Referer': busTimetablePageUrl},
    );

    Map<String, dynamic>? data;
    if (request.data is String &&
        request.headers['Content-Type']![0].contains('text/html')) {
      data = jsonDecode(request.data as String) as Map<String, dynamic>;
    } else if (request.data is Map<String, dynamic>) {
      data = request.data as Map<String, dynamic>;
    }
    return BookingBusData(
      success: (data!['success'] as bool) && data['title'] == '預約成功',
    );
  }

  Future<CancelBusData> busUnBook({
    required String busId,
  }) async {
    final Response<dynamic> request = await generalRequest(
      busTimetablePageUrl,
      otherRequestUrl: busUnbookApiUrl,
      data: <String, String>{'reserveId': busId},
      firstRequestHeader: <String, String>{'Referer': homeUrl},
      otherRequestHeader: <String, String>{'Referer': busTimetablePageUrl},
    );

    Map<String, dynamic>? data;
    if (request.data is String &&
        request.headers['Content-Type']![0].contains('text/html')) {
      data = jsonDecode(request.data as String) as Map<String, dynamic>;
    } else if (request.data is Map<String, dynamic>) {
      data = request.data as Map<String, dynamic>;
    }
    return CancelBusData(
      success: (data!['success'] as bool) && data['title'] == '取消成功',
    );
  }

  Future<BusReservationsData> busUserRecord() async {
    //get main CSRF
    final Response<dynamic> request = await dio.get(
      busUserRecordPageUrl,
      options: Options(headers: <String, String>{'Referer': homeUrl}),
    );

    final List<Response<dynamic>> requestsList = <Response<dynamic>>[];
    final List<List<String>> requestsDataList = <List<String>>[
      <String>['建工', '燕巢'],
      <String>['燕巢', '建工'],
      <String>['第一', '建工'],
      <String>['建工', '第一'],
    ];
    for (final List<String> requestData in requestsDataList) {
      final Response<dynamic> r = await dio.post(
        busUserRecordApiUrl,
        data: <String, dynamic>{
          'reserveStateCode': 0,
          'beginStation': requestData[0],
          'endStation': requestData[1],
          'pageNum': 1,
          'pageSize': 99,
          '__RequestVerificationToken': MobileNkustParser.getCSRF(request.data)
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: <String, String>{'Referer': busUserRecordPageUrl},
        ),
      );
      requestsList.add(r);
    }

    final List<Map<String, dynamic>> result = <Map<String, dynamic>>[];

    for (int i = 0; i < requestsList.length; i++) {
      // add <table> tag to avoid parser error.
      result.addAll(
        MobileNkustParser.busUserRecords(
          '<table>${await requestsList[i].data}</table>',
          startStation: requestsDataList[i][0],
          endStation: requestsDataList[i][1],
        ),
      );
    }

    final BusReservationsData busReservationsData =
        BusReservationsData.fromJson(<String, dynamic>{
      'data': result,
    });

    return busReservationsData;
  }

  Future<BusViolationRecordsData> busViolationRecords() async {
    // paid request
    final Response<dynamic> paidRequest = await generalRequest(
      busViolationRecordsPageUrl,
      otherRequestUrl: busViolationRecordsApiUrl,
      data: <String, dynamic>{
        'paid': true,
        'pageNum': 1,
        'pageSize': 100,
      },
      firstRequestHeader: <String, String>{
        'Referer': homeUrl,
      },
      otherRequestHeader: <String, String>{
        'Referer': busViolationRecordsPageUrl
      },
    );
    // not pay request
    final Response<dynamic> notPaidRequest = await generalRequest(
      busViolationRecordsPageUrl,
      otherRequestUrl: busViolationRecordsApiUrl,
      data: <String, dynamic>{
        'paid': false,
        'pageNum': 1,
        'pageSize': 100,
      },
      firstRequestHeader: <String, String>{
        'Referer': homeUrl,
      },
      otherRequestHeader: <String, String>{
        'Referer': busViolationRecordsPageUrl,
      },
    );

    final List<Map<String, dynamic>> result = <Map<String, dynamic>>[];
    result.addAll(
      MobileNkustParser.busViolationRecords(
        '<table> ${paidRequest.data} </table>',
        paidStatus: true,
      ),
    );
    result.addAll(
      MobileNkustParser.busViolationRecords(
        '<table> ${notPaidRequest.data} </table>',
        paidStatus: false,
      ),
    );

    final BusViolationRecordsData busViolationRecordsData =
        BusViolationRecordsData.fromJson(
      <String, dynamic>{'reservation': result},
    );

    return busViolationRecordsData;
  }
}
