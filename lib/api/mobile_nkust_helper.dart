import 'dart:io';
import 'dart:typed_data';

import 'package:ap_common/callback/general_callback.dart';
import 'package:ap_common/models/course_data.dart';
import 'package:ap_common/models/score_data.dart';
import 'package:ap_common/models/user_info.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:html/parser.dart' as html;
import 'package:cookie_jar/cookie_jar.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/api/parser/ap_parser.dart';

class MobileNkustHelper {
  static const BASE_URL = 'https://mobile.nkust.edu.tw';

  static const LOGIN = '$BASE_URL/';
  static const HOME = '$BASE_URL/Home/Index';
  static const COURSE = '$BASE_URL/Student/Course';
  static const SCORE = '$BASE_URL/Student/Grades';
  static const PICTURE = '$BASE_URL/Common/GetStudentPhoto';

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
      {Map<String, dynamic> data}) async {
    Response response = await dio.get(
      url,
    );

    if (data != null) {
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
}

class CourseParser {
  static CourseData courseTable(rawHtml) {
    final courseData = CourseData();
    return courseData;
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
