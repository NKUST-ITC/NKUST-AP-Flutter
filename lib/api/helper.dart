import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ap_common/models/announcement_data.dart';
import 'package:ap_common/models/course_data.dart';
import 'package:ap_common/models/notification_data.dart';
import 'package:ap_common/models/score_data.dart';
import 'package:ap_common/models/semester_data.dart';
import 'package:ap_common/models/user_info.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common_firebase/utils/firebase_crashlytics_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:nkust_ap/api/ap_helper.dart';
import 'package:nkust_ap/api/ap_status_code.dart';
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

export 'package:ap_common/callback/general_callback.dart';

class Helper {
  static const String host = 'nkust.taki.dog';

  static const String version = 'v3';

  //LOGIN API
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

  /// From sqflite plugin setting
  static bool isSupportCacheData = false;

  static CrawlerSelector? selector;

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

  Helper() {
    final String apiHost = Preferences.getString(Constants.apiHost, host);
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://$apiHost/$version',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
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
    Helper.username = username;
    Helper.password = password;
    try {
      LoginResponse? loginResponse;
      switch (selector?.login) {
        case mobile:
        case webap:
        default:
          if (selector != null && (selector!.login == mobile)) {
            loginResponse = await WebApHelper.instance.login(
              username: username,
              password: password,
            );
            await WebApHelper.instance.loginToMobile();
          } else {
            loginResponse = await WebApHelper.instance.login(
              username: username,
              password: password,
            );
          }
          break;
      }
      expireTime = loginResponse.expireTime;
      callback.onSuccess(loginResponse);
    } on GeneralResponse catch (response) {
      callback.onError(response);
      rethrow;
    } on DioException catch (e) {
      callback.onFailure(e);
      rethrow;
    } catch (e) {
      callback.onError(
        GeneralResponse.unknownError(),
      );
      rethrow;
    }
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

  Future<void> getAllAnnouncements({
    String? locale,
    GeneralCallback<List<Announcement>?>? callback,
  }) async {
    try {
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
      return (callback == null) ? data.data : callback.onSuccess(data.data);
    } on DioException catch (dioError) {
      if (callback == null) {
        rethrow;
      } else {
        callback.onFailure(dioError);
      }
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported) {
        await FirebaseCrashlytics.instance.recordError(e, s);
      }
    }
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

  Future<UserInfo?> getUsersInfo({
    GeneralCallback<UserInfo>? callback,
  }) async {
    try {
      UserInfo data;
      switch (selector?.userInfo) {
        case mobile:
          data = await MobileNkustHelper.instance.getUserInfo();
          break;
        case webap:
        default:
          data = await WebApHelper.instance.userInfoCrawler();
          break;
      }
      reLoginCount = 0;
      if (data.id.isEmpty) {
        data.copyWith(
          id: username,
        );
      }
      return (callback == null) ? data : callback.onSuccess(data) as UserInfo?;
    } on DioException catch (dioError) {
      callback?.onFailure(dioError);
      if (callback == null) rethrow;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported) {
        await FirebaseCrashlytics.instance.recordError(e, s);
      }
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
          break;
        case inkust:
          //TODO
          break;
        case mobile:
          //TODO
          break;
        case webap:
        default:
          data = await WebApHelper.instance.semesters();
          break;
      }
      reLoginCount = 0;
      return (callback == null)
          ? data
          : callback.onSuccess(data!) as SemesterData?;
    } on DioException catch (dioError) {
      callback?.onFailure(dioError);
      if (callback == null) rethrow;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported) {
        await FirebaseCrashlytics.instance.recordError(e, s);
      }
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
          break;
        case inkust:
          //TODO
          break;
        case webap:
        default:
          data = await WebApHelper.instance.scores(
            semester.year,
            semester.value,
          );
          break;
      }
      if (data != null && data.scores.isEmpty) data = null;
      return (callback == null) ? data : callback.onSuccess(data) as ScoreData?;
    } on DioException catch (dioError) {
      callback?.onFailure(dioError);
      if (callback == null) rethrow;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported) {
        await FirebaseCrashlytics.instance.recordError(e, s);
      }
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
          final bool isDefault = semesterDefault!.code == semester.code;
          data = await MobileNkustHelper.instance.getCourseTable(
            year: isDefault ? null : semester.year,
            semester: isDefault ? null : semester.value,
          );
          break;
        case webap:
        default:
          data = await WebApHelper.instance.getCourseTable(
            year: semester.year,
            semester: semester.value,
          );
          break;
      }
      if (data.courses.isNotEmpty) {
        reLoginCount = 0;
      }
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioException catch (dioError) {
      if (selector?.course == mobile && dioError.response?.statusCode == 302) {
        FirebaseAnalyticsUtils.instance.logEvent(
          'mobile_user_agent_error',
          parameters: <String, dynamic>{
            'message': MobileNkustHelper.instance.userAgent,
          },
        );
      }
      callback?.onFailure(dioError);
      if (callback == null) rethrow;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported) {
        await FirebaseCrashlytics.instance.recordError(e, s);
      }
    }
  }

  Future<void> getRewardAndPenalty({
    required Semester semester,
    required GeneralCallback<RewardAndPenaltyData> callback,
  }) async {
    try {
      final RewardAndPenaltyData data =
          await WebApHelper.instance.rewardAndPenalty(
        semester.year,
        semester.value,
      );
      reLoginCount = 0;
      callback.onSuccess(data);
    } on DioException catch (dioError) {
      callback.onFailure(dioError);
    } catch (e, s) {
      callback.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported) {
        await FirebaseCrashlytics.instance.recordError(e, s);
      }
    }
  }

  Future<void> getMidtermAlerts({
    required Semester semester,
    required GeneralCallback<MidtermAlertsData> callback,
  }) async {
    try {
      final MidtermAlertsData data = await WebApHelper.instance.midtermAlerts(
        semester.year,
        semester.value,
      );
      callback.onSuccess(data);
    } on DioException catch (dioError) {
      callback.onFailure(dioError);
    } catch (e, s) {
      callback.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported) {
        await FirebaseCrashlytics.instance.recordError(e, s);
      }
    }
  }

  //1=建工 /2=燕巢/3=第一/4=楠梓/5=旗津
  Future<void> getRoomList({
    // required Semester semester,
    required int campusCode,
    required GeneralCallback<RoomData> callback,
  }) async {
    try {
      final RoomData data = await WebApHelper.instance.roomList(
          '$campusCode',
          // semester.year,
          // semester.value,
        '112',
        '1',
      );

      reLoginCount = 0;
      callback.onSuccess(data);
    } on DioException catch (dioError) {
      callback.onFailure(dioError);
    } catch (e, s) {
      callback.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported) {
        await FirebaseCrashlytics.instance.recordError(e, s);
      }
    }
  }

  Future<void> getRoomCourseTables({
    required String? roomId,
    required Semester semester,
    required GeneralCallback<CourseData> callback,
  }) async {
    try {
      final CourseData data = await WebApHelper.instance.roomCourseTableQuery(
        roomId,
        semester.year,
        semester.value,
      );
      reLoginCount = 0;
      callback.onSuccess(data);
    } on DioException catch (dioError) {
      callback.onFailure(dioError);
    } catch (e, s) {
      callback.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported) {
        await FirebaseCrashlytics.instance.recordError(e, s);
      }
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
      final BusData data = await MobileNkustHelper.instance.busTimeTableQuery(
        fromDateTime: dateTime,
      );
      reLoginCount = 0;
      if (data.canReserve) {
        callback.onSuccess(data);
        return;
      } else {
        callback.onError(
          GeneralResponse(
            statusCode: 403,
            message: data.description!,
          ),
        );
        return;
      }
    } on DioException catch (dioError) {
      if (dioError.hasResponse) {
        BusHelper.reLoginReTryCounts = 0;
        if (dioError.isServerError) {
          callback.onError(dioError.serverErrorResponse);
        } else {
          callback.onFailure(dioError);
        }
      } else {
        callback.onFailure(dioError);
      }
    } catch (e, s) {
      callback.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported) {
        await FirebaseCrashlytics.instance.recordError(e, s);
      }
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
      final BusReservationsData data =
          await MobileNkustHelper.instance.busUserRecord();
      reLoginCount = 0;
      callback.onSuccess(data);
      return;
    } on DioException catch (dioError) {
      if (dioError.hasResponse) {
        BusHelper.reLoginReTryCounts = 0;

        if (dioError.isServerError) {
          callback.onError(dioError.serverErrorResponse);
        } else {
          callback.onFailure(dioError);
        }
      } else {
        callback.onFailure(dioError);
      }
    } catch (e, s) {
      callback.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported) {
        await FirebaseCrashlytics.instance.recordError(e, s);
      }
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
      final BookingBusData data =
          await MobileNkustHelper.instance.busBook(busId: busId);
      reLoginCount = 0;
      callback.onSuccess(data);
      return;
    } on DioException catch (dioError) {
      if (dioError.hasResponse) {
        BusHelper.reLoginReTryCounts = 0;

        if (dioError.isServerError) {
          callback.onError(dioError.serverErrorResponse);
        } else {
          callback.onFailure(dioError);
        }
      } else {
        callback.onFailure(dioError);
      }
    } catch (e, s) {
      callback.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported) {
        await FirebaseCrashlytics.instance.recordError(e, s);
      }
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
      final CancelBusData data =
          await MobileNkustHelper.instance.busUnBook(busId: cancelKey);
      reLoginCount = 0;
      callback.onSuccess(data);
      return;
    } on DioException catch (dioError) {
      if (dioError.hasResponse) {
        BusHelper.reLoginReTryCounts = 0;

        if (dioError.isServerError) {
          callback.onError(dioError.serverErrorResponse);
        } else {
          callback.onFailure(dioError);
        }
      } else {
        callback.onFailure(dioError);
      }
    } catch (e, s) {
      callback.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported) {
        await FirebaseCrashlytics.instance.recordError(e, s);
      }
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
      final BusViolationRecordsData data =
          await MobileNkustHelper.instance.busViolationRecords();
      reLoginCount = 0;
      callback.onSuccess(data);
      return;
    } on DioException catch (dioError) {
      if (dioError.hasResponse) {
        BusHelper.reLoginReTryCounts = 0;

        if (dioError.isServerError) {
          callback.onError(dioError.serverErrorResponse);
        } else {
          callback.onFailure(dioError);
        }
      } else {
        callback.onFailure(dioError);
      }
    } catch (e, s) {
      callback.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported) {
        await FirebaseCrashlytics.instance.recordError(e, s);
      }
    }
  }

  Future<void> getNotifications({
    required int page,
    required GeneralCallback<NotificationsData> callback,
  }) async {
    try {
      final NotificationsData data =
          await NKUSTHelper.instance.getNotifications(page);
      callback.onSuccess(data);
    } on DioException catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isServerError) {
          callback.onError(dioError.serverErrorResponse);
        } else {
          callback.onFailure(dioError);
        }
      } else {
        callback.onFailure(dioError);
      }
    } catch (e, s) {
      callback.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported) {
        await FirebaseCrashlytics.instance.recordError(e, s);
      }
    }
  }

  Future<void> getLeaves({
    required Semester semester,
    required GeneralCallback<LeaveData> callback,
  }) async {
    try {
      final LeaveData data = await LeaveHelper.instance
          .getLeaves(year: semester.year, semester: semester.value);

      callback.onSuccess(data);
    } on DioException catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isServerError) {
          callback.onError(dioError.serverErrorResponse);
        } else {
          callback.onFailure(dioError);
        }
      } else {
        callback.onFailure(dioError);
      }
    } catch (e, s) {
      callback.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported) {
        await FirebaseCrashlytics.instance.recordError(e, s);
      }
    }
  }

  Future<void> getLeavesSubmitInfo({
    required GeneralCallback<LeaveSubmitInfoData> callback,
  }) async {
    try {
      final LeaveSubmitInfoData data =
          await LeaveHelper.instance.getLeavesSubmitInfo();
      callback.onSuccess(data);
    } on DioException catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isServerError) {
          callback.onError(dioError.serverErrorResponse);
        } else {
          callback.onFailure(dioError);
        }
      } else {
        callback.onFailure(dioError);
      }
    } catch (e, s) {
      callback.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported) {
        await FirebaseCrashlytics.instance.recordError(e, s);
      }
    }
  }

  Future<void> sendLeavesSubmit({
    required LeaveSubmitData data,
    required XFile? image,
    required GeneralCallback<Response<dynamic>?> callback,
  }) async {
    try {
      final Response<dynamic>? res =
          await LeaveHelper.instance.leavesSubmit(data, proofImage: image);
      callback.onSuccess(res);
    } on DioException catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isServerError) {
          callback.onError(dioError.serverErrorResponse);
        } else {
          callback.onFailure(dioError);
        }
      } else {
        callback.onFailure(dioError);
      }
    } catch (e, s) {
      callback.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported) {
        await FirebaseCrashlytics.instance.recordError(e, s);
      }
    }
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

  bool get isExpire => response!.statusCode == ApStatusCode.apiExpire;

  bool get isServerError =>
      response!.statusCode == ApStatusCode.schoolServerError ||
      response!.statusCode == ApStatusCode.apiServerError;

  GeneralResponse get serverErrorResponse {
    switch (response!.statusCode) {
      case ApStatusCode.apiServerError:
        return GeneralResponse(
          statusCode: ApStatusCode.apiServerError,
          message: 'api server error',
        );
      case ApStatusCode.schoolServerError:
      default:
        return GeneralResponse(
          statusCode: ApStatusCode.schoolServerError,
          message: 'shool server error',
        );
    }
  }
}

extension GeneralResponseExtension on GeneralResponse {
  String getGeneralMessage(
    BuildContext context,
  ) {
    final ApLocalizations ap = ApLocalizations.current;
    String message = '';
    switch (statusCode) {
      case ApStatusCode.schoolServerError:
        message = ap.schoolServerError;
        break;
      case ApStatusCode.apiServerError:
        message = ap.schoolServerError;
        break;
      case ApStatusCode.apiExpire:
        message = ap.tokenExpiredContent;
        break;
      case GeneralResponse.platformNotSupportCode:
        message = ap.platformError;
        break;
      default:
        message = ap.unknownError;
        break;
    }
    FirebaseAnalyticsUtils.instance.logApiEvent(
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
