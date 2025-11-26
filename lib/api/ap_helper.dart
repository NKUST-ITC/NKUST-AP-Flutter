import 'dart:developer';
import 'dart:io';

import 'package:ap_common/ap_common.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/io.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:nkust_ap/api/ap_status_code.dart';
import 'package:nkust_ap/api/api_config.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/api/leave_helper.dart';
import 'package:nkust_ap/api/mobile_nkust_helper.dart';
import 'package:nkust_ap/api/parser/ap_parser.dart';
import 'package:nkust_ap/api/parser/api_tool.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';
import 'package:nkust_ap/models/reward_and_penalty_data.dart';
import 'package:nkust_ap/models/room_data.dart';
import 'package:nkust_ap/utils/captcha_utils.dart';

class WebApHelper {
  static const String _baseUrl = 'https://webap.nkust.edu.tw';

  static WebApHelper? _instance;

  late Dio dio;
  late DioCacheManager _manager;
  late CookieJar cookieJar;

  static int reLoginReTryCountsLimit = 3;
  static int reLoginReTryCounts = 0;

  bool isLogin = false;
  String? pictureUrl;

  static String get semesterCacheKey => 'semesterCacheKey';
  static String get coursetableCacheKey => '${Helper.username}_coursetableCacheKey';
  static String get scoresCacheKey => '${Helper.username}_scoresCacheKey';
  static String get userInfoCacheKey => '${Helper.username}_userInfoCacheKey';

  static WebApHelper get instance => _instance ??= WebApHelper();

  WebApHelper() {
    dioInit();
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

  Future<void> logout() async {
    try {
      await dio.post<dynamic>('$_baseUrl/nkust/reclear.jsp');
    } catch (_) {}
  }

  void dioInit() {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: <String, String>{
          'user-agent': ApiConfig.defaultUserAgent,
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Encoding': 'gzip, deflate, br',
          'Accept-Language': 'zh-TW,zh;q=0.9,en-US;q=0.8,en;q=0.7',
          'Connection': 'keep-alive',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    cookieJar = CookieJar();

    if (Helper.isSupportCacheData) {
      _manager = DioCacheManager(CacheConfig(baseUrl: _baseUrl));
      dio.interceptors.add(_manager.interceptor as Interceptor);
    }

    dio.interceptors.add(PrivateCookieManager(cookieJar));

    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS || Platform.isAndroid)) {
      dio.httpClientAdapter = NativeAdapter();
    }
  }

  Future<Uint8List?> getValidationImage() async {
    final response = await dio.get<Uint8List>(
      '/nkust/validateCode.jsp',
      options: Options(
        responseType: ResponseType.bytes,
        headers: <String, String>{
          'Referer': '$_baseUrl/nkust/index_main.html',
        },
      ),
    );
    return response.data;
  }

  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    for (int i = 0; i < 5; i++) {
      try {
        final captchaCode = await CaptchaUtils.extractByEucDist(
          bodyBytes: (await getValidationImage())!,
        );

        if (kDebugMode) {
          log('Login attempt ${i + 1}: $username');
        }

        final res = await dio.post<dynamic>(
          '/nkust/perchk.jsp',
          data: <String, String>{
            'uid': username,
            'pwd': password,
            'etxt_code': captchaCode,
          },
          options: Options(contentType: Headers.formUrlEncodedContentType),
        );

        Helper.username = username;
        Helper.password = password;

        final code = WebApParser.instance.apLoginParser(res.data);

        switch (code) {
          case -1:
            continue;
          case 4:
            await stayOldPwd();
            return login(username: username, password: password);
          case 0:
            isLogin = true;
            return LoginResponse(
              expireTime: DateTime.now().add(const Duration(hours: 6)),
            );
          case 1:
            throw GeneralResponse(
              statusCode: ApStatusCode.userDataError,
              message: 'username or password error',
            );
          case 5:
            throw GeneralResponse(
              statusCode: ApStatusCode.passwordFiveTimesError,
              message: 'password error 5 times',
            );
          case 500:
            throw GeneralResponse(
              statusCode: ApStatusCode.schoolServerError,
              message: 'school server error',
            );
          default:
            throw GeneralResponse(statusCode: code, message: 'unknown error');
        }
      } catch (e, s) {
        CrashlyticsUtil.instance.recordError(e, s);
        if (kDebugMode) log('Login error: $e');
      }
    }

    throw GeneralResponse(
      statusCode: ApStatusCode.unknownError,
      message: 'captcha error or unknown error',
    );
  }

  Future<Response<dynamic>> stayOldPwd() async {
    return dio.post<dynamic>(
      '/nkust/system/sys010_stay.jsp',
      data: <String, String>{'cpwd': '', 'opwd': '', 'spwd': ''},
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
  }

  Future<LoginResponse> loginToMobile() async {
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw GeneralResponse(
        statusCode: ApStatusCode.networkConnectFail,
        message: 'Login exceeded retry limit',
      );
    }

    await checkLogin();
    await apQuery('ag304_01', null);

    var res = await dio.post<String>(
      '/nkust/fnc.jsp',
      data: <String, String>{'fncid': 'CK004'},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    final skyDirectData = WebApParser.instance.webapToleaveParser(res.data);

    final tempDio = Dio()..interceptors.add(PrivateCookieManager(cookieJar));

    res = await tempDio.post<String>(
      'https://mobile.nkust.edu.tw/Account/LoginBySkytekPortalNewWindow',
      data: skyDirectData,
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (res.statusCode == 200 && res.data!.contains('/Student/Leave/Create')) {
      return LoginResponse(
        expireTime: DateTime.now().add(const Duration(hours: 1)),
      );
    }

    throw GeneralResponse(statusCode: ApStatusCode.cancel, message: 'cancel');
  }

  Future<LoginResponse> loginToOosaf() async {
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw GeneralResponse(
        statusCode: ApStatusCode.networkConnectFail,
        message: 'Login exceeded retry limit',
      );
    }

    await checkLogin();
    await apQuery('ag304_01', null);

    var res = await dio.post<String>(
      '/nkust/fnc.jsp',
      data: <String, String>{'fncid': 'CK004'},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    final skyDirectData = WebApParser.instance.webapToleaveParser(res.data);

    final tempDio = Dio()..interceptors.add(PrivateCookieManager(cookieJar));

    res = await tempDio.post<String>(
      'https://oosaf.nkust.edu.tw/Account/LoginBySkytekPortalNewWindow',
      data: skyDirectData,
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (res.statusCode == 200 && res.data!.contains('/Student/Leave/Create')) {
      return LoginResponse(
        expireTime: DateTime.now().add(const Duration(hours: 1)),
      );
    }

    throw GeneralResponse(statusCode: ApStatusCode.cancel, message: 'cancel');
  }

  Future<LoginResponse> loginToStdsys() async {
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw GeneralResponse(
        statusCode: ApStatusCode.networkConnectFail,
        message: 'Login exceeded retry limit',
      );
    }

    await checkLogin();
    await apQuery('ag304_01', null);

    var res = await dio.post<String>(
      '/nkust/fnc.jsp',
      data: <String, String>{'fncid': 'CK004'},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    final skyDirectData = WebApParser.instance.webapToleaveParser(res.data);

    final tempDio = Dio()..interceptors.add(PrivateCookieManager(cookieJar));

    res = await tempDio.post<String>(
      'https://stdsys.nkust.edu.tw/Student/Account/LoginBySkytekPortalNewWindow',
      data: skyDirectData,
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (res.statusCode == 200 && res.data!.contains('/Student/Home/Index')) {
      return LoginResponse(
        expireTime: DateTime.now().add(const Duration(hours: 1)),
      );
    }

    throw GeneralResponse(statusCode: ApStatusCode.cancel, message: 'cancel');
  }

  Future<LoginResponse> loginToLeave() async {
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw GeneralResponse(
        statusCode: ApStatusCode.networkConnectFail,
        message: 'Login exceeded retry limit',
      );
    }

    await checkLogin();
    await apQuery('ag304_01', null);

    var res = await dio.post<String>(
      '/nkust/fnc.jsp',
      data: <String, String>{'fncid': 'CK004'},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    final skyDirectData = WebApParser.instance.webapToleaveParser(res.data);

    res = await dio.get<String>(
      'https://leave.nkust.edu.tw/SkyDir.aspx',
      queryParameters: <String, dynamic>{
        'u': skyDirectData['uid'],
        'r': skyDirectData['ls_randnum'],
      },
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (res.data!.contains('masterindex.aspx')) {
      await dio.get<String>(
        'https://leave.nkust.edu.tw/masterindex.aspx',
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      LeaveHelper.instance.isLogin = true;
      return LoginResponse(
        expireTime: DateTime.now().add(const Duration(hours: 1)),
      );
    }

    throw GeneralResponse(statusCode: ApStatusCode.cancel, message: 'cancel');
  }

  Future<LoginResponse?> checkLogin() async {
    if (isLogin) return null;
    return login(username: Helper.username!, password: Helper.password!);
  }

  Future<Response<dynamic>> apQuery(
    String queryQid,
    Map<String, String?>? queryData, {
    String? cacheKey,
    Duration? cacheExpiredTime,
    bool? bytesResponse,
  }) async {
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw GeneralResponse(
        statusCode: ApStatusCode.networkConnectFail,
        message: 'Login exceeded retry limit',
      );
    }

    await checkLogin();

    final url = '/nkust/${queryQid.substring(0, 2)}_pro/$queryQid.jsp';
    final referer = '$_baseUrl/nkust/system/sys001_00.jsp?spath=ag_pro/$queryQid.jsp?';

    Options options;
    dynamic requestData;

    if (cacheKey == null) {
      options = Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: <String, String>{'Referer': referer},
      );
      if (bytesResponse == true) {
        options = options.copyWith(responseType: ResponseType.bytes);
      }
      requestData = queryData;
    } else {
      dio.options.headers['Content-Type'] = Headers.formUrlEncodedContentType;
      dio.options.headers['Referer'] = referer;

      Options? otherOptions;
      if (bytesResponse == true) {
        otherOptions = Options(responseType: ResponseType.bytes);
      }

      options = buildConfigurableCacheOptions(
        options: otherOptions,
        maxAge: cacheExpiredTime ?? const Duration(seconds: 60),
        primaryKey: cacheKey,
      );
      requestData = formUrlEncoded(queryData);
    }

    Response<dynamic> request;

    if (bytesResponse == true) {
      request = await dio.post<List<int>>(url, data: requestData, options: options);
    } else {
      request = await dio.post<dynamic>(url, data: requestData, options: options);
    }

    if (WebApParser.instance.apLoginParser(request.data) == 2) {
      if (Helper.isSupportCacheData && cacheKey != null) {
        _manager.delete(cacheKey);
      }
      reLoginReTryCounts += 1;
      await login(username: Helper.username!, password: Helper.password!);
      return apQuery(queryQid, queryData, bytesResponse: bytesResponse);
    }

    reLoginReTryCounts = 0;
    return request;
  }

  Future<UserInfo> userInfoCrawler() async {
    if (!Helper.isSupportCacheData) {
      final query = await apQuery('ag003', null);
      final data = UserInfo.fromJson(
        WebApParser.instance.apUserInfoParser(query.data as String),
      );
      pictureUrl = data.pictureUrl;
      return data;
    }

    final query = await apQuery(
      'ag003',
      null,
      cacheKey: userInfoCacheKey,
      cacheExpiredTime: const Duration(hours: 6),
    );

    final parsedData = WebApParser.instance.apUserInfoParser(query.data as String);
    if (parsedData['id'] == null) {
      _manager.delete(userInfoCacheKey);
    }

    final data = UserInfo.fromJson(parsedData);
    pictureUrl = data.pictureUrl;
    return data;
  }

  Future<Uint8List?> getUserPicture() async {
    final response = await dio.get<Uint8List>(
      pictureUrl!,
      options: Options(
        responseType: ResponseType.bytes,
        headers: <String, String>{
          'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
        },
      ),
    );
    return response.data;
  }

  Future<SemesterData> semesters() async {
    if (!Helper.isSupportCacheData) {
      final query = await apQuery('ag304_01', null);
      return SemesterData.fromJson(
        WebApParser.instance.semestersParser(query.data as String),
      );
    }

    final query = await apQuery(
      'ag304_01',
      null,
      cacheKey: semesterCacheKey,
      cacheExpiredTime: const Duration(hours: 3),
    );

    final parsedData = WebApParser.instance.semestersParser(query.data as String);
    if ((parsedData['data'] as List<dynamic>).isEmpty) {
      _manager.delete(semesterCacheKey);
    }

    return SemesterData.fromJson(parsedData);
  }

  Future<Response<Uint8List>> getEnrollmentLetter() async {
    await loginToStdsys();

    final cookies = await cookieJar.loadForRequest(Uri.parse('https://stdsys.nkust.edu.tw'));
    final cookieHeader = cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');

    return dio.get<Uint8List>(
      'https://stdsys.nkust.edu.tw/student/Doc/Status/Download',
      options: Options(
        responseType: ResponseType.bytes,
        headers: <String, String>{
          'Referer': 'https://stdsys.nkust.edu.tw/student/Doc/Status',
          'Cookie': cookieHeader,
        },
      ),
    );
  }

  Future<ScoreData> scores(String? years, String? semesterValue) async {
    await checkLogin();

    if (!Helper.isSupportCacheData) {
      final query = await apQuery(
        'ag008',
        <String, String?>{'arg01': years, 'arg02': semesterValue},
      );
      return ScoreData.fromJson(
        WebApParser.instance.scoresParser(query.data as String),
      );
    }

    final cacheKey = '${scoresCacheKey}_${years}_$semesterValue';
    final query = await apQuery(
      'ag008',
      <String, String?>{'arg01': years, 'arg02': semesterValue},
      cacheKey: cacheKey,
      cacheExpiredTime: const Duration(hours: 6),
    );

    final parsedData = WebApParser.instance.scoresParser(query.data as String);
    if ((parsedData['scores'] as List<dynamic>).isEmpty) {
      _manager.delete(cacheKey);
    }

    return ScoreData.fromJson(parsedData);
  }

  Future<CourseData> getCourseTable({String? year, String? semester}) async {
    if (!Helper.isSupportCacheData) {
      final query = await apQuery(
        'ag222',
        <String, String?>{'arg01': year, 'arg02': semester},
        bytesResponse: true,
      );
      return CourseData.fromJson(
        await WebApParser.instance.coursetableParser(query.data),
      );
    }

    final cacheKey = '${coursetableCacheKey}_${year}_$semester';
    final query = await apQuery(
      'ag222',
      <String, String?>{'arg01': year, 'arg02': semester},
      cacheKey: cacheKey,
      cacheExpiredTime: const Duration(hours: 6),
      bytesResponse: true,
    );

    final parsedData = await WebApParser.instance.coursetableParser(query.data);
    if ((parsedData['courses'] as List<dynamic>).isEmpty) {
      _manager.delete(cacheKey);
    }

    return CourseData.fromJson(parsedData);
  }

  Future<MidtermAlertsData> midtermAlerts(
    String? years,
    String? semesterValue,
  ) async {
    final query = await apQuery(
      'ag009',
      <String, String?>{'arg01': years, 'arg02': semesterValue},
    );
    return MidtermAlertsData.fromJson(
      WebApParser.instance.midtermAlertsParser(query.data as String),
    );
  }

  Future<RewardAndPenaltyData> rewardAndPenalty(
    String? years,
    String? semesterValue,
  ) async {
    final query = await apQuery(
      'ak010',
      <String, String?>{'arg01': years, 'arg02': semesterValue},
    );
    return RewardAndPenaltyData.fromJson(
      WebApParser.instance.rewardAndPenaltyParser(query.data as String),
    );
  }

  Future<RoomData> roomList(
    String cmpAreaId,
    String? years,
    String? semesterValue,
  ) async {
    final query = await apQuery(
      'ag302_01',
      <String, String>{
        'yms_yms': '$years#$semesterValue',
        'cmp_area_id': cmpAreaId,
      },
    );
    return RoomData.fromJson(
      WebApParser.instance.roomListParser(query.data as String),
    );
  }

  Future<CourseData> roomCourseTableQuery(
    String? roomId,
    String? years,
    String? semesterValue,
  ) async {
    final query = await apQuery(
      'ag302_02',
      <String, String?>{'room_id': roomId, 'yms_yms': '$years#$semesterValue'},
      bytesResponse: true,
    );
    return CourseData.fromJson(
      WebApParser.instance.roomCourseTableQueryParser(query.data),
    );
  }

  Future<void> loginVms() async {
    await MobileNkustHelper.instance.loginVms(
      username: Helper.username!,
      password: Helper.password!,
    );
  }
}
