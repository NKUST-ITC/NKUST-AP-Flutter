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
import 'package:nkust_ap/api/exceptions/api_exception.dart';
import 'package:nkust_ap/api/api_config.dart';
import 'package:nkust_ap/api/parser/mobile_nkust_parser.dart';
import 'package:nkust_ap/api/parser/parser_utils.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';
import 'package:nkust_ap/models/mobile_cookies_data.dart';
import 'package:nkust_ap/api/capability/course_provider.dart';
import 'package:nkust_ap/api/capability/score_provider.dart';
import 'package:nkust_ap/api/capability/user_info_provider.dart';
import 'package:nkust_ap/pages/mobile_nkust_page.dart';

class MobileNkustHelper
    implements CourseProvider, ScoreProvider, UserInfoProvider {
  static const String baseUrl = 'https://mobile.nkust.edu.tw/';

  static const String loginUrl = baseUrl;
  static const String homeUrl = '${baseUrl}Home/Index';
  static const String courseUrl = '${baseUrl}Student/Course';
  static const String scoreUrl = '${baseUrl}Student/Grades';
  static const String pictureUrl = '${baseUrl}Common/GetStudentPhoto';
  static const String midAlertsUrl = '${baseUrl}Student/Grades/MidWarning';
  static const String studentLeavePageUrl = '${baseUrl}Student/Leave';
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
        '__RequestVerificationToken': getCSRF(response.data),
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

    throw const CancelledException(
      message: 'mobile.nkust login cancelled by user',
    );
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

}
