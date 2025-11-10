import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:ap_common/ap_common.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/io.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:nkust_ap/api/ap_status_code.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/api/leave_helper.dart';
import 'package:nkust_ap/api/mobile_nkust_helper.dart';
import 'package:nkust_ap/api/parser/ap_parser.dart';
import 'package:nkust_ap/api/parser/api_tool.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';
import 'package:nkust_ap/models/reward_and_penalty_data.dart';
import 'package:nkust_ap/models/room_data.dart';
import 'package:nkust_ap/utils/captcha_utils.dart';

class WebApHelper {
  static WebApHelper? _instance;

  late Dio dio;
  late DioCacheManager _manager;
  late CookieJar cookieJar;

  static int reLoginReTryCountsLimit = 3;
  static int reLoginReTryCounts = 0;

  bool isLogin = false;

  String? pictureUrl;

  //cache key name
  static String get semesterCacheKey => 'semesterCacheKey';

  static String get coursetableCacheKey =>
      '${Helper.username}_coursetableCacheKey';

  static String get scoresCacheKey => '${Helper.username}_scoresCacheKey';

  static String get userInfoCacheKey => '${Helper.username}_userInfoCacheKey';

  //ignore: prefer_constructors_over_static_methods
  static WebApHelper get instance {
    return _instance ??= WebApHelper();
  }

  WebApHelper() {
    dioInit();
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

  Future<void> logout() async {
    try {
      await dio.post('https://webap.nkust.edu.tw/nkust/reclear.jsp');
    } catch (_) {}
  }

  void dioInit() {
    // Use PrivateCookieManager to overwrite origin CookieManager, because
    // Cookie name of the NKUST ap system not follow the RFC6265. :(
    dio = Dio();
    cookieJar = CookieJar();
    if (Helper.isSupportCacheData) {
      _manager = DioCacheManager(
        CacheConfig(baseUrl: 'https://webap.nkust.edu.tw'),
      );
      dio.interceptors.add(_manager.interceptor as Interceptor);
    }
    dio.interceptors.add(PrivateCookieManager(cookieJar));
    dio.options.headers['user-agent'] =
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36';
    dio.options.headers['Connection'] = 'close';
    dio.options.connectTimeout = const Duration(
      milliseconds: Constants.timeoutMs,
    );
    dio.options.receiveTimeout = const Duration(
      milliseconds: Constants.timeoutMs,
    );
    if (Platform.isIOS || Platform.isMacOS || Platform.isAndroid) {
      dio.httpClientAdapter = NativeAdapter();
    }
  }

  Future<Uint8List?> getValidationImage() async {
    final Response<Uint8List> response = await dio.get<Uint8List>(
      'https://webap.nkust.edu.tw/nkust/validateCode.jsp',
      options: Options(
        responseType: ResponseType.bytes,
        headers: <String, dynamic>{
          'Referer': 'https://webap.nkust.edu.tw/nkust/index_main.html',
        },
      ),
    );
    return response.data;
  }

  Future<LoginResponse> login({
    required String username,
    required String password,
    int retryCounts = 5,
  }) async {
    //
    /*
    Retrun type Int
    -1: captcha error
    0 : Login Success
    1 : Password error or not found user
    2 : Relogin
    3 : Not found login message
    */
    //
    for (int i = 0; i < retryCounts; i++) {
      try {
        final String? captchaCode = await CaptchaUtils.extractByEucDist(
          bodyBytes: await getValidationImage(),
        );

        log(username);
        log(password);
        log(captchaCode);

        if (captchaCode == null || captchaCode.length != 4) {
          //Captcha error, go retry.
          continue;
        }

        final Response<dynamic> res = await dio.post(
          'https://webap.nkust.edu.tw/nkust/perchk.jsp',
          data: <String, String>{
            'uid': username,
            'pwd': password,
            'etxt_code': captchaCode,
          },
          options: Options(contentType: 'application/x-www-form-urlencoded'),
        );
        Helper.username = username;
        Helper.password = password;
        final int code = WebApParser.instance.apLoginParser(res.data);
        switch (code) {
          case -1:
            //Captcha error, go retry.
            break;  //break switch
          case 4:
            //Stay old password and relogin.
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
              message: 'username or password error',
            );
          case 500:
            throw GeneralResponse(
              statusCode: ApStatusCode.schoolServerError,
              message: 'school server error',
            );
          default:
            throw GeneralResponse(
              statusCode: code,
              message: 'unknown error',
            );
        }
      } catch (e, s) {
        CrashlyticsUtil.instance.recordError(e, s);
        log(e.toString());
      }
    }
    //
    throw GeneralResponse(
      statusCode: ApStatusCode.unknownError,
      message: 'captcha error or unknown error',
    );
  }

  Future<Response<dynamic>> stayOldPwd() async {
    final Response<dynamic> res = await dio.post(
      'https://webap.nkust.edu.tw/nkust/system/sys010_stay.jsp',
      data: <String, String>{
        'cpwd': '',
        'opwd': '',
        'spwd': '',
      },
      options: Options(
        followRedirects: false,
        validateStatus: (int? status) {
          return status! < 500;
        },
        contentType: 'application/x-www-form-urlencoded',
      ),
    );
    return res;
  }

  Future<LoginResponse> loginToMobile() async {
    // Login leave.nkust from webap.
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw GeneralResponse(
        statusCode: ApStatusCode.networkConnectFail,
        message: 'Login exceeded retry limit',
      );
    }
    await checkLogin();
    await apQuery('ag304_01', null);

    Response<String> res = await dio.post<String>(
      'https://webap.nkust.edu.tw/nkust/fnc.jsp',
      data: <String, String>{'fncid': 'CK004'},
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );

    final Map<String, dynamic> skyDirectData =
        WebApParser.instance.webapToleaveParser(res.data);

    res = await (Dio()
          ..interceptors.add(
            PrivateCookieManager(cookieJar),
          ))
        .post(
      'https://mobile.nkust.edu.tw/Account/LoginBySkytekPortalNewWindow',
      data: skyDirectData,
      options: Options(
        followRedirects: false,
        validateStatus: (int? status) {
          return status! < 500;
        },
        contentType: 'application/x-www-form-urlencoded',
      ),
    );

    if (res.statusCode == 200 && res.data!.contains('/Student/Leave/Create')) {
      return LoginResponse(
        expireTime: DateTime.now().add(const Duration(hours: 1)),
      );
    } else {
      throw GeneralResponse(statusCode: ApStatusCode.cancel, message: 'cancel');
    }
  }

  Future<LoginResponse> loginToOosaf() async {
    // Login oosaf.nkust from webap.
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw GeneralResponse(
        statusCode: ApStatusCode.networkConnectFail,
        message: 'Login exceeded retry limit',
      );
    }
    await checkLogin();
    await apQuery('ag304_01', null);

    Response<String> res = await dio.post<String>(
      'https://webap.nkust.edu.tw/nkust/fnc.jsp',
      data: <String, String>{'fncid': 'CK004'},
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );

    final Map<String, dynamic> skyDirectData =
        WebApParser.instance.webapToleaveParser(res.data);

    res = await (Dio()
          ..interceptors.add(
            PrivateCookieManager(cookieJar),
          ))
        .post(
      'https://oosaf.nkust.edu.tw/Account/LoginBySkytekPortalNewWindow',
      data: skyDirectData,
      options: Options(
        followRedirects: false,
        validateStatus: (int? status) {
          return status! < 500;
        },
        contentType: 'application/x-www-form-urlencoded',
      ),
    );

    if (res.statusCode == 200 && res.data!.contains('/Student/Leave/Create')) {
      return LoginResponse(
        expireTime: DateTime.now().add(const Duration(hours: 1)),
      );
    } else {
      throw GeneralResponse(statusCode: ApStatusCode.cancel, message: 'cancel');
    }
  }

  Future<LoginResponse> loginToStdsys() async {
    // Login stdsys.nkust from webap.
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw GeneralResponse(
        statusCode: ApStatusCode.networkConnectFail,
        message: 'Login exceeded retry limit',
      );
    }
    await checkLogin();
    await apQuery('ag304_01', null);

    Response<String> res = await dio.post<String>(
      'https://webap.nkust.edu.tw/nkust/fnc.jsp',
      data: <String, String>{'fncid': 'CK004'},
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );

    final Map<String, dynamic> skyDirectData =
        WebApParser.instance.webapToleaveParser(res.data);

    res = await (Dio()
          ..interceptors.add(
            PrivateCookieManager(cookieJar),
          ))
        .post(
      'https://stdsys.nkust.edu.tw/Student/Account/LoginBySkytekPortalNewWindow',
      data: skyDirectData,
      options: Options(
        followRedirects: false,
        validateStatus: (int? status) {
          return status! < 500;
        },
        contentType: 'application/x-www-form-urlencoded',
      ),
    );

    if (res.statusCode == 200 && res.data!.contains('/Student/Home/Index')) {
      return LoginResponse(
        expireTime: DateTime.now().add(const Duration(hours: 1)),
      );
    } else {
      throw GeneralResponse(statusCode: ApStatusCode.cancel, message: 'cancel');
    }
  }

  Future<LoginResponse> loginToLeave() async {
    // Login leave.nkust from webap.
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw GeneralResponse(
        statusCode: ApStatusCode.networkConnectFail,
        message: 'Login exceeded retry limit',
      );
    }
    await checkLogin();
    await apQuery('ag304_01', null);

    Response<String> res = await dio.post(
      'https://webap.nkust.edu.tw/nkust/fnc.jsp',
      data: <String, String>{'fncid': 'CK004'},
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );
    final Map<String?, dynamic> skyDirectData =
        WebApParser.instance.webapToleaveParser(res.data);
    res = await dio.get<String>(
      'https://leave.nkust.edu.tw/SkyDir.aspx',
      queryParameters: <String, dynamic>{
        'u': skyDirectData['uid'],
        'r': skyDirectData['ls_randnum'],
      },
      options: Options(
        followRedirects: false,
        validateStatus: (int? status) {
          return status! < 500;
        },
        contentType: 'application/x-www-form-urlencoded',
      ),
    );
    if (res.data!.contains('masterindex.aspx')) {
      res = await dio.get(
        'https://leave.nkust.edu.tw/masterindex.aspx',
        options: Options(
          followRedirects: false,
          validateStatus: (int? status) {
            return status! < 500;
          },
          contentType: 'application/x-www-form-urlencoded',
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
    return isLogin
        ? null
        : await login(username: Helper.username!, password: Helper.password!);
  }

  Future<Response<dynamic>> apQuery(
    String queryQid,
    Map<String, String?>? queryData, {
    String? cacheKey,
    Duration? cacheExpiredTime,
    bool? bytesResponse,
  }) async {
    /*
    Retrun type Response <Dio>
    */
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw GeneralResponse(
        statusCode: ApStatusCode.networkConnectFail,
        message: 'Login exceeded retry limit',
      );
    }
    await checkLogin();
    final String url =
        'https://webap.nkust.edu.tw/nkust/${queryQid.substring(0, 2)}_pro/$queryQid.jsp';
    Options options;
    dynamic requestData;
    if (cacheKey == null) {
      options = Options(contentType: 'application/x-www-form-urlencoded');
      dio.options.headers['Referer'] =
          'https://webap.nkust.edu.tw/nkust/system/sys001_00.jsp?spath=ag_pro/$queryQid.jsp?';
      if (bytesResponse != null) {
        options.responseType = ResponseType.bytes;
      }
      requestData = queryData;
    } else {
      dio.options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
      dio.options.headers['Referer'] =
          'https://webap.nkust.edu.tw/nkust/system/sys001_00.jsp?spath=ag_pro/$queryQid.jsp?';
      Options? otherOptions;
      if (bytesResponse != null) {
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

    if (bytesResponse != null) {
      request = await dio.post<List<int>>(
        url,
        data: requestData,
        options: options,
      );
    } else {
      request = await dio.post<dynamic>(
        url,
        data: requestData,
        options: options,
      );
    }

    if (WebApParser.instance.apLoginParser(request.data) == 2) {
      if (Helper.isSupportCacheData) _manager.delete(cacheKey!);
      reLoginReTryCounts += 1;
      await login(username: Helper.username!, password: Helper.password!);
      return apQuery(queryQid, queryData, bytesResponse: bytesResponse);
    }
    reLoginReTryCounts = 0;
    return request;
  }

  Future<UserInfo> userInfoCrawler() async {
    if (!Helper.isSupportCacheData) {
      final Response<dynamic> query = await apQuery('ag003', null);
      final UserInfo data = UserInfo.fromJson(
        WebApParser.instance.apUserInfoParser(query.data as String),
      );
      pictureUrl = data.pictureUrl;
      return data;
    }
    final Response<dynamic> query = await apQuery(
      'ag003',
      null,
      cacheKey: userInfoCacheKey,
      cacheExpiredTime: const Duration(hours: 6),
    );

    final Map<String, dynamic> parsedData =
        WebApParser.instance.apUserInfoParser(query.data as String);
    if (parsedData['id'] == null) {
      _manager.delete(userInfoCacheKey);
    }
    final UserInfo data = UserInfo.fromJson(
      WebApParser.instance.apUserInfoParser(query.data as String),
    );
    pictureUrl = data.pictureUrl;
    return data;
  }

  Future<Uint8List?> getUserPicture() async {
    dio.options.headers['Accept'] =
        'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8';
    final Response<Uint8List> response = await dio.get<Uint8List>(
      pictureUrl!,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );
    return response.data;
  }

  Future<SemesterData> semesters() async {
    if (!Helper.isSupportCacheData) {
      final Response<dynamic> query = await apQuery('ag304_01', null);
      return SemesterData.fromJson(
        WebApParser.instance.semestersParser(query.data as String),
      );
    }
    final Response<dynamic> query = await apQuery(
      'ag304_01',
      null,
      cacheKey: semesterCacheKey,
      cacheExpiredTime: const Duration(hours: 3),
    );
    final Map<String, dynamic> parsedData =
        WebApParser.instance.semestersParser(query.data as String);
    if ((parsedData['data'] as List<dynamic>).isEmpty) {
      //data error delete cache
      _manager.delete(semesterCacheKey);
    }

    return SemesterData.fromJson(parsedData);
  }

  Future<Response<Uint8List>> getEnrollmentLetter() async {
    await loginToStdsys();

    final List<Cookie> cookies =
        await cookieJar.loadForRequest(Uri.parse('https://stdsys.nkust.edu.tw'));
    final String cookieHeader = cookies
        .map((Cookie cookie) => '${cookie.name}=${cookie.value}')
        .join('; ');

    final Response<Uint8List> response = await dio.get<Uint8List>(
      'https://stdsys.nkust.edu.tw/student/Doc/Status/Download',
      options: Options(
        responseType: ResponseType.bytes,
        headers: <String, dynamic>{
          'Referer': 'https://stdsys.nkust.edu.tw/student/Doc/Status',
          'Cookie': cookieHeader,
        },
      ),
    );
    return response;
  }

  Future<ScoreData> scores(String? years, String? semesterValue) async {
    await checkLogin();
    if (!Helper.isSupportCacheData) {
      final Response<dynamic> query = await apQuery(
        'ag008',
        <String, String?>{'arg01': years, 'arg02': semesterValue},
      );
      return ScoreData.fromJson(
        WebApParser.instance.scoresParser(query.data as String),
      );
    }
    final Response<dynamic> query = await apQuery(
      'ag008',
      <String, String?>{'arg01': years, 'arg02': semesterValue},
      cacheKey: '${scoresCacheKey}_${years}_$semesterValue',
      cacheExpiredTime: const Duration(hours: 6),
    );

    final Map<String, dynamic> parsedData =
        WebApParser.instance.scoresParser(query.data as String);
    if ((parsedData['scores'] as List<dynamic>).isEmpty) {
      _manager.delete('${scoresCacheKey}_${years}_$semesterValue');
    }

    return ScoreData.fromJson(
      parsedData,
    );
  }

  Future<CourseData> getCourseTable({
    String? year,
    String? semester,
  }) async {
    if (!Helper.isSupportCacheData) {
      final Response<dynamic> query = await apQuery(
        'ag222',
        <String, String?>{
          'arg01': year,
          'arg02': semester,
        },
        bytesResponse: true,
      );
      return CourseData.fromJson(
        await WebApParser.instance.coursetableParser(query.data),
      );
    }
    final Response<dynamic> query = await apQuery(
      'ag222',
      <String, String?>{'arg01': year, 'arg02': semester},
      cacheKey: '${coursetableCacheKey}_${year}_$semester',
      cacheExpiredTime: const Duration(hours: 6),
      bytesResponse: true,
    );
    final Map<String, dynamic> parsedData =
        await WebApParser.instance.coursetableParser(query.data);
    if ((parsedData['courses'] as List<dynamic>).isEmpty) {
      _manager.delete('${coursetableCacheKey}_${year}_$semester');
    }
    return CourseData.fromJson(
      parsedData,
    );
  }

  Future<MidtermAlertsData> midtermAlerts(
    String? years,
    String? semesterValue,
  ) async {
    final Response<dynamic> query = await apQuery(
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
    final Response<dynamic> query = await apQuery(
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
    /*
    cmpAreaId
    1=建工/2=燕巢/3=第一/4=楠梓/5=旗津
    */
    final Response<dynamic> query = await apQuery(
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
    final Response<dynamic> query = await apQuery(
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
