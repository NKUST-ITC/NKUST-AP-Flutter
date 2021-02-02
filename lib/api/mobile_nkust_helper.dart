import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ap_common/callback/general_callback.dart';
import 'package:ap_common/models/course_data.dart';
import 'package:ap_common/models/score_data.dart';
import 'package:ap_common/models/user_info.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/booking_bus_data.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/models/cancel_bus_data.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';
import 'package:nkust_ap/models/bus_data.dart';
import 'package:nkust_ap/models/mobile_cookies_data.dart';

import 'parser/mobile_nkust_parser.dart';

class MobileNkustHelper {
  static const BASE_URL = 'https://mobile.nkust.edu.tw/';

  static const LOGIN = '$BASE_URL';
  static const HOME = '${BASE_URL}Home/Index';
  static const COURSE = '${BASE_URL}Student/Course';
  static const SCORE = '${BASE_URL}Student/Grades';
  static const PICTURE = '${BASE_URL}Common/GetStudentPhoto';
  static const MIDALERTS = '${BASE_URL}Student/Grades/MidWarning';
  static const BUSTIMETABLE_PAGE = '${BASE_URL}Bus/Timetable';
  static const BUSTIMETABLE_API = '${BASE_URL}Bus/GetTimetableGrid';
  static const BUS_BOOK_API = '${BASE_URL}Bus/CreateReserve';
  static const BUS_UNBOOK_API = '${BASE_URL}Bus/CancelReserve';
  static const BUS_USER_RECORD_PAGE = '${BASE_URL}Bus/Reserve';
  static const BUS_USER_RECORD_API = '${BASE_URL}Bus/GetReserveGrid';
  static const BUS_VIOLATION_RECORDS_PAGE = '${BASE_URL}Bus/Illegal';
  static const BUS_VIOLATION_RECORDS_API = '${BASE_URL}Bus/GetIllegalGrid';

  static const CHECK_EXPIRE = '${BASE_URL}Account/CheckExpire';
  static Dio dio;

  static CookieJar cookieJar;

  static MobileNkustHelper _instance;

  int captchaErrorCount = 0;

  static MobileNkustHelper get instance {
    if (_instance == null) {
      _instance = MobileNkustHelper();
      dio = Dio(
        BaseOptions(
          followRedirects: false,
          headers: {
            "user-agent":
                "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148",
          },
        ),
      );
      initCookiesJar();
    }

    return _instance;
  }

  static initCookiesJar() {
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
      if (res.data == 'alive') {
        return true;
      }
    } catch (e) {}
    return false;
  }

  Future<Response> generalRequest(String url,
      {String otherRequestUrl, Map<String, dynamic> data}) async {
    Response response = await dio.get(
      url,
    );

    if (data != null) {
      if (otherRequestUrl != null) {
        url = otherRequestUrl;
      }
      Map<String, dynamic> _requestData = {
        '__RequestVerificationToken': MobileNkustParser.getCSRF(response.data)
      };
      _requestData.addAll(data);

      response = await dio.post(url,
          data: _requestData,
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
          ));
    }
    return response;
  }

  Future<CourseData> getCourseTable({
    String year,
    String semester,
    GeneralCallback<CourseData> callback,
  }) async {
    Response response;
    if (year == null || semester == null) {
      response = await generalRequest(COURSE);
    } else {
      response = await generalRequest(
        COURSE,
        data: {"Yms": "$year-$semester"},
      );
    }

    final rawHtml = response.data;
    // if (kDebugMode) debugPrint(rawHtml);
    final courseData = MobileNkustParser.courseTable(rawHtml);
    return callback != null ? callback.onSuccess(courseData) : courseData;
  }

  Future<MidtermAlertsData> getMidAlerts({
    int year,
    int semester,
    GeneralCallback<MidtermAlertsData> callback,
  }) async {
    try {
      Response response;
      if (year == null || semester == null) {
        response = await generalRequest(MIDALERTS);
      } else {
        response = await generalRequest(
          MIDALERTS,
          data: {"Yms": "$year-$semester"},
        );
      }

      final rawHtml = response.data;
      // if (kDebugMode) debugPrint(rawHtml);
      final midtermAlertsData = MobileNkustParser.midtermAlerts(rawHtml);
      return callback != null
          ? callback.onSuccess(midtermAlertsData)
          : midtermAlertsData;
    } catch (e) {
      if (e is DioError) print(e.request.path);
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
  }

  Future<ScoreData> getScores({
    String year,
    String semester,
    GeneralCallback<ScoreData> callback,
  }) async {
    try {
      Response response;
      if (year == null || semester == null) {
        response = await generalRequest(SCORE);
      } else {
        response = await generalRequest(
          SCORE,
          data: {"Yms": "$year-$semester"},
        );
      }

      final rawHtml = response.data;
      // if (kDebugMode) debugPrint(rawHtml);
      final courseData = MobileNkustParser.scores(rawHtml);
      return callback != null ? callback.onSuccess(courseData) : courseData;
    } catch (e) {
      if (e is DioError) print(e.request.path);
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
  }

  Future<UserInfo> getUserInfo() async {
    final response = await generalRequest(HOME);
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
      ),
    );
    return response.data;
  }

  Future<BusData> busTimeTableQuery({
    DateTime fromDateTime,
    String year,
    String month,
    String day,
    GeneralCallback<BusData> callback,
  }) async {
    try {
      // suport DateTime or {year,month,day}.
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

      //get main CORS
      Response _request = await dio.get(
        BUSTIMETABLE_PAGE,
      );

      List<Response> _requestsList = [];
      List<List<String>> requestsDataList = [
        ['建工', '燕巢'],
        ['燕巢', '建工'],
        ['第一', '建工'],
        ['建工', '第一'],
      ];
      for (var requestData in requestsDataList) {
        Response request = await dio.post(BUSTIMETABLE_API,
            data: {
              'driveDate': '$year/$month/$day',
              'beginStation': requestData[0],
              'endStation': requestData[1],
              '__RequestVerificationToken':
                  MobileNkustParser.getCSRF(_request.data)
            },
            options: Options(
              contentType: Headers.formUrlEncodedContentType,
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
      return callback != null ? callback.onSuccess(busData) : busData;
    } catch (e) {
      if (e is DioError) print(e.request.path);
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
  }

  Future<BookingBusData> busBook({
    String busId,
    GeneralCallback<BookingBusData> callback,
  }) async {
    try {
      var request = await generalRequest(BUSTIMETABLE_PAGE,
          otherRequestUrl: BUS_BOOK_API, data: {"busId": busId});

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

      return callback != null ? callback.onSuccess(status) : status;
    } catch (e) {
      if (e is DioError) print(e.request.path);
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
  }

  Future<CancelBusData> busUnBook({
    String busId,
    GeneralCallback<CancelBusData> callback,
  }) async {
    try {
      var request = await generalRequest(BUSTIMETABLE_PAGE,
          otherRequestUrl: BUS_UNBOOK_API, data: {"reserveId": busId});

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

      return callback != null ? callback.onSuccess(status) : status;
    } catch (e) {
      if (e is DioError) print(e.request.path);
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
  }

  Future<BusReservationsData> busUserRecord({
    GeneralCallback<BusReservationsData> callback,
  }) async {
    try {
      //get main CORS
      Response _request = await dio.get(
        BUS_USER_RECORD_PAGE,
      );

      List<Response> _requestsList = [];
      List<List<String>> requestsDataList = [
        ['建工', '燕巢'],
        ['燕巢', '建工'],
        ['第一', '建工'],
        ['建工', '第一'],
      ];
      for (var requestData in requestsDataList) {
        Response request = await dio.post(BUS_USER_RECORD_API,
            data: {
              'reserveStateCode': 0,
              'beginStation': requestData[0],
              'endStation': requestData[1],
              'pageNum': 1,
              'pageSize': 99,
              '__RequestVerificationToken':
                  MobileNkustParser.getCSRF(_request.data)
            },
            options: Options(
              contentType: Headers.formUrlEncodedContentType,
            ));
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

      final busReservationsData =
          BusReservationsData.fromJson({"data": result});

      return callback != null
          ? callback.onSuccess(busReservationsData)
          : busReservationsData;
    } catch (e) {
      if (e is DioError) print(e.request.path);
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
  }

  Future<BusViolationRecordsData> busViolationRecords({
    GeneralCallback<BusViolationRecordsData> callback,
  }) async {
    try {
      // paid request
      var paidRequest = await generalRequest(BUS_VIOLATION_RECORDS_PAGE,
          otherRequestUrl: BUS_VIOLATION_RECORDS_API,
          data: {
            'paid': true,
            'pageNum': 1,
            'pageSize': 100,
          });
      // not pay request
      var notPaidRequest = await generalRequest(BUS_VIOLATION_RECORDS_PAGE,
          otherRequestUrl: BUS_VIOLATION_RECORDS_API,
          data: {
            'paid': false,
            'pageNum': 1,
            'pageSize': 100,
          });

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

      return callback != null
          ? callback.onSuccess(busViolationRecordsData)
          : busViolationRecordsData;
    } catch (e) {
      if (e is DioError) print(e.request.path);
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
  }
}
