import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:ap_common/callback/general_callback.dart';
import 'package:ap_common/models/course_data.dart';
import 'package:ap_common/models/score_data.dart';
import 'package:ap_common/models/user_info.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common_firebase/utils/firebase_analytics_utils.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/booking_bus_data.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/models/cancel_bus_data.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';
import 'package:nkust_ap/models/bus_data.dart';
import 'package:nkust_ap/models/mobile_cookies_data.dart';
import 'package:nkust_ap/pages/mobile_nkust_page.dart';

import 'ap_status_code.dart';
import 'parser/mobile_nkust_parser.dart';

class MobileNkustHelper {
  static const BASE_URL = 'https://mobile.nkust.edu.tw/';

  static const LOGIN = '$BASE_URL';
  static const HOME = '${BASE_URL}Home/Index';
  static const COURSE = '${BASE_URL}Student/Course';
  static const SCORE = '${BASE_URL}Student/Grades';
  static const PICTURE = '${BASE_URL}Common/GetStudentPhoto';
  static const MID_ALERTS = '${BASE_URL}Student/Grades/MidWarning';
  static const BUS_TIMETABLE_PAGE = '${BASE_URL}Bus/Timetable';
  static const BUS_TIMETABLE_API = '${BASE_URL}Bus/GetTimetableGrid';
  static const BUS_BOOK_API = '${BASE_URL}Bus/CreateReserve';
  static const BUS_UNBOOK_API = '${BASE_URL}Bus/CancelReserve';
  static const BUS_USER_RECORD_PAGE = '${BASE_URL}Bus/Reserve';
  static const BUS_USER_RECORD_API = '${BASE_URL}Bus/GetReserveGrid';
  static const BUS_VIOLATION_RECORDS_PAGE = '${BASE_URL}Bus/Illegal';
  static const BUS_VIOLATION_RECORDS_API = '${BASE_URL}Bus/GetIllegalGrid';

  static const CHECK_EXPIRE = '${BASE_URL}Account/CheckExpire';

  static MobileNkustHelper _instance;

  static get isSupport => (!kIsWeb && (Platform.isAndroid || Platform.isIOS));

  Dio dio;

  CookieJar cookieJar;

  MobileCookiesData cookiesData;

  static List<String> userAgentList = [
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

  String get userAgent => dio.options.headers['user-agent'];

  static MobileNkustHelper get instance {
    final _random = new Random();
    if (_instance == null) {
      _instance = MobileNkustHelper();
      _instance.dio = Dio(
        BaseOptions(
          followRedirects: false,
          headers: {
            "user-agent":
                "${userAgentList[_random.nextInt(userAgentList.length)]}",
          },
        ),
      );
      _instance.initCookiesJar();
    }
    return _instance;
  }

  void initCookiesJar() {
    cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
    cookieJar.loadForRequest(Uri.parse(BASE_URL));
  }

  void setProxy(String proxyIP) {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.findProxy = (uri) {
        return "PROXY " + proxyIP;
      };
    };
  }

  void setCookieFromData(MobileCookiesData data) {
    if (data != null) {
      cookiesData = data;
      data.cookies?.forEach((element) {
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
    String cookieName,
    String cookieValue,
    String cookieDomain,
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
      var res = await dio.get(CHECK_EXPIRE);
      return res?.data == 'alive';
    } catch (e) {}
    return false;
  }

  Future<Response> generalRequest(
    String url, {
    Map<String, dynamic> firstRequestHeader,
    String otherRequestUrl,
    Map<String, dynamic> otherRequestHeader,
    Map<String, dynamic> data,
  }) async {
    Response response = await dio.get(
      url,
      options: Options(headers: firstRequestHeader),
    );

    if (data != null) {
      if (otherRequestUrl != null) {
        url = otherRequestUrl;
      }
      Map<String, dynamic> _requestData = {
        '__RequestVerificationToken': MobileNkustParser.getCSRF(response.data)
      };
      _requestData.addAll(data);

      response = await dio.post(
        url,
        data: _requestData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: otherRequestHeader,
        ),
      );
    }
    return response;
  }

  Future<LoginResponse> login({
    @required BuildContext context,
    @required String username,
    @required String password,
    bool clearCache = false,
  }) async {
    final data = MobileCookiesData.load();
    if (data != null) {
      MobileNkustHelper.instance.setCookieFromData(data);
      final isCookieAlive = await MobileNkustHelper.instance.isCookieAlive();
      if (isCookieAlive) {
        final now = DateTime.now();
        final lastTime = Preferences.getInt(
          Constants.MOBILE_COOKIES_LAST_TIME,
          now.microsecondsSinceEpoch,
        );
        FirebaseAnalyticsUtils.analytics.logEvent(
          name: 'cookies_persistence_time',
          parameters: {
            'time': now.microsecondsSinceEpoch - lastTime,
          },
        );
        return LoginResponse();
      }
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MobileNkustPage(
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

  Future<CourseData> getCourseTable({
    String year,
    String semester,
  }) async {
    Response response;
    if (year == null || semester == null) {
      response = await generalRequest(
        COURSE,
        firstRequestHeader: {"Referer": HOME},
      );
    } else {
      response = await generalRequest(
        COURSE,
        data: {"Yms": "$year-$semester"},
        firstRequestHeader: {"Referer": COURSE},
      );
    }

    final rawHtml = response.data;
    // if (kDebugMode) debugPrint(rawHtml);
    final courseData = MobileNkustParser.courseTable(rawHtml);
    return courseData;
  }

  Future<MidtermAlertsData> getMidAlerts({
    String year,
    String semester,
  }) async {
    Response response;
    if (year == null || semester == null) {
      response = await generalRequest(
        MID_ALERTS,
        firstRequestHeader: {"Referer": HOME},
      );
    } else {
      response = await generalRequest(
        MID_ALERTS,
        data: {"Yms": "$year-$semester"},
        firstRequestHeader: {"Referer": MID_ALERTS},
      );
    }

    final rawHtml = response.data;
    // if (kDebugMode) debugPrint(rawHtml);
    final midtermAlertsData = MobileNkustParser.midtermAlerts(rawHtml);
    return midtermAlertsData;
  }

  Future<ScoreData> getScores({
    String year,
    String semester,
  }) async {
    Response response;
    if (year == null || semester == null) {
      response = await generalRequest(
        SCORE,
        firstRequestHeader: {"Referer": HOME},
      );
    } else {
      response = await generalRequest(
        SCORE,
        data: {"Yms": "$year-$semester"},
        firstRequestHeader: {"Referer": SCORE},
      );
    }

    final rawHtml = response.data;
    // if (kDebugMode) debugPrint(rawHtml);
    final courseData = MobileNkustParser.scores(rawHtml);
    return courseData;
  }

  Future<UserInfo> getUserInfo() async {
    final response = await generalRequest(
      HOME,
      firstRequestHeader: {"Referer": HOME},
    );
    final rawHtml = response.data;
    // if (kDebugMode) debugPrint(rawHtml);
    final data = MobileNkustParser.userInfo(rawHtml);
    return data;
  }

  Future<Uint8List> getUserPicture() async {
    dio.options.headers['Accept'] =
        'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8';
    final response = await dio.get(
      PICTURE,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {"Referer": HOME},
      ),
    );
    return response.data;
  }

  Future<BusData> busTimeTableQuery({
    DateTime fromDateTime,
    String year,
    String month,
    String day,
  }) async {
    // support DateTime or {year,month,day}.
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

    //get main CSRF
    Response _request = await dio.get(
      BUS_TIMETABLE_PAGE,
      options: Options(headers: {"Referer": HOME}),
    );

    List<Response> _requestsList = [];
    List<List<String>> requestsDataList = [
      ['建工', '燕巢'],
      ['燕巢', '建工'],
      ['第一', '建工'],
      ['建工', '第一'],
    ];
    for (var requestData in requestsDataList) {
      Response request = await dio.post(BUS_TIMETABLE_API,
          data: {
            'driveDate': '$year/$month/$day',
            'beginStation': requestData[0],
            'endStation': requestData[1],
            '__RequestVerificationToken':
                MobileNkustParser.getCSRF(_request.data)
          },
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            headers: {"Referer": BUS_TIMETABLE_PAGE},
          ));
      _requestsList.add(request);
    }

    List result = [];

    for (int i = 0; i < _requestsList.length; i++) {
      result.addAll(MobileNkustParser.busTimeTable(
        await _requestsList[i].data,
        time: '$year/$month/$day',
        startStation: requestsDataList[i][0],
        endStation: requestsDataList[i][1],
      ));
    }
    final busData = BusData.fromJson({"data": result});
    return busData;
  }

  Future<BookingBusData> busBook({
    String busId,
  }) async {
    var request = await generalRequest(
      BUS_TIMETABLE_PAGE,
      otherRequestUrl: BUS_BOOK_API,
      data: {"busId": busId},
      firstRequestHeader: {"Referer": HOME},
      otherRequestHeader: {"Referer": BUS_TIMETABLE_PAGE},
    );

    Map<String, dynamic> data;
    BookingBusData status = BookingBusData();
    if (request.data is String &&
        request.headers['Content-Type'][0].indexOf("text/html") > -1) {
      data = jsonDecode(request.data);
    } else if (request.data is Map<String, dynamic>) {
      data = request.data;
    }
    if (data['success'] && data['title'] == "預約成功") {
      status.success = true;
    } else {
      status.success = false;
    }

    return status;
  }

  Future<CancelBusData> busUnBook({
    String busId,
  }) async {
    var request = await generalRequest(
      BUS_TIMETABLE_PAGE,
      otherRequestUrl: BUS_UNBOOK_API,
      data: {"reserveId": busId},
      firstRequestHeader: {"Referer": HOME},
      otherRequestHeader: {"Referer": BUS_TIMETABLE_PAGE},
    );

    Map<String, dynamic> data;
    CancelBusData status = CancelBusData();
    if (request.data is String &&
        request.headers['Content-Type'][0].indexOf("text/html") > -1) {
      data = jsonDecode(request.data);
    } else if (request.data is Map<String, dynamic>) {
      data = request.data;
    }
    if (data['success'] && data['title'] == "取消成功") {
      status.success = true;
    } else {
      status.success = false;
    }
    return status;
  }

  Future<BusReservationsData> busUserRecord() async {
    //get main CSRF
    Response _request = await dio.get(
      BUS_USER_RECORD_PAGE,
      options: Options(headers: {"Referer": HOME}),
    );

    List<Response> _requestsList = [];
    List<List<String>> requestsDataList = [
      ['建工', '燕巢'],
      ['燕巢', '建工'],
      ['第一', '建工'],
      ['建工', '第一'],
    ];
    for (var requestData in requestsDataList) {
      Response request = await dio.post(
        BUS_USER_RECORD_API,
        data: {
          'reserveStateCode': 0,
          'beginStation': requestData[0],
          'endStation': requestData[1],
          'pageNum': 1,
          'pageSize': 99,
          '__RequestVerificationToken': MobileNkustParser.getCSRF(_request.data)
        },
        options: Options(
            contentType: Headers.formUrlEncodedContentType,
            headers: {"Referer": BUS_USER_RECORD_PAGE}),
      );
      _requestsList.add(request);
    }

    List result = [];

    for (int i = 0; i < _requestsList.length; i++) {
      // add <table> tag to avoid parser error.
      result.addAll(MobileNkustParser.busUserRecords(
        "<table>${await _requestsList[i].data}</table>",
        startStation: requestsDataList[i][0],
        endStation: requestsDataList[i][1],
      ));
    }

    final busReservationsData = BusReservationsData.fromJson({"data": result});

    return busReservationsData;
  }

  Future<BusViolationRecordsData> busViolationRecords() async {
    // paid request
    var paidRequest = await generalRequest(
      BUS_VIOLATION_RECORDS_PAGE,
      otherRequestUrl: BUS_VIOLATION_RECORDS_API,
      data: {
        'paid': true,
        'pageNum': 1,
        'pageSize': 100,
      },
      firstRequestHeader: {"Referer": HOME},
      otherRequestHeader: {"Referer": BUS_VIOLATION_RECORDS_PAGE},
    );
    // not pay request
    var notPaidRequest = await generalRequest(
      BUS_VIOLATION_RECORDS_PAGE,
      otherRequestUrl: BUS_VIOLATION_RECORDS_API,
      data: {
        'paid': false,
        'pageNum': 1,
        'pageSize': 100,
      },
      firstRequestHeader: {"Referer": HOME},
      otherRequestHeader: {"Referer": BUS_VIOLATION_RECORDS_PAGE},
    );

    var result = [];
    result.addAll(MobileNkustParser.busViolationRecords(
      '<table> ${paidRequest.data} </table>',
      paidStatus: true,
    ));
    result.addAll(MobileNkustParser.busViolationRecords(
      '<table> ${notPaidRequest.data} </table>',
      paidStatus: false,
    ));

    final busViolationRecordsData =
        BusViolationRecordsData.fromJson({"reservation": result});

    return busViolationRecordsData;
  }
}
