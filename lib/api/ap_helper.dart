import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:ap_common/ap_common.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/io.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:nkust_ap/api/api_config.dart';
import 'package:nkust_ap/api/ap_status_code.dart';
import 'package:nkust_ap/api/safe_cookie_manager.dart';
import 'package:nkust_ap/api/exceptions/api_exception.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/api/leave_helper.dart';
import 'package:nkust_ap/api/vms_bus_helper.dart';
import 'package:nkust_ap/api/parser/ap_parser.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';
import 'package:nkust_ap/models/reward_and_penalty_data.dart';
import 'package:nkust_ap/models/room_data.dart';
import 'package:nkust_ap/api/relogin_mixin.dart';
import 'package:nkust_ap/api/capability/course_provider.dart';
import 'package:nkust_ap/api/capability/score_provider.dart';
import 'package:nkust_ap/api/capability/semester_provider.dart';
import 'package:nkust_ap/api/capability/user_info_provider.dart';
import 'package:nkust_ap/utils/captcha_utils.dart';

class WebApHelper
    with ReloginMixin
    implements CourseProvider, ScoreProvider, UserInfoProvider, SemesterProvider {
  static WebApHelper? _instance;

  late Dio dio;
  late CookieJar cookieJar;

  /// Guards against concurrent login attempts. When multiple callers trigger
  /// re-login simultaneously (e.g. parallel apQuery calls both get code 2),
  /// only the first one performs the actual captcha login; others wait for
  /// its result.
  Completer<LoginResponse>? _loginInProgress;

  @override
  int get maxRelogins => 3;

  bool isLogin = false;

  //ignore: prefer_constructors_over_static_methods
  static WebApHelper get instance {
    return _instance ??= WebApHelper();
  }

  WebApHelper() {
    dioInit();
  }

  void setProxy(String proxyIP) {
    ApiConfig.setProxy(dio, proxyIP);
  }

  Future<void> logout() async {
    _stdsysLoginExpireTime = null;
    _loginInProgress = null;
    resetReloginState();
    try {
      await dio.post('https://webap.nkust.edu.tw/nkust/reclear.jsp');
    } catch (_) {}
  }

  void dioInit() {
    final (:dio, :cookieJar) = ApiConfig.createScraperDio();
    this.dio = dio;
    this.cookieJar = cookieJar;
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

  /// Logs into WebAP with captcha recognition.
  ///
  /// If a login is already in progress (e.g. triggered by a parallel
  /// [withAutoRelogin] call), subsequent callers wait for the same result
  /// instead of starting a second captcha attempt that could interfere
  /// with the first session.
  Future<LoginResponse> login({
    required String username,
    required String password,
    int retryCounts = 5,
  }) async {
    if (_loginInProgress != null) {
      return _loginInProgress!.future;
    }
    final completer = Completer<LoginResponse>();
    _loginInProgress = completer;
    try {
      final LoginResponse result = await _doLogin(
        username: username,
        password: password,
        retryCounts: retryCounts,
      );
      markReloginSuccess();
      completer.complete(result);
      return result;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _loginInProgress = null;
    }
  }

  Future<LoginResponse> _doLogin({
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
    assert(retryCounts >= 0, 'retryCounts must be >= 0');

    for (int i = 0; i < retryCounts; i++) {
      try {
        final Uint8List? imageBytes = await getValidationImage();

        if (imageBytes == null) {
          continue;
        }

        // extractByEucDist 不會回傳 null，失敗會丟出 exception
        final String captchaCode = await CaptchaUtils.extractByEucDist(
          bodyBytes: imageBytes,
        );

        // perchk.jsp does a server-side CSRF check that emits
        // alert('Please Logon From Homepage!!') when the request lacks
        // the homepage Referer/Origin. Without these, even a correct
        // captcha gets rejected as 驗證碼錯誤.
        final Response<dynamic> res = await dio.post(
          'https://webap.nkust.edu.tw/nkust/perchk.jsp',
          data: <String, String>{
            'uid': username,
            'pwd': password,
            'etxt_code': captchaCode,
          },
          options: Options(
            contentType: 'application/x-www-form-urlencoded',
            headers: <String, String>{
              'Referer': 'https://webap.nkust.edu.tw/nkust/index_main.html',
              'Origin': 'https://webap.nkust.edu.tw',
            },
          ),
        );
        Helper.username = username;
        Helper.password = password;
        final int code = WebApParser.instance.apLoginParser(res.data);
        switch (code) {
          case -1:
            //Captcha error, go retry.
            break;
          case 4:
            //Stay old password and relogin.
            await stayOldPwd();
            return _doLogin(username: username, password: password);
          case 0:
            isLogin = true;
            return LoginResponse(
              expireTime: DateTime.now().add(const Duration(hours: 6)),
            );
          case 1:
            throw AuthException(
              AuthFailureReason.invalidCredentials,
              message: 'username or password error',
            );
          case 5:
            throw AuthException(
              AuthFailureReason.tooManyAttempts,
              message: 'too many failed attempts',
            );
          case 500:
            throw ServerException(
              statusCode: ApStatusCode.schoolServerError,
              message: 'school server error',
            );
          default:
            throw ServerException(
              statusCode: code,
              message: 'unknown login response code: $code',
            );
        }
      } on ApException {
        // Non-captcha auth / server errors should propagate immediately —
        // retrying with the same credentials would only hammer the login
        // endpoint.
        rethrow;
      } on DioException catch (e) {
        // Any DioException — transport failure, server 4xx/5xx, or user
        // cancellation — terminates the captcha retry loop. Another
        // attempt with a fresh captcha cannot help when the HTTP layer
        // itself failed, and retrying a cancelled request would waste
        // work and produce misleading "captcha error" messages.
        throw e.toApException();
      } catch (e, s) {
        // Truly unexpected errors (parser bugs, etc.) are logged and
        // allowed to trigger another captcha attempt.
        CrashlyticsUtil.instance.recordError(e, s);
        log(e.toString());
      }
    }
    //
    throw CaptchaException(
      attempts: retryCounts,
      message: 'captcha failed after $retryCounts attempts',
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
    // Login mobile.nkust from webap.
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
            SafeCookieManager(cookieJar),
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
      throw AuthException(AuthFailureReason.unknown, message: 'cross-system SSO did not land on target page');
    }
  }

  Future<LoginResponse> loginToOosaf() async {
    // Login oosaf.nkust from webap.
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
            SafeCookieManager(cookieJar),
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
      throw AuthException(AuthFailureReason.unknown, message: 'cross-system SSO did not land on target page');
    }
  }

  DateTime? _stdsysLoginExpireTime;

  /// Tracks an in-flight stdsys SSO handshake so concurrent callers
  /// piggy-back on a single login instead of hammering the portal with
  /// duplicate requests. Cleared (successfully or otherwise) once the
  /// handshake returns.
  Completer<LoginResponse>? _stdsysLoginInFlight;

  Future<LoginResponse> loginToStdsys() async {
    // Fast-path: reuse a still-valid cached session.
    if (_stdsysLoginExpireTime != null &&
        DateTime.now().isBefore(_stdsysLoginExpireTime!)) {
      return LoginResponse(expireTime: _stdsysLoginExpireTime!);
    }

    // Single-flight: if another call is already running the SSO flow,
    // await the same future. Errors propagate to every waiter.
    final Completer<LoginResponse>? inFlight = _stdsysLoginInFlight;
    if (inFlight != null) return inFlight.future;

    final Completer<LoginResponse> completer = Completer<LoginResponse>();
    _stdsysLoginInFlight = completer;
    try {
      final LoginResponse response = await _performStdsysLogin();
      completer.complete(response);
      return response;
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
      rethrow;
    } finally {
      _stdsysLoginInFlight = null;
    }
  }

  Future<LoginResponse> _performStdsysLogin() async {
    // Login stdsys.nkust from webap.
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
            SafeCookieManager(cookieJar),
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
      _stdsysLoginExpireTime = DateTime.now().add(const Duration(hours: 1));
      return LoginResponse(
        expireTime: _stdsysLoginExpireTime!,
      );
    } else {
      throw AuthException(AuthFailureReason.unknown, message: 'cross-system SSO did not land on target page');
    }
  }

  Future<LoginResponse> loginToLeave() async {
    // Login leave.nkust from webap.
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
    throw AuthException(AuthFailureReason.unknown, message: 'cross-system SSO did not land on target page');
  }

  Future<LoginResponse?> checkLogin() async {
    return isLogin
        ? null
        : await login(username: Helper.username!, password: Helper.password!);
  }

  Future<Response<dynamic>> apQuery(
    String queryQid,
    Map<String, String?>? queryData, {
    bool? bytesResponse,
  }) async {
    return withAutoRelogin(
      action: () => _doApQuery(queryQid, queryData, bytesResponse: bytesResponse),
      relogin: () async { await login(username: Helper.username!, password: Helper.password!); },
      isSessionExpired: (e) => e is ApSessionExpiredException,
    );
  }

  /// Internal implementation of apQuery without re-login logic.
  /// Throws [ApSessionExpiredException] when server returns code 2.
  Future<Response<dynamic>> _doApQuery(
    String queryQid,
    Map<String, String?>? queryData, {
    bool? bytesResponse,
  }) async {
    await checkLogin();
    final String url =
        'https://webap.nkust.edu.tw/nkust/${queryQid.substring(0, 2)}_pro/$queryQid.jsp';
    final Options options = Options(
      contentType: 'application/x-www-form-urlencoded',
      responseType: bytesResponse != null ? ResponseType.bytes : null,
    );
    dio.options.headers['Referer'] =
        'https://webap.nkust.edu.tw/nkust/system/sys001_00.jsp?spath=ag_pro/$queryQid.jsp?';

    Response<dynamic> request;
    if (bytesResponse != null) {
      request = await dio.post<List<int>>(
        url,
        data: queryData,
        options: options,
      );
    } else {
      request = await dio.post<dynamic>(
        url,
        data: queryData,
        options: options,
      );
    }

    if (WebApParser.instance.apLoginParser(request.data) == 2) {
      throw const ApSessionExpiredException();
    }
    return request;
  }

  Future<UserInfo> userInfoCrawler() async {
    final Response<dynamic> query = await apQuery('ag003', null);
    return UserInfo.fromJson(
      WebApParser.instance.apUserInfoParser(query.data as String),
    );
  }

  Future<SemesterData> semesters() async {
    final Response<dynamic> query = await apQuery('ag304_01', null);
    return SemesterData.fromJson(
      WebApParser.instance.semestersParser(query.data as String),
    );
  }

  @Deprecated('use StdsysHelper.getEnrollmentLetter instead')
  Future<Response<Uint8List>> getEnrollmentLetter() async {
    final List<Cookie> cookies =
        await cookieJar.loadForRequest(Uri.parse('https://webap.nkust.edu.tw'));
    final String cookieHeader = cookies
        .map((Cookie cookie) => '${cookie.name}=${cookie.value}')
        .join('; ');

    final Response<String> res = await dio.post<String>(
      'https://webap.nkust.edu.tw/nkust/fnc.jsp',
      data: <String, String>{'fncid': 'AG225'},
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );

    final Map<String, dynamic> requestData =
        WebApParser.instance.enrollmentRequestParser(res.data);

    final String action = (requestData['action'] as String)
        .replaceAll('ag_pro/', '')
        .replaceAll('.jsp', '');
    final Map<String, String> params =
        requestData['params'] as Map<String, String>;

    final Response<dynamic> query = await apQuery(
      action,
      params,
    );

    final String? pdfPath =
        WebApParser.instance.enrollmentLetterPathParser(query.data as String);

    if (pdfPath == null || pdfPath.isEmpty) {
      throw ServerException(
        message: 'enrollment letter PDF url not found in response',
      );
    }

    final Response<Uint8List> response = await dio.get<Uint8List>(
      'https://webap.nkust.edu.tw/nkust/ag_pro/${pdfPath}',
      options: Options(
        responseType: ResponseType.bytes,
        headers: <String, dynamic>{
          'Referer': 'https://webap.nkust.edu.tw/',
          'Cookie': cookieHeader,
        },
      ),
    );
    return response;
  }

  Future<ScoreData> scores(String? years, String? semesterValue) async {
    await checkLogin();
    final Response<dynamic> query = await apQuery(
      'ag008',
      <String, String?>{'arg01': years, 'arg02': semesterValue},
    );
    return ScoreData.fromJson(
      WebApParser.instance.scoresParser(query.data as String),
    );
  }

  @override
  Future<CourseData> getCourseTable({
    String? year,
    String? semester,
  }) async {
    final Response<dynamic> query = await apQuery(
      'ag222',
      <String, String?>{'arg01': year, 'arg02': semester},
      bytesResponse: true,
    );
    return CourseData.fromJson(
      await WebApParser.instance.coursetableParser(query.data),
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

  @Deprecated('use StdsysHelper.roomList instead')
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
    await VmsBusHelper.instance.loginVms(
      username: Helper.username!,
      password: Helper.password!,
    );
  }

  // -- Capability interface implementations --

  @override
  Future<ScoreData?> getScores({
    required String year,
    required String semester,
  }) async {
    return scores(year, semester);
  }

  @override
  Future<UserInfo> getUserInfo() => userInfoCrawler();

  @override
  Future<Uint8List?> getUserPicture(String? pictureUrl) async {
    if (pictureUrl == null) return null;
    dio.options.headers['Accept'] =
        'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8';
    final Response<Uint8List> response = await dio.get<Uint8List>(
      pictureUrl,
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data;
  }

  @override
  Future<SemesterData?> getSemesters() => semesters();
}
