import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:ap_common/ap_common.dart';
import 'package:ap_common_firebase/ap_common_firebase.dart';
import 'package:ap_common_plugin/ap_common_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:nkust_ap/api/ap_helper.dart';
import 'package:nkust_ap/api/ap_status_code.dart';
import 'package:nkust_ap/api/bus_helper.dart';
import 'package:nkust_ap/api/exceptions/api_exception.dart';
import 'package:nkust_ap/api/leave_helper.dart';
import 'package:nkust_ap/api/mobile_nkust_helper.dart';
import 'package:nkust_ap/api/nkust_helper.dart';
import 'package:nkust_ap/api/stdsys_helper.dart';
import 'package:nkust_ap/models/booking_bus_data.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/models/cancel_bus_data.dart';
import 'package:nkust_ap/models/crawler_selector.dart';
import 'package:nkust_ap/models/leave_data.dart';
import 'package:nkust_ap/models/leave_submit_data.dart';
import 'package:nkust_ap/models/leave_submit_info_data.dart';
import 'package:nkust_ap/models/library_info_data.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/models/reward_and_penalty_data.dart';
import 'package:nkust_ap/models/room_data.dart';
import 'package:nkust_ap/models/server_info_data.dart';
import 'package:nkust_ap/api/capability/bus_provider.dart';
import 'package:nkust_ap/api/capability/course_provider.dart';
import 'package:nkust_ap/api/capability/leave_provider.dart';
import 'package:nkust_ap/api/capability/score_provider.dart';
import 'package:nkust_ap/api/capability/semester_provider.dart';
import 'package:nkust_ap/api/capability/user_info_provider.dart';
import 'package:nkust_ap/api/scraper_registry.dart';
import 'package:nkust_ap/api/session_state.dart';
import 'package:nkust_ap/utils/global.dart';

class Helper {
  static const String host = 'nkust.taki.dog';

  static const String version = 'v3';

  //LOGIN API
  static const int userDataError = 1401;

  static Helper? _instance;

  late Dio dio;

  late BaseOptions options;

  JsonCodec? jsonCodec;

  static CancelToken? cancelToken;

  static String? username;
  static String? password;

  static DateTime? expireTime;

  static CrawlerSelector? selector;

  /// Registry for resolving capability providers at runtime.
  final ScraperRegistry registry = ScraperRegistry();

  /// Cleanup callbacks registered by sub-helpers.
  /// Called during [clearSetting] so each helper can reset its own state.
  final List<FutureOr<void> Function()> _cleanupCallbacks = [];

  /// Registers a cleanup callback to be called during [clearSetting].
  /// Each sub-helper should register its own cleanup in its constructor.
  void registerCleanup(FutureOr<void> Function() callback) {
    _cleanupCallbacks.add(callback);
  }

  /// Unified session state for all scrapers.
  /// Will replace the scattered static fields (username/password/expireTime)
  /// and per-helper isLogin booleans in a future step.
  ScraperSessionState _sessionState = const Unauthenticated();
  ScraperSessionState get sessionState => _sessionState;

  int reLoginCount = 0;

  bool get canReLogin => reLoginCount == 0;

  bool isExpire() {
    if (expireTime == null) {
      return false;
    } else {
      return DateTime.now().isAfter(expireTime!.add(const Duration(hours: 8)));
    }
  }

  //ignore: prefer_constructors_over_static_methods
  static Helper get instance {
    return _instance ??= Helper();
  }

  /// Fires whenever any scraper helper (WebAP / Bus / Leave) completes a
  /// successful (re)login.
  ///
  /// UI layers that had a request exhaust its retry budget can listen here
  /// to retry themselves once another operation has restored the session.
  Stream<void> get onReloginSuccess => _reloginSuccessController.stream;

  final StreamController<void> _reloginSuccessController =
      StreamController<void>.broadcast();

  Helper() {
    final String apiHost =
        PreferenceUtil.instance.getString(Constants.apiHost, host);
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://$apiHost/$version',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    cancelToken = CancelToken();
    _registerProviders();
  }

  static void resetInstance() {
    _instance = Helper();
    cancelToken = CancelToken();
  }

  /// Registers all capability providers in the [registry].
  ///
  /// Adding a new scraper source requires only:
  /// 1. Implementing the relevant capability interface(s)
  /// 2. Registering it here
  /// No switch statements need to be modified.
  void _registerProviders() {
    // WebApHelper: course, score, userInfo, semester
    registry.register<CourseProvider>(
      ScraperSource.webap, WebApHelper.instance,
    );
    registry.register<ScoreProvider>(
      ScraperSource.webap, WebApHelper.instance,
    );
    registry.register<UserInfoProvider>(
      ScraperSource.webap, WebApHelper.instance,
    );
    registry.register<SemesterProvider>(
      ScraperSource.webap, WebApHelper.instance,
    );

    // StdsysHelper: course, score, userInfo, semester
    registry.register<CourseProvider>(
      ScraperSource.stdsys, StdsysHelper.instance,
    );
    registry.register<ScoreProvider>(
      ScraperSource.stdsys, StdsysHelper.instance,
    );
    registry.register<UserInfoProvider>(
      ScraperSource.stdsys, StdsysHelper.instance,
    );
    registry.register<SemesterProvider>(
      ScraperSource.stdsys, StdsysHelper.instance,
    );

    // MobileNkustHelper: course, score, userInfo, bus
    registry.register<CourseProvider>(
      ScraperSource.mobile, MobileNkustHelper.instance,
    );
    registry.register<ScoreProvider>(
      ScraperSource.mobile, MobileNkustHelper.instance,
    );
    registry.register<UserInfoProvider>(
      ScraperSource.mobile, MobileNkustHelper.instance,
    );
    registry.register<BusProvider>(
      ScraperSource.mobile, MobileNkustHelper.instance,
    );

    // BusHelper: bus
    registry.register<BusProvider>(
      ScraperSource.webap, BusHelper.instance,
    );

    // LeaveHelper: leave
    registry.register<LeaveProvider>(
      ScraperSource.webap, LeaveHelper.instance,
    );

    // Forward relogin-success events from every helper that uses
    // ReloginMixin so consumers can subscribe once via
    // [Helper.instance.onReloginSuccess] instead of knowing about each
    // helper individually.
    void forward(Stream<void> source) {
      source.listen((_) {
        if (!_reloginSuccessController.isClosed) {
          _reloginSuccessController.add(null);
        }
      });
    }

    forward(WebApHelper.instance.onReloginSuccess);
    forward(BusHelper.instance.onReloginSuccess);
    forward(LeaveHelper.instance.onReloginSuccess);

    // Register cleanup callbacks for each sub-helper.
    // This replaces the manual cleanup in clearSetting() and ensures
    // all helpers (including previously-missed LeaveHelper) are reset.
    registerCleanup(() async {
      await WebApHelper.instance.logout();
      WebApHelper.instance.dioInit();
      WebApHelper.instance.isLogin = false;
    });
    registerCleanup(() {
      BusHelper.instance.isLogin = false;
      BusHelper.instance.dioInit();
    });
    registerCleanup(() {
      LeaveHelper.instance.isLogin = null;
    });
    registerCleanup(() {
      MobileNkustHelper.instance.cookiesData?.clear();
    });
  }

  Future<LoginResponse?> login({
    required String username,
    required String password,
    bool clearCache = false,
  }) async {
    Helper.username = username.toUpperCase();
    Helper.password = password;
    LoginResponse? loginResponse;
    loginResponse = await _call(() async {
      final LoginResponse? result = await WebApHelper.instance.login(
        username: username.toUpperCase(),
        password: password,
      );
      if (selector?.login == ScraperSource.mobile) {
        await WebApHelper.instance.loginVms();
      }
      return result;
    });
    if (loginResponse != null) {
      expireTime = loginResponse.expireTime;
      _sessionState = Authenticated(
        username: Helper.username!,
        expireTime: loginResponse.expireTime ?? DateTime.now(),
      );
    }
    return loginResponse;
  }

  Future<LoginResponse> adminLogin(String username, String password) async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.post<Map<String, dynamic>>(
        '/oauth/admin/token',
        data: <String, String>{
          'username': username,
          'password': password,
        },
      );
      final LoginResponse loginResponse =
          LoginResponse.fromJson(response.data!);
      options.headers = _createBearerTokenAuth(loginResponse.token);
      expireTime = loginResponse.expireTime;
      Helper.username = username;
      Helper.password = password;
      return loginResponse;
    } catch (dioError) {
      rethrow;
    }
  }

  Future<Response<dynamic>> deleteToken() async {
    try {
      final Response<dynamic> response = await dio.delete(
        '/oauth/token',
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response<dynamic>> deleteAllToken() async {
    try {
      final Response<dynamic> response = await dio.delete(
        '/oauth/token/all',
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<ServerInfoData> getServerInfoData() async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.get<Map<String, dynamic>>('​/server​/info');
      return ServerInfoData.fromJson(response.data!);
    } on DioException {
      rethrow;
    }
  }

  Future<List<Announcement>> getAllAnnouncements({
    String? locale,
  }) async {
    final Response<Map<String, dynamic>> response =
        await dio.get<Map<String, dynamic>>(
      '/news/announcements/all',
      queryParameters: <String, String>{
        'lang': locale ?? '',
      },
    );
    AnnouncementData data = AnnouncementData(
      data: <Announcement>[],
    );
    if (response.statusCode != 204) {
      data = AnnouncementData.fromJson(response.data!);
      data.data.sort((Announcement a, Announcement b) {
        return b.weight.compareTo(a.weight);
      });
    }
    return data.data;
  }

  Future<Response<dynamic>> addAnnouncement(Announcement announcements) async {
    try {
      final Response<dynamic> response = await dio.post(
        '/news/announcements/add',
        data: announcements.toUpdateJson(),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response<dynamic>> updateAnnouncement(
    Announcement announcements,
  ) async {
    try {
      final Response<dynamic> response = await dio.put(
        '/news/announcements/update/${announcements.id}',
        data: announcements.toUpdateJson(),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response<dynamic>> deleteAnnouncement(
    Announcement announcements,
  ) async {
    try {
      final Response<dynamic> response = await dio.delete(
        '/news/announcements/remove/${announcements.id}',
        data: announcements.toUpdateJson(),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<UserInfo> getUsersInfo() async {
    return _call(() async {
      final provider = registry.resolve<UserInfoProvider>(selector?.userInfo);
      UserInfo data = await provider.getUserInfo();
      reLoginCount = 0;
      if (data.id.isEmpty) {
        data = data.copyWith(
          id: username!,
        );
      }
      return data;
    });
  }

  Future<Uint8List?> getUserPicture(String pictureUrl) async {
    return _call(() async {
      final provider = registry.resolve<UserInfoProvider>(selector?.userInfo);
      return provider.getUserPicture(pictureUrl);
    });
  }

  Future<SemesterData> getSemester() async {
    return _call(() async {
      SemesterData? data;
      log(selector?.semester.toString() ?? '');
      if (selector?.semester == ScraperSource.remoteConfig) {
        data = SemesterData.load();
        await Future<void>.delayed(const Duration(milliseconds: 100));
      } else {
        final provider = registry.resolve<SemesterProvider>(selector?.semester);
        data = await provider.getSemesters();
      }
      reLoginCount = 0;
      if (data == null) {
        throw ServerException(message: 'empty semester data');
      }
      return data;
    });
  }

  /// Runs a crawler-facing operation and normalises every escaping
  /// exception into an [ApException] subtype:
  ///
  /// - [ApException] → rethrown as-is. High-signal subtypes
  ///   ([ServerException], [CaptchaException]) are also logged to
  ///   Crashlytics so regressions in the school system or captcha OCR
  ///   stay visible; low-signal ones (user wrong password, network off,
  ///   user cancellation) are not logged to avoid noise.
  /// - [DioException] → translated to the matching subtype (network /
  ///   server / cancelled) via [DioExceptionToApException].
  /// - Anything else (TypeError, FormatException, StateError, plugin
  ///   failures…) → recorded to Crashlytics and wrapped as
  ///   [UnknownException] so the UI's single `on ApException catch`
  ///   clause can surface a user-visible "未知錯誤" message instead of
  ///   the call silently disappearing.
  Future<T> _call<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on ApException catch (e, s) {
      _maybeRecordApException(e, s);
      rethrow;
    } on DioException catch (e, s) {
      final ApException translated = e.toApException();
      _maybeRecordApException(translated, s);
      throw translated;
    } catch (e, s) {
      CrashlyticsUtil.instance.recordError(e, s);
      throw UnknownException(
        message: '${e.runtimeType}: $e',
        cause: e,
        causeStackTrace: s,
      );
    }
  }

  /// High-signal ApException subtypes go to Crashlytics so regressions in
  /// the school system or captcha OCR stay visible. Low-signal ones
  /// (wrong password, no internet, user cancellation) are skipped to
  /// keep the dashboard usable.
  void _maybeRecordApException(ApException e, StackTrace s) {
    if (e is ServerException || e is CaptchaException) {
      CrashlyticsUtil.instance.recordError(e, s, reason: e.typeName);
    }
  }

  /// Specialisation of [_call] for bus endpoints: translates the bus
  /// system's HTTP status conventions into typed subtypes before the
  /// outer [_call] sees them.
  ///
  /// - 401 → [AccountNotSupportedException] (non-student, blocked account).
  /// - 403 → [CampusNotSupportedException] (campus without shuttle bus).
  ///
  /// These are user-facing states, not regressions, so they skip the
  /// Crashlytics pathway in `_maybeRecordApException`.
  Future<T> _busCall<T>(Future<T> Function() body) async {
    return _call(() async {
      try {
        return await body();
      } on DioException catch (e) {
        final int? code = e.response?.statusCode;
        if (code == 401) throw const AccountNotSupportedException();
        if (code == 403) throw const CampusNotSupportedException();
        rethrow;
      }
    });
  }

  /// Specialisation of [_call] for leave endpoints: maps the leave
  /// system's HTTP 403 to [AccountNotSupportedException] (the only
  /// business-semantic status we currently translate for leave).
  Future<T> _leaveCall<T>(Future<T> Function() body) async {
    return _call(() async {
      try {
        return await body();
      } on DioException catch (e) {
        if (e.response?.statusCode == 403) {
          throw const AccountNotSupportedException();
        }
        rethrow;
      }
    });
  }

  Future<ScoreData?> getScores({
    required Semester semester,
  }) async {
    return _call(() async {
      log('Fetch(Score) ${selector?.score} '
          '${semester.year} ${semester.code}');
      final provider = registry.resolve<ScoreProvider>(selector?.score);
      ScoreData? data = await provider.getScores(
        year: semester.year,
        semester: semester.value,
      );
      if (data != null && data.scores.isEmpty) data = null;
      return data;
    });
  }

  Future<CourseData> getCourseTables({
    required Semester semester,
  }) async {
    return _call(() async {
      log('Fetch(CourseTable) ${selector?.course} '
          '${semester.year} ${semester.code}');
      final provider = registry.resolve<CourseProvider>(selector?.course);
      final CourseData data = await provider.getCourseTable(
        year: semester.year,
        semester: semester.value,
      );
      if (data.courses.isNotEmpty) {
        reLoginCount = 0;
      }
      return data;
    });
  }

  Future<RewardAndPenaltyData> getRewardAndPenalty({
    required Semester semester,
  }) async {
    return _call(() async {
      final RewardAndPenaltyData data =
          await WebApHelper.instance.rewardAndPenalty(
        semester.year,
        semester.value,
      );
      reLoginCount = 0;
      return data;
    });
  }

  Future<MidtermAlertsData> getMidtermAlerts({
    required Semester semester,
  }) async {
    return _call(() async {
      return WebApHelper.instance.midtermAlerts(
        semester.year,
        semester.value,
      );
    });
  }

  //1=建工/2=燕巢/3=第一/4=楠梓/5=旗津/6=東方
  Future<RoomData> getRoomList({
    required Semester semester,
    required int campusCode,
  }) async {
    return _call(() async {
      final RoomData data = await StdsysHelper.instance
          .roomList('$campusCode', semester.year, semester.value);
      reLoginCount = 0;
      return data;
    });
  }

  Future<CourseData> getRoomCourseTables({
    required String? roomId,
    required Semester semester,
  }) async {
    return _call(() async {
      final CourseData data = await StdsysHelper.instance.roomCourseTableQuery(
        roomId,
        semester.year,
        semester.value,
      );
      reLoginCount = 0;
      return data;
    });
  }

  Future<BusData> getBusTimeTables({
    required DateTime dateTime,
  }) async {
    return _busCall(() async {
      if (!MobileNkustHelper.isSupport) {
        throw const PlatformUnsupportedException();
      }
      final provider = registry.resolve<BusProvider>(null);
      final BusData data = await provider.getTimeTable(dateTime: dateTime);
      reLoginCount = 0;
      if (data.canReserve) {
        return data;
      }
      // Business-rule failure (outside reservation window / full).
      // Preserve the server's Chinese description but leave
      // httpStatusCode null so the typed-subtype layer doesn't treat
      // this like a real HTTP 403 "campus not supported".
      throw ServerException(
        message: data.description ?? 'bus not reservable',
      );
    });
  }

  Future<BusReservationsData> getBusReservations() async {
    return _busCall(() async {
      if (!MobileNkustHelper.isSupport) {
        throw const PlatformUnsupportedException();
      }
      final provider = registry.resolve<BusProvider>(null);
      final BusReservationsData data = await provider.getReservations();
      reLoginCount = 0;
      return data;
    });
  }

  Future<BookingBusData> bookingBusReservation({
    required String busId,
  }) async {
    return _busCall(() async {
      if (!MobileNkustHelper.isSupport) {
        throw const PlatformUnsupportedException();
      }
      final provider = registry.resolve<BusProvider>(null);
      final BookingBusData data = await provider.bookBus(busId: busId);
      reLoginCount = 0;
      return data;
    });
  }

  Future<CancelBusData> cancelBusReservation({
    required String cancelKey,
  }) async {
    return _busCall(() async {
      if (!MobileNkustHelper.isSupport) {
        throw const PlatformUnsupportedException();
      }
      final provider = registry.resolve<BusProvider>(null);
      final CancelBusData data = await provider.cancelBus(busId: cancelKey);
      reLoginCount = 0;
      return data;
    });
  }

  Future<BusViolationRecordsData> getBusViolationRecords() async {
    return _busCall(() async {
      if (!MobileNkustHelper.isSupport) {
        throw const PlatformUnsupportedException();
      }
      final provider = registry.resolve<BusProvider>(null);
      final BusViolationRecordsData data =
          await provider.getViolationRecords();
      reLoginCount = 0;
      return data;
    });
  }

  Future<NotificationsData> getNotifications({
    required int page,
  }) async {
    return _call(() async {
      return NKUSTHelper.instance.getNotifications(page);
    });
  }

  Future<UserInfo> searchUsername({
    required String rocId,
    required DateTime birthday,
  }) async {
    return _call(() async {
      return NKUSTHelper.instance.getUsername(
        rocId: rocId,
        birthday: birthday,
      );
    });
  }

  Future<LeaveData> getLeaves({
    required Semester semester,
  }) async {
    return _leaveCall(() async {
      final provider = registry.resolve<LeaveProvider>(null);
      return provider.getLeaves(
        year: semester.year,
        semester: semester.value,
      );
    });
  }

  Future<Response<Uint8List>> getEnrollmentLetter(
    EnrollmentLetterLang lang,
  ) async {
    return _call(() async {
      return StdsysHelper.instance.getEnrollmentLetter(lang);
    });
  }

  Future<LeaveSubmitInfoData> getLeavesSubmitInfo() async {
    return _leaveCall(() async {
      final provider = registry.resolve<LeaveProvider>(null);
      return provider.getSubmitInfo();
    });
  }

  Future<Response<dynamic>?> sendLeavesSubmit({
    required LeaveSubmitData data,
    required XFile? image,
  }) async {
    return _leaveCall(() async {
      final provider = registry.resolve<LeaveProvider>(null);
      return provider.submit(data, proofImage: image);
    });
  }

  Future<LibraryInfo?> getLibraryInfo() async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.get<Map<String, dynamic>>(
        '/leaves/submit/info',
        cancelToken: cancelToken,
      );
      if (response.statusCode == 204) {
        return null;
      } else {
        return LibraryInfoData.fromJson(response.data!).data;
      }
    } on DioException {
      rethrow;
    }
  }

  // v3 api Authorization
  Map<String, dynamic> _createBearerTokenAuth(String? token) {
    return <String, String>{
      'Authorization': 'Bearer $token',
    };
  }

  static Future<void> clearSetting() async {
    instance._sessionState = const Unauthenticated();
    expireTime = null;
    username = null;
    password = null;
    ApCommonPlugin.clearCourseWidget();
    ApCommonPlugin.clearUserInfoWidget();

    // Call all registered cleanup callbacks from sub-helpers.
    for (final callback in instance._cleanupCallbacks) {
      await callback();
    }
  }
}

extension NewsExtension on Announcement {
  Map<String, dynamic> toUpdateJson() => <String, dynamic>{
        'title': title,
        'weight': weight,
        'imgUrl': imgUrl,
        'url': url,
        'description': description,
        'expireTime': expireTime,
      };
}

extension DioErrorExtension on DioException {
  bool get hasResponse => type == DioExceptionType.badResponse;
}

extension GeneralResponseExtension on GeneralResponse {
  String getGeneralMessage(
    BuildContext context,
  ) {
    String message = '';
    switch (statusCode) {
      case ApStatusCode.schoolServerError:
        message = ap.schoolServerError;
      case GeneralResponse.platformNotSupportCode:
        message = ap.platformError;
      default:
        message = ap.unknownError;
    }
    AnalyticsUtil.instance.logApiEvent(
      'GeneralResponse',
      statusCode,
      message: message,
    );
    return message;
  }
}

extension SemesterExtension on Semester {
  String get cacheSaveTag => '${Helper.username}_$code';
}
