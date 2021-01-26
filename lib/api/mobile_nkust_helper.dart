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

  Future<CourseData> getCourseTable({
    int year,
    int semester,
    GeneralCallback<CourseData> callback,
  }) async {
    try {
      dio.options.headers['Connection'] =
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9';
      dio.options.headers['Accept'] = 'keep-alive';

      Response response = await dio.get(
        COURSE,
      );

      // Select year and semester
      if (year != null && semester != null) {
        response = await dio.post(COURSE,
            data: {
              'Yms': "$year-$semester",
              '__RequestVerificationToken': CourseParser.getCSRF(response.data)
            },
            options: Options(
              contentType: Headers.formUrlEncodedContentType,
            ));
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
      dio.options.headers['Connection'] =
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9';
      dio.options.headers['Accept'] = 'keep-alive';
      Response response = await dio.get(
        SCORE,
      );

      // Select year and semester
      if (year != null && semester != null) {
        response = await dio.post(SCORE,
            data: {
              'Yms': "$year-$semester",
              '__RequestVerificationToken': CourseParser.getCSRF(response.data)
            },
            options: Options(
              contentType: Headers.formUrlEncodedContentType,
            ));
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
    dio.options.headers['Connection'] =
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9';
    dio.options.headers['Accept'] = 'keep-alive';
    final response = await dio.get(HOME);
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
    return scoreData;
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
