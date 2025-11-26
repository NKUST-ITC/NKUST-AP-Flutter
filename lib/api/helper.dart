import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ap_common/ap_common.dart';
import 'package:ap_common_firebase/ap_common_firebase.dart';
import 'package:flutter/cupertino.dart';
import 'package:nkust_ap/api/ap_helper.dart';
import 'package:nkust_ap/api/ap_status_code.dart';
import 'package:nkust_ap/api/api_config.dart';
import 'package:nkust_ap/api/bus_helper.dart';
import 'package:nkust_ap/api/leave_helper.dart';
import 'package:nkust_ap/api/mobile_nkust_helper.dart';
import 'package:nkust_ap/api/nkust_helper.dart';
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
import 'package:nkust_ap/utils/global.dart';

class Helper {
  static const String host = 'nkust.taki.dog';
  static const String version = 'v3';

  static const int userDataError = 1401;

  static const String webap = 'webap';
  static const String inkust = 'inkust';
  static const String mobile = 'mobile';
  static const String remoteConfig = 'config';

  static Helper? _instance;

  late Dio dio;
  late BaseOptions options;

  JsonCodec? jsonCodec;

  static CancelToken? cancelToken;

  static String? username;
  static String? password;

  static DateTime? expireTime;

  static bool isSupportCacheData = false;

  static CrawlerSelector? selector;

  int reLoginCount = 0;

  bool get canReLogin => reLoginCount == 0;

  bool isExpire() {
    if (expireTime == null) return false;
    return DateTime.now().isAfter(expireTime!.add(const Duration(hours: 8)));
  }

  static Helper get instance => _instance ??= Helper();

  Helper() {
    final apiHost = PreferenceUtil.instance.getString(Constants.apiHost, host);

    dio = ApiConfig.createDio(
      baseUrl: 'https://$apiHost/$version',
      enableGzip: true,
    );

    cancelToken = CancelToken();
  }

  static void resetInstance() {
    _instance = Helper();
    cancelToken = CancelToken();
  }

  Future<void> login({
    required BuildContext context,
    required String username,
    required String password,
    required GeneralCallback<LoginResponse?> callback,
    bool clearCache = false,
  }) async {
    Helper.username = username.toUpperCase();
    Helper.password = password;

    try {
      LoginResponse? loginResponse;

      switch (selector?.login) {
        case mobile:
        case webap:
        default:
          if (selector != null && selector!.login == mobile) {
            loginResponse = await WebApHelper.instance.login(
              username: username.toUpperCase(),
              password: password,
            );
            await WebApHelper.instance.loginVms();
          } else {
            loginResponse = await WebApHelper.instance.login(
              username: username.toUpperCase(),
              password: password,
            );
          }
      }

      expireTime = loginResponse.expireTime;
      callback.onSuccess(loginResponse);
    } on GeneralResponse catch (response) {
      callback.onError(response);
    } on DioException catch (e) {
      callback.onFailure(e);
    } catch (e, s) {
      _logError('login', e, s);
      callback.onError(GeneralResponse.unknownError());
    }
  }

  Future<LoginResponse> adminLogin(String username, String password) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/oauth/admin/token',
      data: <String, String>{
        'username': username,
        'password': password,
      },
    );

    final loginResponse = LoginResponse.fromJson(response.data!);
    options.headers = _createBearerTokenAuth(loginResponse.token);
    expireTime = loginResponse.expireTime;
    Helper.username = username;
    Helper.password = password;

    return loginResponse;
  }

  Future<Response<dynamic>> deleteToken() async {
    return dio.delete<dynamic>('/oauth/token');
  }

  Future<Response<dynamic>> deleteAllToken() async {
    return dio.delete<dynamic>('/oauth/token/all');
  }

  Future<ServerInfoData> getServerInfoData() async {
    final response = await dio.get<Map<String, dynamic>>('/server/info');
    return ServerInfoData.fromJson(response.data!);
  }

  Future<void> getAllAnnouncements({
    String? locale,
    GeneralCallback<List<Announcement>?>? callback,
  }) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/news/announcements/all',
        queryParameters: <String, String>{'lang': locale ?? ''},
      );

      var data = AnnouncementData(data: <Announcement>[]);

      if (response.statusCode != 204) {
        data = AnnouncementData.fromJson(response.data!);
        data.data.sort((a, b) => b.weight.compareTo(a.weight));
      }

      callback?.onSuccess(data.data);
    } on DioException catch (e) {
      callback?.onFailure(e);
    } catch (e, s) {
      _logError('getAllAnnouncements', e, s);
      callback?.onError(GeneralResponse.unknownError());
    }
  }

  Future<Response<dynamic>> addAnnouncement(Announcement announcement) async {
    return dio.post<dynamic>(
      '/news/announcements/add',
      data: announcement.toUpdateJson(),
    );
  }

  Future<Response<dynamic>> updateAnnouncement(
    Announcement announcement,
  ) async {
    return dio.put<dynamic>(
      '/news/announcements/update/${announcement.id}',
      data: announcement.toUpdateJson(),
    );
  }

  Future<Response<dynamic>> deleteAnnouncement(
    Announcement announcement,
  ) async {
    return dio.delete<dynamic>(
      '/news/announcements/remove/${announcement.id}',
      data: announcement.toUpdateJson(),
    );
  }

  Future<UserInfo?> getUsersInfo({
    GeneralCallback<UserInfo>? callback,
  }) async {
    try {
      UserInfo data;

      switch (selector?.userInfo) {
        case mobile:
          data = await MobileNkustHelper.instance.getUserInfo();
        case webap:
        default:
          data = await WebApHelper.instance.userInfoCrawler();
      }

      reLoginCount = 0;

      if (data.id.isEmpty) {
        data = data.copyWith(id: username);
      }

      callback?.onSuccess(data);
      return data;
    } on DioException catch (e) {
      callback?.onFailure(e);
    } catch (e, s) {
      _logError('getUsersInfo', e, s);
      callback?.onError(GeneralResponse.unknownError());
    }
    return null;
  }

  Future<Uint8List?> getUserPicture() async {
    switch (selector?.userInfo) {
      case mobile:
        return MobileNkustHelper.instance.getUserPicture();
      case webap:
      default:
        return WebApHelper.instance.getUserPicture();
    }
  }

  Future<SemesterData?> getSemester({
    GeneralCallback<SemesterData>? callback,
  }) async {
    try {
      SemesterData? data;

      switch (selector?.semester) {
        case remoteConfig:
          data = SemesterData.load();
          await Future<void>.delayed(const Duration(milliseconds: 100));
        case inkust:
        case mobile:
          break;
        case webap:
        default:
          data = await WebApHelper.instance.semesters();
      }

      reLoginCount = 0;
      callback?.onSuccess(data!);
      return data;
    } on DioException catch (e) {
      callback?.onFailure(e);
    } catch (e, s) {
      _logError('getSemester', e, s);
      callback?.onError(GeneralResponse.unknownError());
    }
    return null;
  }

  Future<ScoreData?> getScores({
    required Semester semester,
    GeneralCallback<ScoreData?>? callback,
  }) async {
    try {
      ScoreData? data;

      switch (selector?.score) {
        case mobile:
          data = await MobileNkustHelper.instance.getScores(
            year: semester.year,
            semester: semester.value,
          );
        case inkust:
          break;
        case webap:
        default:
          data = await WebApHelper.instance.scores(
            semester.year,
            semester.value,
          );
      }

      if (data != null && data.scores.isEmpty) data = null;
      callback?.onSuccess(data);
      return data;
    } on DioException catch (e) {
      callback?.onFailure(e);
    } catch (e, s) {
      _logError('getScores', e, s);
      callback?.onError(GeneralResponse.unknownError());
    }
    return null;
  }

  Future<void> getCourseTables({
    required Semester semester,
    Semester? semesterDefault,
    required GeneralCallback<CourseData?>? callback,
  }) async {
    try {
      CourseData data;

      switch (selector?.course) {
        case mobile:
          final isDefault = semesterDefault!.code == semester.code;
          data = await MobileNkustHelper.instance.getCourseTable(
            year: isDefault ? null : semester.year,
            semester: isDefault ? null : semester.value,
          );
        case webap:
        default:
          data = await WebApHelper.instance.getCourseTable(
            year: semester.year,
            semester: semester.value,
          );
      }

      if (data.courses.isNotEmpty) reLoginCount = 0;
      callback?.onSuccess(data);
    } on DioException catch (e) {
      if (selector?.course == mobile && e.response?.statusCode == 302) {
        AnalyticsUtil.instance.logEvent(
          'mobile_user_agent_error',
          parameters: <String, dynamic>{
            'message': MobileNkustHelper.instance.userAgent,
          },
        );
      }
      callback?.onFailure(e);
    } catch (e, s) {
      _logError('getCourseTables', e, s);
      callback?.onError(GeneralResponse.unknownError());
    }
  }

  Future<void> getRewardAndPenalty({
    required Semester semester,
    required GeneralCallback<RewardAndPenaltyData> callback,
  }) async {
    try {
      final data = await WebApHelper.instance.rewardAndPenalty(
        semester.year,
        semester.value,
      );
      reLoginCount = 0;
      callback.onSuccess(data);
    } on DioException catch (e) {
      callback.onFailure(e);
    } catch (e, s) {
      _logError('getRewardAndPenalty', e, s);
      callback.onError(GeneralResponse.unknownError());
    }
  }

  Future<void> getMidtermAlerts({
    required Semester semester,
    required GeneralCallback<MidtermAlertsData> callback,
  }) async {
    try {
      final data = await WebApHelper.instance.midtermAlerts(
        semester.year,
        semester.value,
      );
      callback.onSuccess(data);
    } on DioException catch (e) {
      callback.onFailure(e);
    } catch (e, s) {
      _logError('getMidtermAlerts', e, s);
      callback.onError(GeneralResponse.unknownError());
    }
  }

  Future<void> getRoomList({
    required int campusCode,
    required GeneralCallback<RoomData> callback,
  }) async {
    try {
      final data = await WebApHelper.instance.roomList(
        '$campusCode',
        '112',
        '1',
      );
      reLoginCount = 0;
      callback.onSuccess(data);
    } on DioException catch (e) {
      callback.onFailure(e);
    } catch (e, s) {
      _logError('getRoomList', e, s);
      callback.onError(GeneralResponse.unknownError());
    }
  }

  Future<void> getRoomCourseTables({
    required String? roomId,
    required Semester semester,
    required GeneralCallback<CourseData> callback,
  }) async {
    try {
      final data = await WebApHelper.instance.roomCourseTableQuery(
        roomId,
        semester.year,
        semester.value,
      );
      reLoginCount = 0;
      callback.onSuccess(data);
    } on DioException catch (e) {
      callback.onFailure(e);
    } catch (e, s) {
      _logError('getRoomCourseTables', e, s);
      callback.onError(GeneralResponse.unknownError());
    }
  }

  Future<void> getBusTimeTables({
    required DateTime dateTime,
    required GeneralCallback<BusData> callback,
  }) async {
    try {
      if (!MobileNkustHelper.isSupport) {
        callback.onError(GeneralResponse.platformNotSupport());
        return;
      }

      final data = await MobileNkustHelper.instance.busTimeTableQuery(
        fromDateTime: dateTime,
      );

      reLoginCount = 0;

      if (data.canReserve) {
        callback.onSuccess(data);
      } else {
        callback.onError(
          GeneralResponse(statusCode: 403, message: data.description!),
        );
      }
    } on DioException catch (e) {
      _handleBusError(e, callback);
    } catch (e, s) {
      _logError('getBusTimeTables', e, s);
      callback.onError(GeneralResponse.unknownError());
    }
  }

  Future<void> getBusReservations({
    required GeneralCallback<BusReservationsData> callback,
  }) async {
    try {
      if (!MobileNkustHelper.isSupport) {
        callback.onError(GeneralResponse.platformNotSupport());
        return;
      }

      final data = await MobileNkustHelper.instance.busUserRecord();
      reLoginCount = 0;
      callback.onSuccess(data);
    } on DioException catch (e) {
      _handleBusError(e, callback);
    } catch (e, s) {
      _logError('getBusReservations', e, s);
      callback.onError(GeneralResponse.unknownError());
    }
  }

  Future<void> bookingBusReservation({
    required String busId,
    required GeneralCallback<BookingBusData> callback,
  }) async {
    try {
      if (!MobileNkustHelper.isSupport) {
        callback.onError(GeneralResponse.platformNotSupport());
        return;
      }

      final data = await MobileNkustHelper.instance.busBook(busId: busId);
      reLoginCount = 0;
      callback.onSuccess(data);
    } on DioException catch (e) {
      _handleBusError(e, callback);
    } catch (e, s) {
      _logError('bookingBusReservation', e, s);
      callback.onError(GeneralResponse.unknownError());
    }
  }

  Future<void> cancelBusReservation({
    required String cancelKey,
    required GeneralCallback<CancelBusData> callback,
  }) async {
    try {
      if (!MobileNkustHelper.isSupport) {
        callback.onError(GeneralResponse.platformNotSupport());
        return;
      }

      final data = await MobileNkustHelper.instance.busUnBook(busId: cancelKey);
      reLoginCount = 0;
      callback.onSuccess(data);
    } on DioException catch (e) {
      _handleBusError(e, callback);
    } catch (e, s) {
      _logError('cancelBusReservation', e, s);
      callback.onError(GeneralResponse.unknownError());
    }
  }

  Future<void> getBusViolationRecords({
    required GeneralCallback<BusViolationRecordsData> callback,
  }) async {
    try {
      if (!MobileNkustHelper.isSupport) {
        callback.onError(GeneralResponse.platformNotSupport());
        return;
      }

      final data = await MobileNkustHelper.instance.busViolationRecords();
      reLoginCount = 0;
      callback.onSuccess(data);
    } on DioException catch (e) {
      _handleBusError(e, callback);
    } catch (e, s) {
      _logError('getBusViolationRecords', e, s);
      callback.onError(GeneralResponse.unknownError());
    }
  }

  Future<void> getNotifications({
    required int page,
    required GeneralCallback<NotificationsData> callback,
  }) async {
    try {
      final data = await NKUSTHelper.instance.getNotifications(page);
      callback.onSuccess(data);
    } on DioException catch (e) {
      _handleServerError(e, callback);
    } catch (e, s) {
      _logError('getNotifications', e, s);
      callback.onError(GeneralResponse.unknownError());
    }
  }

  Future<void> getLeaves({
    required Semester semester,
    required GeneralCallback<LeaveData> callback,
  }) async {
    try {
      final data = await LeaveHelper.instance.getLeaves(
        year: semester.year,
        semester: semester.value,
      );
      callback.onSuccess(data);
    } on DioException catch (e) {
      _handleServerError(e, callback);
    } catch (e, s) {
      _logError('getLeaves', e, s);
      callback.onError(GeneralResponse.unknownError());
    }
  }

  Future<void> getLeavesSubmitInfo({
    required GeneralCallback<LeaveSubmitInfoData> callback,
  }) async {
    try {
      final data = await LeaveHelper.instance.getLeavesSubmitInfo();
      callback.onSuccess(data);
    } on DioException catch (e) {
      _handleServerError(e, callback);
    } catch (e, s) {
      _logError('getLeavesSubmitInfo', e, s);
      callback.onError(GeneralResponse.unknownError());
    }
  }

  Future<void> sendLeavesSubmit({
    required LeaveSubmitData data,
    required XFile? image,
    required GeneralCallback<Response<dynamic>?> callback,
  }) async {
    try {
      final res = await LeaveHelper.instance.leavesSubmit(
        data,
        proofImage: image,
      );
      callback.onSuccess(res);
    } on DioException catch (e) {
      _handleServerError(e, callback);
    } catch (e, s) {
      _logError('sendLeavesSubmit', e, s);
      callback.onError(GeneralResponse.unknownError());
    }
  }

  Future<LibraryInfo?> getLibraryInfo() async {
    final response = await dio.get<Map<String, dynamic>>(
      '/leaves/submit/info',
      cancelToken: cancelToken,
    );

    if (response.statusCode == 204) return null;
    return LibraryInfoData.fromJson(response.data!).data;
  }

  Map<String, dynamic> _createBearerTokenAuth(String? token) {
    return <String, String>{'Authorization': 'Bearer $token'};
  }

  void _handleBusError<T>(DioException e, GeneralCallback<T> callback) {
    if (e.hasResponse) {
      BusHelper.reLoginReTryCounts = 0;
      if (e.isServerError) {
        callback.onError(e.serverErrorResponse);
      } else {
        callback.onFailure(e);
      }
    } else {
      callback.onFailure(e);
    }
  }

  void _handleServerError<T>(DioException e, GeneralCallback<T> callback) {
    if (e.hasResponse) {
      if (e.isServerError) {
        callback.onError(e.serverErrorResponse);
      } else {
        callback.onFailure(e);
      }
    } else {
      callback.onFailure(e);
    }
  }

  Future<void> _logError(String method, Object e, StackTrace s) async {
    if (FirebaseCrashlyticsUtils.isSupported) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'Helper.$method error',
      );
    }
  }

  static void clearSetting() {
    expireTime = null;
    username = null;
    password = null;
    WebApHelper.instance.logout();
    WebApHelper.instance.dioInit();
    WebApHelper.instance.isLogin = false;
    BusHelper.instance.isLogin = false;
    MobileNkustHelper.instance.cookiesData?.clear();
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

  bool get isExpire => response?.statusCode == ApStatusCode.apiExpire;

  bool get isServerError =>
      response?.statusCode == ApStatusCode.schoolServerError || response?.statusCode == ApStatusCode.apiServerError;

  GeneralResponse get serverErrorResponse {
    switch (response?.statusCode) {
      case ApStatusCode.apiServerError:
        return GeneralResponse(
          statusCode: ApStatusCode.apiServerError,
          message: 'API 伺服器錯誤',
        );
      case ApStatusCode.schoolServerError:
      default:
        return GeneralResponse(
          statusCode: ApStatusCode.schoolServerError,
          message: '學校伺服器錯誤',
        );
    }
  }
}

extension GeneralResponseExtension on GeneralResponse {
  String getGeneralMessage(BuildContext context) {
    final ap = ApLocalizations.current;
    String message;

    switch (statusCode) {
      case ApStatusCode.schoolServerError:
        message = ap.schoolServerError;
      case ApStatusCode.apiServerError:
        message = ap.schoolServerError;
      case ApStatusCode.apiExpire:
        message = ap.tokenExpiredContent;
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
