import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ap_common/callback/general_callback.dart';
import 'package:ap_common/models/announcement_data.dart';
import 'package:ap_common/models/course_data.dart';
import 'package:ap_common/models/notification_data.dart';
import 'package:ap_common/models/score_data.dart';
import 'package:ap_common/models/semester_data.dart';
import 'package:ap_common/models/user_info.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common_firebase/utils/firebase_analytics_utils.dart';
import 'package:ap_common_firebase/utils/firebase_crashlytics_utils.dart';
import 'package:ap_common_firebase/utils/firebase_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nkust_ap/api/ap_helper.dart';
import 'package:nkust_ap/api/ap_status_code.dart';
import 'package:nkust_ap/api/bus_helper.dart';
import 'package:nkust_ap/api/inkust_helper.dart';
import 'package:nkust_ap/api/leave_helper.dart';
import 'package:nkust_ap/api/mobile_nkust_helper.dart';
import 'package:nkust_ap/api/nkust_helper.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/booking_bus_data.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/models/cancel_bus_data.dart';
import 'package:nkust_ap/models/crawler_selector.dart';
import 'package:nkust_ap/models/event_callback.dart';
import 'package:nkust_ap/models/event_info_response.dart';
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
  static const HOST = 'nkust.taki.dog';

  static const VERSION = 'v3';

  //LOGIN API
  static const USER_DATA_ERROR = 1401;

  static const WEBAP = 'webap';
  static const INKUST = 'inkust';
  static const MOBILE = 'mobile';
  static const REMOTE_CONFIG = 'config';

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
    if (expireTime == null)
      return false;
    else
      return DateTime.now().isAfter(expireTime!.add(Duration(hours: 8)));
  }

  static Helper get instance {
    return _instance ??= Helper();
  }

  Helper() {
    var host = Preferences.getString(Constants.API_HOST, HOST);
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://$host/$VERSION',
        connectTimeout: 10000,
        receiveTimeout: 10000,
      ),
    );
    cancelToken = CancelToken();
  }

  static resetInstance() {
    _instance = Helper();
    cancelToken = CancelToken();
  }

  Future<LoginResponse?> login({
    required BuildContext context,
    required String username,
    required String password,
    GeneralCallback<LoginResponse?>? callback,
    bool clearCache = false,
  }) async {
    Helper.username = username;
    Helper.password = password;
    try {
      LoginResponse? loginResponse;
      switch (selector?.login) {
        case INKUST:
          await InkustHelper.instance!.login(
            username: username,
            password: password,
          );
          break;
        case MOBILE:
        case WEBAP:
        default:
          if (selector != null &&
              (selector!.login == MOBILE || selector!.login == null)) {
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
      expireTime = loginResponse!.expireTime;
      if (callback != null)
        return callback.onSuccess(loginResponse);
      else
        return loginResponse;
    } on GeneralResponse catch (response) {
      callback?.onError(response);
    } on DioError catch (e) {
      callback?.onFailure(e);
    } catch (e) {
      callback?.onError(
        GeneralResponse.unknownError(),
      );
      rethrow;
    }
    return null;
  }

  Future<LoginResponse> adminLogin(String username, String password) async {
    try {
      var response = await dio.post(
        '/oauth/admin/token',
        data: {
          'username': username,
          'password': password,
        },
      );
      var loginResponse = LoginResponse.fromJson(response.data);
      options.headers = _createBearerTokenAuth(loginResponse.token);
      expireTime = loginResponse.expireTime;
      Helper.username = username;
      Helper.password = password;
      return loginResponse;
    } catch (dioError) {
      throw dioError;
    }
  }

  Future<Response> deleteToken() async {
    try {
      var response = await dio.delete(
        '/oauth/token',
      );
      return response;
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<Response> deleteAllToken() async {
    try {
      var response = await dio.delete(
        '/oauth/token/all',
      );
      return response;
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<ServerInfoData> getServerInfoData() async {
    try {
      var response = await dio.get("​/server​/info");
      return ServerInfoData.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<List<Announcement>?> getAllAnnouncements({
    String? locale,
    GeneralCallback<List<Announcement>?>? callback,
  }) async {
    try {
      var response = await dio.get(
        "/news/announcements/all",
        queryParameters: {
          'lang': locale ?? '',
        },
      );
      var data = AnnouncementData(data: []);
      if (response.statusCode != 204) {
        data = AnnouncementData.fromJson(response.data);
        data.data.sort((a, b) {
          return b.weight.compareTo(a.weight);
        });
      }
      return (callback == null) ? data.data : callback.onSuccess(data.data);
    } on DioError catch (dioError) {
      if (callback == null)
        throw dioError;
      else
        callback.onFailure(dioError);
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported)
        await FirebaseCrashlytics.instance.recordError(e, s);
    }
    return null;
  }

  Future<Response> addAnnouncement(Announcement announcements) async {
    try {
      var response = await dio.post(
        "/news/announcements/add",
        data: announcements.toUpdateJson(),
      );
      return response;
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<Response> updateAnnouncement(Announcement announcements) async {
    try {
      var response = await dio.put(
        "/news/announcements/update/${announcements.id}",
        data: announcements.toUpdateJson(),
      );
      return response;
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<Response> deleteAnnouncement(Announcement announcements) async {
    try {
      var response = await dio.delete(
        "/news/announcements/remove/${announcements.id}",
        data: announcements.toUpdateJson(),
      );
      return response;
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<UserInfo?> getUsersInfo({
    GeneralCallback<UserInfo>? callback,
  }) async {
    try {
      UserInfo data;
      switch (selector?.userInfo) {
        case MOBILE:
          data = await MobileNkustHelper.instance!.getUserInfo();
          break;
        case WEBAP:
        default:
          data = await WebApHelper.instance.userInfoCrawler();
          break;
      }
      reLoginCount = 0;
      if (data.id.isEmpty)
        data.copyWith(
          id: username,
        );
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported)
        await FirebaseCrashlytics.instance.recordError(e, s);
    }
    return null;
  }

  Future<Uint8List?> getUserPicture() async {
    switch (selector?.userInfo) {
      case MOBILE:
        return await MobileNkustHelper.instance!.getUserPicture();
        break;
      case WEBAP:
      default:
        return await WebApHelper.instance.getUserPicture();
        break;
    }
  }

  Future<SemesterData?> getSemester({
    GeneralCallback<SemesterData>? callback,
  }) async {
    try {
      SemesterData? data;
      switch (selector?.semester) {
        case REMOTE_CONFIG:
          data = SemesterData.load();
          await Future.delayed(Duration(milliseconds: 100));
          break;
        case INKUST:
          //TODO
          break;
        case MOBILE:
          //TODO
          break;
        case WEBAP:
        default:
          data = await WebApHelper.instance.semesters();
          break;
      }
      reLoginCount = 0;
      return (callback == null) ? data : callback.onSuccess(data!);
    } on DioError catch (dioError) {
      callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported)
        await FirebaseCrashlytics.instance.recordError(e, s);
    }
    return null;
  }

  Future<ScoreData?> getScores({
    required Semester? semester,
    GeneralCallback<ScoreData?>? callback,
  }) async {
    try {
      ScoreData? data;
      switch (selector?.score) {
        case MOBILE:
          data = await MobileNkustHelper.instance!.getScores(
            year: semester!.year,
            semester: semester.value,
          );
          break;
        case INKUST:
          //TODO
          break;
        case WEBAP:
        default:
          data = await WebApHelper.instance.scores(
            semester!.year,
            semester.value,
          );
          break;
      }
      if (data != null && data.scores.length == 0) data = null;
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported)
        await FirebaseCrashlytics.instance.recordError(e, s);
    }
    return null;
  }

  Future<CourseData?> getCourseTables({
    required Semester? semester,
    Semester? semesterDefault,
    GeneralCallback<CourseData?>? callback,
  }) async {
    try {
      CourseData? data;
      switch (selector?.course) {
        case MOBILE:
          final isDefault = semesterDefault!.code == semester!.code;
          data = await MobileNkustHelper.instance!.getCourseTable(
            year: isDefault ? null : semester.year,
            semester: isDefault ? null : semester.value,
          );
          break;
        case INKUST:
          data = await InkustHelper.instance!.courseTable(
            semester!.year,
            semester.value,
          );
          break;
        case WEBAP:
        default:
          data = await WebApHelper.instance.getCourseTable(
            year: semester!.year,
            semester: semester.value,
          );
          break;
      }
      if (data != null && data.courses != null && data.courses.length != 0) {
        reLoginCount = 0;
      }
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      if (selector?.course == MOBILE && dioError.response?.statusCode == 302) {
        FirebaseAnalyticsUtils.instance.logEvent(
          'mobile_user_agent_error',
          parameters: {
            'message': MobileNkustHelper.instance!.userAgent,
          },
        );
      }
      callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported)
        await FirebaseCrashlytics.instance.recordError(e, s);
    }
    return null;
  }

  Future<RewardAndPenaltyData?> getRewardAndPenalty({
    required Semester semester,
    GeneralCallback<RewardAndPenaltyData>? callback,
  }) async {
    try {
      var data = await WebApHelper.instance.rewardAndPenalty(
        semester.year,
        semester.value,
      );
      reLoginCount = 0;
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported)
        await FirebaseCrashlytics.instance.recordError(e, s);
    }
    return null;
  }

  Future<MidtermAlertsData?> getMidtermAlerts({
    required Semester semester,
    GeneralCallback<MidtermAlertsData>? callback,
  }) async {
    try {
      var data = await WebApHelper.instance.midtermAlerts(
        semester.year,
        semester.value,
      );
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported)
        await FirebaseCrashlytics.instance.recordError(e, s);
    }
    return null;
  }

  //1=建工 /2=燕巢/3=第一/4=楠梓/5=旗津
  Future<RoomData?> getRoomList({
    required int campusCode,
    GeneralCallback<RoomData>? callback,
  }) async {
    try {
      var data = await WebApHelper.instance.roomList('$campusCode');
      reLoginCount = 0;
      return callback == null ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported)
        await FirebaseCrashlytics.instance.recordError(e, s);
    }
    return null;
  }

  Future<CourseData?> getRoomCourseTables({
    required String? roomId,
    required Semester semester,
    GeneralCallback<CourseData>? callback,
  }) async {
    try {
      var data = await WebApHelper.instance.roomCourseTableQuery(
        roomId,
        semester.year,
        semester.value,
      );
      reLoginCount = 0;
      return callback == null ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported)
        await FirebaseCrashlytics.instance.recordError(e, s);
    }
    return null;
  }

  Future<BusData?> getBusTimeTables({
    required DateTime dateTime,
    GeneralCallback<BusData>? callback,
  }) async {
    try {
      if (!MobileNkustHelper.isSupport)
        return callback?.onError(GeneralResponse.platformNotSupport());
      BusData data = await MobileNkustHelper.instance!.busTimeTableQuery(
        fromDateTime: dateTime,
      );
      reLoginCount = 0;
      if (data.canReserve!) {
        return (callback == null) ? data : callback.onSuccess(data);
      } else {
        callback!.onError(
          GeneralResponse(
            statusCode: 403,
            message: data.description!,
          ),
        );
        return null;
      }
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        BusHelper.reLoginReTryCounts = 0;
        if (dioError.isServerError)
          callback?.onError(dioError.serverErrorResponse);
        else
          callback?.onFailure(dioError);
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported)
        await FirebaseCrashlytics.instance.recordError(e, s);
    }
    return null;
  }

  Future<BusReservationsData?> getBusReservations({
    GeneralCallback<BusReservationsData>? callback,
  }) async {
    try {
      if (!MobileNkustHelper.isSupport)
        return callback?.onError(GeneralResponse.platformNotSupport());
      BusReservationsData data =
          await MobileNkustHelper.instance!.busUserRecord();
      reLoginCount = 0;
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        BusHelper.reLoginReTryCounts = 0;

        if (dioError.isServerError)
          callback?.onError(dioError.serverErrorResponse);
        else
          callback?.onFailure(dioError);
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported)
        await FirebaseCrashlytics.instance.recordError(e, s);
    }
    return null;
  }

  Future<BookingBusData?> bookingBusReservation({
    String? busId,
    GeneralCallback<BookingBusData>? callback,
  }) async {
    try {
      if (!MobileNkustHelper.isSupport)
        return callback?.onError(GeneralResponse.platformNotSupport());
      BookingBusData data =
          await MobileNkustHelper.instance!.busBook(busId: busId);
      reLoginCount = 0;
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        BusHelper.reLoginReTryCounts = 0;

        if (dioError.isServerError)
          callback?.onError(dioError.serverErrorResponse);
        else
          callback?.onFailure(dioError);
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported)
        await FirebaseCrashlytics.instance.recordError(e, s);
    }
    return null;
  }

  Future<CancelBusData?> cancelBusReservation({
    String? cancelKey,
    GeneralCallback<CancelBusData>? callback,
  }) async {
    try {
      if (!MobileNkustHelper.isSupport)
        return callback?.onError(GeneralResponse.platformNotSupport());
      CancelBusData data =
          await MobileNkustHelper.instance!.busUnBook(busId: cancelKey);
      reLoginCount = 0;
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        BusHelper.reLoginReTryCounts = 0;

        if (dioError.isServerError)
          callback?.onError(dioError.serverErrorResponse);
        else
          callback?.onFailure(dioError);
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported)
        await FirebaseCrashlytics.instance.recordError(e, s);
    }
    return null;
  }

  Future<BusViolationRecordsData?> getBusViolationRecords({
    GeneralCallback<BusViolationRecordsData>? callback,
  }) async {
    try {
      if (!MobileNkustHelper.isSupport)
        return callback?.onError(GeneralResponse.platformNotSupport());
      BusViolationRecordsData data =
          await MobileNkustHelper.instance!.busViolationRecords();

      reLoginCount = 0;
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        BusHelper.reLoginReTryCounts = 0;

        if (dioError.isServerError)
          callback?.onError(dioError.serverErrorResponse);
        else
          callback?.onFailure(dioError);
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported)
        await FirebaseCrashlytics.instance.recordError(e, s);
    }
    return null;
  }

  Future<NotificationsData?> getNotifications({
    required int page,
    GeneralCallback<NotificationsData>? callback,
  }) async {
    try {
      NotificationsData data =
          await NKUSTHelper.instance.getNotifications(page);
      return callback == null ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isServerError)
          callback?.onError(dioError.serverErrorResponse);
        else
          callback?.onFailure(dioError);
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported)
        await FirebaseCrashlytics.instance.recordError(e, s);
    }
    return null;
  }

  Future<LeaveData?> getLeaves({
    required Semester semester,
    GeneralCallback<LeaveData>? callback,
  }) async {
    try {
      LeaveData data = await LeaveHelper.instance!
          .getLeaves(year: semester.year, semester: semester.value);

      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isServerError)
          callback?.onError(dioError.serverErrorResponse);
        else
          callback?.onFailure(dioError);
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported)
        await FirebaseCrashlytics.instance.recordError(e, s);
    }
    return null;
  }

  Future<LeaveSubmitInfoData?> getLeavesSubmitInfo({
    GeneralCallback<LeaveSubmitInfoData>? callback,
  }) async {
    try {
      LeaveSubmitInfoData data =
          await LeaveHelper.instance!.getLeavesSubmitInfo();
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isServerError)
          callback?.onError(dioError.serverErrorResponse);
        else
          callback?.onFailure(dioError);
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported)
        await FirebaseCrashlytics.instance.recordError(e, s);
    }
    return null;
  }

  Future<Response?> sendLeavesSubmit({
    required LeaveSubmitData data,
    required PickedFile? image,
    GeneralCallback<Response?>? callback,
  }) async {
    try {
      Response? res =
          await LeaveHelper.instance!.leavesSubmit(data, proofImage: image);
      return (callback == null)
          ? data as Future<Response<dynamic>?>
          : callback.onSuccess(res);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isServerError)
          callback?.onError(dioError.serverErrorResponse);
        else
          callback?.onFailure(dioError);
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e, s) {
      callback?.onError(GeneralResponse.unknownError());
      if (FirebaseCrashlyticsUtils.isSupported)
        await FirebaseCrashlytics.instance.recordError(e, s);
    }
    return null;
  }

  Future<LibraryInfo?> getLibraryInfo() async {
    try {
      var response = await dio.get(
        '/leaves/submit/info',
        cancelToken: cancelToken,
      );
      if (response.statusCode == 204)
        return null;
      else
        return LibraryInfoData.fromJson(response.data).data;
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  @deprecated
  Future<EventInfoResponse?> getEventInfo({
    required String data,
    required GeneralCallback<EventInfoResponse> callback,
  }) async {
    try {
      var response = await dio.post(
        '/event/info',
        data: {
          'data': data,
        },
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200)
        return callback.onSuccess(EventInfoResponse.fromJson(response.data));
      else
        callback.onError(GeneralResponse.fromJson(response.data));
    } on DioError catch (dioError) {
      callback.onFailure(dioError);
    }
    return null;
  }

  @deprecated
  Future<EventSendResponse?> sendEvent({
    required String data,
    required String busId,
    required EventSendCallback<EventSendResponse> callback,
  }) async {
    try {
      var response = await dio.post(
        '/event/send',
        data: {
          'data': data,
          'bus_id': busId,
        },
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200) {
        var generalResponse = GeneralResponse.fromJson(response.data);
        if (generalResponse.statusCode == 401)
          callback.onNeedPick(EventInfoResponse.fromJson(response.data));
        return callback.onSuccess(EventSendResponse.fromJson(response.data));
      } else
        callback.onError(GeneralResponse.fromJson(response.data));
    } on DioError catch (dioError) {
      callback.onFailure(dioError);
    }
    return null;
  }

  // v3 api Authorization
  _createBearerTokenAuth(String? token) {
    return {
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
    BusHelper.instance!.isLogin = false;
    MobileNkustHelper.instance!.cookiesData?.clear();
  }
}

extension NewsExtension on Announcement {
  Map<String, dynamic> toUpdateJson() => {
        "title": title,
        "weight": weight,
        "imgUrl": imgUrl,
        "url": url,
        "description": description,
        "expireTime": expireTime,
      };
}

extension DioErrorExtension on DioError {
  bool get hasResponse => type == DioErrorType.response;

  bool get isExpire => response!.statusCode == ApStatusCode.API_EXPIRE;

  bool get isServerError =>
      response!.statusCode == ApStatusCode.SCHOOL_SERVER_ERROR ||
      response!.statusCode == ApStatusCode.API_SERVER_ERROR;

  GeneralResponse get serverErrorResponse {
    switch (response!.statusCode) {
      case ApStatusCode.API_SERVER_ERROR:
        return GeneralResponse(
          statusCode: ApStatusCode.API_SERVER_ERROR,
          message: 'api server error',
        );
      case ApStatusCode.SCHOOL_SERVER_ERROR:
      default:
        return GeneralResponse(
          statusCode: ApStatusCode.SCHOOL_SERVER_ERROR,
          message: 'shool server error',
        );
    }
  }
}

extension GeneralResponseExtension on GeneralResponse {
  String getGeneralMessage(
    BuildContext context,
  ) {
    final ap = ApLocalizations.current;
    String message = '';
    switch (statusCode) {
      case ApStatusCode.SCHOOL_SERVER_ERROR:
        message = ap.schoolServerError;
        break;
      case ApStatusCode.API_SERVER_ERROR:
        message = ap.schoolServerError;
        break;
      case ApStatusCode.API_EXPIRE:
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
