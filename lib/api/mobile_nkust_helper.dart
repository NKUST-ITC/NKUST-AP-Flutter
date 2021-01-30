import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ap_common/callback/general_callback.dart';
import 'package:ap_common/models/course_data.dart';
import 'package:ap_common/models/score_data.dart';
import 'package:ap_common/models/user_info.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:html/parser.dart' as html;
import 'package:cookie_jar/cookie_jar.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/api/parser/ap_parser.dart';
import 'package:nkust_ap/models/booking_bus_data.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/models/cancel_bus_data.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';
import 'package:nkust_ap/models/bus_data.dart';

class MobileNkustHelper {
  static const BASE_URL = 'https://mobile.nkust.edu.tw';

  static const LOGIN = '$BASE_URL/';
  static const HOME = '$BASE_URL/Home/Index';
  static const COURSE = '$BASE_URL/Student/Course';
  static const SCORE = '$BASE_URL/Student/Grades';
  static const PICTURE = '$BASE_URL/Common/GetStudentPhoto';
  static const MIDALERTS = '$BASE_URL/Student/Grades/MidWarning';
  static const BUSTIMETABLE_PAGE = '$BASE_URL/Bus/Timetable';
  static const BUSTIMETABLE_API = '$BASE_URL/Bus/GetTimetableGrid';
  static const BUS_BOOK_API = '$BASE_URL/Bus/CreateReserve';
  static const BUS_UNBOOK_API = '$BASE_URL/Bus/CancelReserve';
  static const BUS_USER_RECORD_PAGE = '$BASE_URL/Bus/Reserve';
  static const BUS_USER_RECORD_API = '$BASE_URL/Bus/GetReserveGrid';
  static const BUS_VIOLATION_RECORDS_PAGE = '$BASE_URL/Bus/Illegal';
  static const BUS_VIOLATION_RECORDS_API = '$BASE_URL/Bus/GetIllegalGrid';

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
        '__RequestVerificationToken': CourseParser.getCSRF(response.data)
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
    int year,
    int semester,
    GeneralCallback<CourseData> callback,
  }) async {
    try {
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
      if (kDebugMode) debugPrint(rawHtml);
      final courseData = CourseParser.courseTable(rawHtml);
      return callback != null ? callback.onSuccess(courseData) : courseData;
    } catch (e) {
      if (e is DioError) print(e.request.path);
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
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
      final midtermAlertsData = CourseParser.midtermAlerts(rawHtml);
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
    int year,
    int semester,
    GeneralCallback<ScoreData> callback,
  }) async {
    try {
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
      if (kDebugMode) debugPrint(rawHtml);
      final courseData = CourseParser.scores(rawHtml);
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
    final data = CourseParser.userInfo(rawHtml);
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
              '__RequestVerificationToken': CourseParser.getCSRF(_request.data)
            },
            options: Options(
              contentType: Headers.formUrlEncodedContentType,
            ));
        _requestsList.add(request);
      }

      List result = [];

      for (int i = 0; i < _requestsList.length; i++) {
        result.addAll(CourseParser.busTimeTable(
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
              '__RequestVerificationToken': CourseParser.getCSRF(_request.data)
            },
            options: Options(
              contentType: Headers.formUrlEncodedContentType,
            ));
        _requestsList.add(request);
      }

      List result = [];

      for (int i = 0; i < _requestsList.length; i++) {
        // add <table> tag to avoid parser error.
        result.addAll(CourseParser.busUserRecords(
          "<table>${await _requestsList[i].data}</table>",
          startStation: requestsDataList[i][0],
          endStation: requestsDataList[i][0],
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
      result.addAll(CourseParser.busViolationRecords(
        '<table> ${paidRequest.data} </table>',
        paidStatus: true,
      ));
      result.addAll(CourseParser.busViolationRecords(
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

class CourseParser {
  static List<Map<String, dynamic>> busViolationRecords(
    String rawHtml, {
    bool paidStatus,
  }) {
    final document = html.parse(rawHtml);
    List<Map<String, dynamic>> result = [];
    var format = DateFormat('yyyy/MM/dd HH:mm');

    for (var trElement in document.getElementsByTagName('tr')) {
      Map<String, dynamic> _temp = {};

      var tdElements = trElement.getElementsByTagName('td');
      var timeElement = tdElements[1].getElementsByTagName('div')[0];
      _temp['isPayment'] = paidStatus;
      var startAndGoal = tdElements[3].text.split(" 到 ");
      _temp['startStation'] = startAndGoal[0];
      _temp['endStation'] = startAndGoal[1];
      _temp['amountend'] = int.parse(tdElements[4].text);
      _temp['homeCharteredBus'] = false;

      _temp['time'] = format.parse(
          '${timeElement.text.substring(0, 10)} ${timeElement.text.substring(14)}');
      result.add(_temp);
    }
    return result;
  }

  static List<Map<String, dynamic>> busUserRecords(
    String rawHtml, {
    String startStation,
    String endStation,
  }) {
    final document = html.parse(rawHtml);
    List<Map<String, dynamic>> result = [];
    var format = DateFormat('yyyy/MM/dd HH:mm');

    for (var trElement in document.getElementsByTagName('tr')) {
      Map<String, dynamic> _temp = {};
      _temp['cancelKey'] =
          trElement.getElementsByTagName("input")[0].attributes['value'];
      var tdElements = trElement.getElementsByTagName('td');

      _temp['dateTime'] = format.parse(
          '${tdElements[1].text.substring(0, 10)} ${tdElements[1].text.substring(14)}');
      _temp['state'] = "";
      _temp['travelState'] = "";
      _temp['start'] = startStation;
      _temp['end'] = endStation;
      result.add(_temp);
    }

    return result;
  }

  static CourseData courseTable(rawHtml) {
    final document = html.parse(rawHtml);

    Map<String, dynamic> result = {
      "courses": [],
      'timeCodes': [],
    };
    var inputElements = document.getElementsByTagName("input");
    var coursesJson = jsonDecode(inputElements[0].attributes['value']);
    var periodTimeJson = jsonDecode(inputElements[1].attributes['value']);

    periodTimeJson.forEach((periodTime) {
      result["timeCodes"].add({
        "title": "第${periodTime["PeriodName"]}節",
        "startTime":
            "${periodTime["BegTime"].substring(0, 2)}:${periodTime["BegTime"].substring(2, 4)}",
        "endTime":
            "${periodTime["EndTime"].substring(0, 2)}:${periodTime["EndTime"].substring(2, 4)}",
      });
    });

    coursesJson.forEach((course) {
      var _temp = {
        "code": course['SelectCode'].toString(),
        "title": course['CourseName'].toString(),
        "className": course['ClassNameAbr'].toString(),
        "group": course['CourseGroup'].toString(),
        "units": course['Credit'].toString(),
        "hours": course['Hour'].toString(),
        "required": course['OptionName'].toString(),
        "at": course['Annual'],
        "sectionTimes": []
      };
      for (var time in course['CourseWeekPeriod']) {
        _temp['sectionTimes'].add({
          "weekday": int.parse(time['CourseWeek']),
          "index": int.parse(time['CoursePeriod'])
        });
      }
      result["courses"].add(_temp);
    });

    return CourseData.fromJson(result);
  }

  static MidtermAlertsData midtermAlerts(rawHtml) {
    final midtermAlertsData = MidtermAlertsData();
    return midtermAlertsData;
  }

  static List<Map<String, dynamic>> busTimeTable(
    rawHtml, {
    String time,
    String startStation,
    String endStation,
  }) {
    var document = html.parse(rawHtml);

    List<Map<String, dynamic>> result = [];

    for (var trElement in document.getElementsByTagName('tr').sublist(1)) {
      Map<String, dynamic> _temp = {};

      // Element can't get ById. so build new parser object.
      var _input_document = html.parse(trElement.outerHtml);
      _temp['canBook'] = true;

      if (_input_document.getElementById('ReserveEnable').attributes['value'] ==
          null) {
        //can't book.
        _temp['canBook'] = false;
      }
      _temp['busId'] =
          _input_document.getElementById('BusId').attributes['value'];
      _temp['cancelKey'] =
          _input_document.getElementById('ReserveId').attributes['value'];
      _temp['isReserve'] =
          (_input_document.getElementById('ReserveStateCode').text == '1');

      var tdElements = trElement.getElementsByTagName('td').sublist(1);

      var format = DateFormat('yyyy/MM/dd HH:mm');

      _temp['departureTime'] = format.parse('$time ${tdElements[0].text}');
      _temp['reserveCount'] = int.parse(tdElements[1].text);
      _temp['homeCharteredBus'] = false;
      _temp['specialTrain'] = '';
      _temp['description'] = '';
      _temp['startStation'] = startStation;
      _temp['endStation'] = endStation;
      _temp['limitCount'] = 999;

      if (tdElements[2].text != '') {
        if (tdElements[2].getElementsByTagName('button').isNotEmpty) {
          var _typeString = tdElements[2]
              .getElementsByTagName('button')[0]
              .text
              .replaceAll(' ', '')
              .replaceAll('\n', '');
          if (_typeString == '返鄉專車') {
            _temp['homeCharteredBus'] = true;
          }
          if (_typeString == '試辦專車') {
            _temp['specialTrain'] = '2';
          }
          _temp['description'] = tdElements[2]
              .getElementsByTagName('button')[0]
              .attributes['data-content'];
        }
      }
      result.add(_temp);
    }
    return result;
  }

  static ScoreData scores(rawHtml) {
    final scoreData = ScoreData();
    final document = html.parse(rawHtml);
    // generate scores list
    if (document.getElementById("datatable") == null) {
      return scoreData;
    }
    List<Map<String, dynamic>> scoresList = [];
    //skip table header
    var _trElements =
        document.getElementById("datatable").getElementsByTagName('tr');
    if (_trElements.length <= 1) {
      return scoreData;
    }

    for (var trElement in _trElements.sublist(1)) {
      // select td element
      var tdElements = trElement.getElementsByTagName("td");

      if (tdElements.length < 8) {
        // continue;
        return scoreData;
      }
      scoresList.add({
        "title": tdElements.elementAt(0).text,
        "units": tdElements.elementAt(1).text,
        "hours": tdElements.elementAt(2).text,
        "required": tdElements.elementAt(3).text,
        "at": tdElements.elementAt(4).text,
        "middleScore": tdElements.elementAt(5).text,
        "finalScore": tdElements.elementAt(6).text,
        "remark": tdElements.elementAt(7).text,
      });
    }

    //detail data
    Map<String, dynamic> detailData = {};
    var detailDiv = document.getElementsByClassName("text-bold text-info");
    if (detailDiv == null) {
      return scoreData;
    }
    if (detailDiv.length < 4) {
      return scoreData;
    }
    detailData["average"] = detailDiv
        .elementAt(0)
        .parent
        .text
        .replaceAll(detailDiv.elementAt(0).text, "")
        .replaceAll("\n", "")
        .replaceAll(" ", "");
    detailData["average"] = double.parse(detailData["average"]);
    detailData["conduct"] = detailDiv
        .elementAt(1)
        .parent
        .text
        .replaceAll(detailDiv.elementAt(1).text, "")
        .replaceAll("\n", "")
        .replaceAll(" ", "");
    detailData["conduct"] = double.parse(detailData["conduct"]);
    detailData["classRank"] = detailDiv
        .elementAt(2)
        .parent
        .text
        .replaceAll(detailDiv.elementAt(2).text, "")
        .replaceAll("\n", "")
        .replaceAll(" ", "");

    detailData["departmentRank"] = detailDiv
        .elementAt(3)
        .parent
        .text
        .replaceAll(detailDiv.elementAt(3).text, "")
        .replaceAll("\n", "")
        .replaceAll(" ", "");

    return ScoreData.fromJson({
      "scores": scoresList,
      "detail": detailData,
    });
  }

  static UserInfo userInfo(rawHtml) {
    final userInfo = UserInfo();
    final document = html.parse(rawHtml);
    final list = document.getElementsByClassName('user-header');
    if (list.length > 0) {
      final p = list[0].getElementsByTagName('p');
      if (p.length >= 2) {
        userInfo.id = p[0].text.split(' ').first;
        userInfo.name = p[0].text.split(' ').last;
        userInfo.department = p[1].text;
      }
    }
    return userInfo;
  }

  static String getCSRF(rawHtml) {
    final document = html.parse(rawHtml);
    for (var inputElement in document.getElementsByTagName("input")) {
      if (((inputElement.attributes ?? const {})['name'] ?? "") ==
          "__RequestVerificationToken") {
        return inputElement.attributes['value'];
      }
    }
    return "";
  }
}
