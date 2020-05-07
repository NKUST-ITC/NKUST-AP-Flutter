import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ap_common/callback/general_callback.dart';
import 'package:ap_common/models/announcement_data.dart';
import 'package:ap_common/models/course_data.dart';
import 'package:ap_common/models/score_data.dart';
import 'package:ap_common/models/user_info.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/booking_bus_data.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/models/cancel_bus_data.dart';
import 'package:nkust_ap/models/event_callback.dart';
import 'package:nkust_ap/models/event_info_response.dart';
import 'package:nkust_ap/models/leave_submit_info_data.dart';
import 'package:nkust_ap/models/leave_data.dart';
import 'package:nkust_ap/models/leave_submit_data.dart';
import 'package:nkust_ap/models/library_info_data.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/models/reward_and_penalty_data.dart';
import 'package:nkust_ap/models/room_data.dart';
import 'package:nkust_ap/models/server_info_data.dart';
import 'package:nkust_ap/utils/utils.dart';

class Helper {
  static const HOST = 'nkust.v3.backup.taki.dog';

  static const VERSION = 'v3';

  static Helper _instance;
  static BaseOptions options;
  static Dio dio;
  static JsonCodec jsonCodec;
  static CancelToken cancelToken;

  static String username;
  static String password;
  static DateTime expireTime;

  //LOGIN API
  static const USER_DATA_ERROR = 1401;

  //Common
  static const API_EXPIRE = 401;
  static const API_SERVER_ERROR = 500;
  static const SCHOOL_SERVER_ERROR = 503;

  int reLoginCount = 0;

  bool get canReLogin => reLoginCount == 0;

  bool isExpire() {
    if (expireTime == null)
      return false;
    else
      return DateTime.now().isAfter(expireTime.add(Duration(hours: 8)));
  }

  static Helper get instance {
    if (_instance == null) {
      _instance = Helper();
      jsonCodec = JsonCodec();
      cancelToken = CancelToken();
    }
    return _instance;
  }

  Helper() {
    var host = Preferences.getString(Constants.API_HOST, HOST);
    options = BaseOptions(
      baseUrl: 'https://$host/$VERSION',
      connectTimeout: 10000,
      receiveTimeout: 10000,
    );
    dio = Dio(options);
  }

  static resetInstance() {
    _instance = Helper();
    jsonCodec = JsonCodec();
    cancelToken = CancelToken();
  }

  static void handleGeneralError(
    BuildContext context,
    GeneralResponse generalResponse,
  ) {
    final ap = ApLocalizations.of(context);
    String message = '';
    switch (generalResponse.statusCode) {
      case SCHOOL_SERVER_ERROR:
        message = ap.schoolSeverError;
        break;
      case API_SERVER_ERROR:
        message = ap.apiSeverError;
        break;
      case API_EXPIRE:
        message = ap.tokenExpiredContent;
        break;
      default:
        message = ap.somethingError;
        break;
    }
    ApUtils.showToast(context, message);
  }

  handleDioError(DioError dioError) {
    switch (dioError.type) {
      case DioErrorType.DEFAULT:
        return LoginResponse.fromJson(dioError.response.data);
        break;
      case DioErrorType.CANCEL:
        throw (dioError);
        break;
      case DioErrorType.CONNECT_TIMEOUT:
        throw (dioError);
      case DioErrorType.SEND_TIMEOUT:
        throw (dioError);
        break;
      case DioErrorType.RESPONSE:
        throw (dioError);
        break;
      case DioErrorType.RECEIVE_TIMEOUT:
        throw (dioError);
        break;
    }
  }

  Future<bool> reLogin(GeneralCallback callback) async {
    var loginResponse = await login(
      username: username,
      password: password,
      callback: GeneralCallback<LoginResponse>(
        onSuccess: (loginResponse) => loginResponse,
        onFailure: callback?.onFailure,
        onError: callback?.onError,
      ),
    );
    return loginResponse != null;
  }

  Future<LoginResponse> login({
    @required String username,
    @required String password,
    GeneralCallback<LoginResponse> callback,
  }) async {
    try {
      var response = await dio.post(
        '/oauth/token',
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
      if (callback != null)
        return callback.onSuccess(loginResponse);
      else
        return loginResponse;
    } on DioError catch (e) {
      if (e.type == DioErrorType.RESPONSE && e.response.statusCode == 401) {
        callback?.onError(
          GeneralResponse(
            statusCode: USER_DATA_ERROR,
            message: 'username or password error',
          ),
        );
      } else
        callback?.onFailure(e);
    } catch (e) {
      callback?.onError(
        GeneralResponse.unknownError(),
      );
      throw e;
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
      if (response == null) print('null');
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

  Future<List<Announcement>> getAllAnnouncements({
    GeneralCallback<List<Announcement>> callback,
  }) async {
    try {
      var response = await dio.get("/news/announcements/all");
      var data = AnnouncementData(data: []);
      if (response.statusCode != 204) {
        data = AnnouncementData.fromJson(response.data);
        data.data.sort((a, b) {
          return b.weight.compareTo(a.weight);
        });
      }
      return (callback == null) ? data : callback.onSuccess(data.data);
    } on DioError catch (dioError) {
      if (callback == null)
        throw dioError;
      else
        callback.onFailure(dioError);
    } catch (e) {
      callback?.onError(GeneralResponse.unknownError());
      throw e;
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

  Future<UserInfo> getUsersInfo({
    GeneralCallback<UserInfo> callback,
  }) async {
    if (isExpire()) await login(username: username, password: password);
    try {
      var response = await dio.get('/user/info');
      reLoginCount = 0;
      var data = UserInfo.fromJson(response.data);
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isExpire && canReLogin && await reLogin(callback)) {
          reLoginCount++;
          return getUsersInfo(callback: callback);
        } else {
          if (dioError.isServerError)
            callback?.onError(dioError.serverErrorResponse);
          else
            callback?.onFailure(dioError);
        }
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e) {
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
    return null;
  }

  Future<SemesterData> getSemester({
    GeneralCallback<SemesterData> callback,
  }) async {
    if (isExpire()) await login(username: username, password: password);
    try {
      var response = await dio.get("/user/semesters");
      var data = SemesterData.fromJson(response.data);
      reLoginCount = 0;
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isExpire && canReLogin && await reLogin(callback)) {
          reLoginCount++;
          return getSemester(callback: callback);
        } else {
          if (dioError.isServerError)
            callback?.onError(dioError.serverErrorResponse);
          else
            callback?.onFailure(dioError);
        }
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e) {
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
    return null;
  }

  Future<ScoreData> getScores({
    @required Semester semester,
    GeneralCallback<ScoreData> callback,
  }) async {
    if (isExpire()) await login(username: username, password: password);
    try {
      var response = await dio.get(
        "/user/scores",
        queryParameters: {
          'year': semester.year,
          'semester': semester.value,
        },
        cancelToken: cancelToken,
      );
      ScoreData data;
      if (response.statusCode != 204) {
        data = ScoreData.fromJson(response.data);
      }
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isExpire && canReLogin && await reLogin(callback)) {
          reLoginCount++;
          return getScores(semester: semester, callback: callback);
        } else {
          if (dioError.isServerError)
            callback?.onError(dioError.serverErrorResponse);
          else
            callback?.onFailure(dioError);
        }
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e) {
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
    return null;
  }

  Future<CourseData> getCourseTables({
    @required Semester semester,
    GeneralCallback callback,
  }) async {
    if (isExpire()) await login(username: username, password: password);
    try {
      var response = await dio.get(
        '/user/coursetable',
        queryParameters: {
          'year': semester.year,
          'semester': semester.value,
        },
        cancelToken: cancelToken,
      );
      CourseData data;
      if (response.statusCode != 204) {
        data = CourseData.fromJson(response.data);
        for (var i = 0; i < data.courses.length; i++) {
          final courseDetail = data.courses[i];
          for (var weekIndex = 0;
              weekIndex < data.courseTables.weeks.length;
              weekIndex++) {
            for (var course in data.courseTables.weeks[weekIndex]) {
              if (course.title == courseDetail.title) {
                course.detailIndex = i;
              }
            }
          }
        }
        reLoginCount = 0;
        return (callback == null) ? data : callback.onSuccess(data);
      }
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isExpire && canReLogin && await reLogin(callback)) {
          reLoginCount++;
          return getCourseTables(semester: semester, callback: callback);
        } else {
          if (dioError.isServerError)
            callback?.onError(dioError.serverErrorResponse);
          else
            callback?.onFailure(dioError);
        }
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e) {
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
    return null;
  }

  Future<RewardAndPenaltyData> getRewardAndPenalty({
    @required Semester semester,
    GeneralCallback<RewardAndPenaltyData> callback,
  }) async {
    if (isExpire()) await login(username: username, password: password);
    try {
      var response = await dio.get(
        "/user/reward-and-penalty",
        queryParameters: {
          'year': semester.year,
          'semester': semester.value,
        },
        cancelToken: cancelToken,
      );
      RewardAndPenaltyData data;
      if (response.statusCode == 200)
        data = RewardAndPenaltyData.fromJson(response.data);
      reLoginCount = 0;
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isExpire && canReLogin && await reLogin(callback)) {
          reLoginCount++;
          return getRewardAndPenalty(semester: semester, callback: callback);
        } else {
          if (dioError.isServerError)
            callback?.onError(dioError.serverErrorResponse);
          else
            callback?.onFailure(dioError);
        }
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e) {
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
    return null;
  }

  Future<MidtermAlertsData> getMidtermAlerts({
    @required Semester semester,
    GeneralCallback<MidtermAlertsData> callback,
  }) async {
    if (isExpire()) await login(username: username, password: password);
    try {
      var response = await dio.get(
        "/user/midterm-alerts",
        queryParameters: {
          'year': semester.year,
          'semester': semester.value,
        },
        cancelToken: cancelToken,
      );
      MidtermAlertsData data;
      if (response.statusCode == 200)
        data = MidtermAlertsData.fromJson(response.data);
      reLoginCount = 0;
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isExpire && canReLogin && await reLogin(callback)) {
          reLoginCount++;
          return getMidtermAlerts(semester: semester, callback: callback);
        } else {
          if (dioError.isServerError)
            callback?.onError(dioError.serverErrorResponse);
          else
            callback?.onFailure(dioError);
        }
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e) {
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
    return null;
  }

  //1=建工 /2=燕巢/3=第一/4=楠梓/5=旗津
  Future<RoomData> getRoomList(int campus) async {
    try {
      var response = await dio.get(
        '/user/room/list',
        queryParameters: {
          'campus': campus,
        },
        cancelToken: cancelToken,
      );
      if (response.statusCode == 204)
        return null;
      else
        return RoomData.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<CourseData> getRoomCourseTables(
      String roomId, String year, String semester) async {
    try {
      var response = await dio.get(
        '/user/empty-room/info',
        queryParameters: {
          'roomId': roomId,
          'year': year,
          'semester': semester,
        },
        cancelToken: cancelToken,
      );
      if (response.statusCode == 204)
        return null;
      else
        return CourseData.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<BusData> getBusTimeTables({
    @required DateTime dateTime,
    GeneralCallback<BusData> callback,
  }) async {
    if (isExpire()) await login(username: username, password: password);
    var formatter = DateFormat('yyyy-MM-dd');
    var date = formatter.format(dateTime);
    try {
      var response = await dio.get(
        '/bus/timetables',
        queryParameters: {
          'date': date,
        },
        cancelToken: cancelToken,
      );
      BusData data;
      if (response.statusCode == 200) data = BusData.fromJson(response.data);
      reLoginCount = 0;
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isExpire && canReLogin && await reLogin(callback)) {
          reLoginCount++;
          return getBusTimeTables(dateTime: dateTime, callback: callback);
        } else {
          if (dioError.isServerError)
            callback?.onError(dioError.serverErrorResponse);
          else
            callback?.onFailure(dioError);
        }
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e) {
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
    return null;
  }

  Future<BusReservationsData> getBusReservations({
    GeneralCallback<BusReservationsData> callback,
  }) async {
    if (isExpire()) await login(username: username, password: password);
    try {
      var response = await dio.get("/bus/reservations");
      BusReservationsData data;
      if (response.statusCode == 200)
        data = BusReservationsData.fromJson(response.data);
      reLoginCount = 0;
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isExpire && canReLogin && await reLogin(callback)) {
          reLoginCount++;
          return getBusReservations(callback: callback);
        } else {
          if (dioError.isServerError)
            callback?.onError(dioError.serverErrorResponse);
          else
            callback?.onFailure(dioError);
        }
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e) {
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
    return null;
  }

  Future<BookingBusData> bookingBusReservation({
    String busId,
    GeneralCallback<BookingBusData> callback,
  }) async {
    if (isExpire()) await login(username: username, password: password);
    try {
      var response = await dio.put(
        "/bus/reservations",
        queryParameters: {
          'busId': busId,
        },
      );
      var data = BookingBusData.fromJson(response.data);
      reLoginCount = 0;
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isExpire && canReLogin && await reLogin(callback)) {
          reLoginCount++;
          return bookingBusReservation(busId: busId, callback: callback);
        } else {
          if (dioError.isServerError)
            callback?.onError(dioError.serverErrorResponse);
          else
            callback?.onFailure(dioError);
        }
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e) {
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
    return null;
  }

  Future<CancelBusData> cancelBusReservation({
    String cancelKey,
    GeneralCallback<CancelBusData> callback,
  }) async {
    if (isExpire()) await login(username: username, password: password);
    try {
      var response = await dio.delete(
        "/bus/reservations",
        queryParameters: {
          'cancelKey': cancelKey,
        },
      );
      var data = CancelBusData.fromJson(response.data);
      reLoginCount = 0;
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isExpire && canReLogin && await reLogin(callback)) {
          reLoginCount++;
          return cancelBusReservation(cancelKey: cancelKey, callback: callback);
        } else {
          if (dioError.isServerError)
            callback?.onError(dioError.serverErrorResponse);
          else
            callback?.onFailure(dioError);
        }
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e) {
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
    return null;
  }

  Future<BusViolationRecordsData> getBusViolationRecords({
    GeneralCallback<BusViolationRecordsData> callback,
  }) async {
    if (isExpire()) await login(username: username, password: password);
    try {
      var response = await dio.get('/bus/violation-records');
      print(response.statusCode);
      print(response.data);
      BusViolationRecordsData data;
      if (response.statusCode == 200)
        data = BusViolationRecordsData.fromJson(response.data);
      reLoginCount = 0;
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isExpire && canReLogin && await reLogin(callback)) {
          reLoginCount++;
          return getBusViolationRecords(callback: callback);
        } else {
          if (dioError.isServerError)
            callback?.onError(dioError.serverErrorResponse);
          else
            callback?.onFailure(dioError);
        }
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e) {
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
    return null;
  }

  Future<NotificationsData> getNotifications({
    @required int page,
    GeneralCallback<NotificationsData> callback,
  }) async {
    try {
      var response = await dio.get(
        "/news/school",
        queryParameters: {'page': page},
      );
      return NotificationsData.fromJson(response.data);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isServerError)
          callback?.onError(dioError.serverErrorResponse);
        else
          callback?.onFailure(dioError);
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e) {
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
    return null;
  }

  Future<LeaveData> getLeaves({
    @required Semester semester,
    GeneralCallback<LeaveData> callback,
  }) async {
    if (isExpire()) await login(username: username, password: password);
    try {
      var response = await dio.get(
        '/leave/all',
        queryParameters: {
          'year': semester.year,
          'semester': semester.value,
        },
        cancelToken: cancelToken,
      );
      LeaveData data;
      if (response.statusCode == 200) data = LeaveData.fromJson(response.data);
      reLoginCount = 0;
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isExpire && canReLogin && await reLogin(callback)) {
          reLoginCount++;
          return getLeaves(semester: semester, callback: callback);
        } else {
          if (dioError.isServerError)
            callback?.onError(dioError.serverErrorResponse);
          else
            callback?.onFailure(dioError);
        }
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e) {
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
    return null;
  }

  Future<LeaveSubmitInfoData> getLeavesSubmitInfo({
    GeneralCallback<LeaveSubmitInfoData> callback,
  }) async {
    if (isExpire()) await login(username: username, password: password);
    try {
      var response = await dio.get(
        '/leave/submit/info',
        cancelToken: cancelToken,
      );
      LeaveSubmitInfoData data;
      if (response.statusCode == 200)
        data = LeaveSubmitInfoData.fromJson(response.data);
      reLoginCount = 0;
      return (callback == null) ? data : callback.onSuccess(data);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isExpire && canReLogin && await reLogin(callback)) {
          reLoginCount++;
          return getLeavesSubmitInfo(callback: callback);
        } else {
          if (dioError.isServerError)
            callback?.onError(dioError.serverErrorResponse);
          else
            callback?.onFailure(dioError);
        }
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e) {
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
    return null;
  }

  Future<Response> sendLeavesSubmit({
    @required LeaveSubmitData data,
    @required File image,
    GeneralCallback<Response> callback,
  }) async {
    if (isExpire()) await login(username: username, password: password);
    try {
      MultipartFile file;
      if (image != null) {
        file = MultipartFile.fromFileSync(
          image.path,
          filename: image.path.split('/').last,
          contentType: MediaType(
              'image', Utils.parserImageFileType(image.path.split('.').last)),
        );
      }
      print(data.toRawJson());
      var response = await dio.post(
        '/leave/submit',
        data: FormData.fromMap(
          {
            'leavesData': data.toRawJson(),
            'proofImage': file,
          },
        ),
        cancelToken: cancelToken,
      );
      reLoginCount = 0;
      return (callback == null) ? data : callback.onSuccess(response);
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isExpire && canReLogin && await reLogin(callback)) {
          reLoginCount++;
          return sendLeavesSubmit(data: data, image: image, callback: callback);
        } else {
          if (dioError.isServerError)
            callback?.onError(dioError.serverErrorResponse);
          else
            callback?.onFailure(dioError);
        }
      } else
        callback?.onFailure(dioError);
      if (callback == null) throw dioError;
    } catch (e) {
      callback?.onError(GeneralResponse.unknownError());
      throw e;
    }
    return null;
  }

  Future<LibraryInfo> getLibraryInfo() async {
    if (isExpire()) await login(username: username, password: password);
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

  Future<EventInfoResponse> getEventInfo({
    @required String data,
    @required GeneralCallback<EventInfoResponse> callback,
  }) async {
    if (isExpire()) await login(username: username, password: password);
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
      if (dioError.hasResponse) {
        if (dioError.isExpire && canReLogin && await reLogin(callback)) {
          reLoginCount++;
          return getEventInfo(data: data, callback: callback);
        } else {
          if (dioError.isServerError)
            callback?.onError(dioError.serverErrorResponse);
          else
            callback.onError(GeneralResponse.fromJson(dioError.response.data));
        }
      } else
        callback?.onFailure(dioError);
    }
    return null;
  }

  Future<EventSendResponse> sendEvent({
    @required String data,
    @required String busId,
    @required EventSendCallback<EventSendResponse> callback,
  }) async {
    if (isExpire()) await login(username: username, password: password);
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
          callback?.onNeedPick(EventInfoResponse.fromJson(response.data));
        return callback.onSuccess(EventSendResponse.fromJson(response.data));
      } else
        callback.onError(GeneralResponse.fromJson(response.data));
    } on DioError catch (dioError) {
      if (dioError.hasResponse) {
        if (dioError.isExpire && canReLogin && await reLogin(callback)) {
          reLoginCount++;
          return sendEvent(data: data, busId: busId, callback: callback);
        } else {
          if (dioError.isServerError)
            callback?.onError(dioError.serverErrorResponse);
          else {
            var generalResponse =
                GeneralResponse.fromJson(dioError.response.data);
            callback.onError(generalResponse);
          }
        }
      } else
        callback?.onFailure(dioError);
    }
    return null;
  }

  @deprecated
  _createBasicAuth(String username, String password) {
    var text = username + ":" + password;
    var encoded = utf8.encode(text);
    return {
      "Connection": "Keep-Alive",
      "Authorization": "Basic " + base64.encode(encoded.toList(growable: false))
    };
  }

  // v3 api Authorization
  _createBearerTokenAuth(String token) {
    return {
      'Authorization': 'Bearer $token',
    };
  }

  static void clearSetting() {
    expireTime = null;
    username = null;
    password = null;
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
  bool get hasResponse => type == DioErrorType.RESPONSE;

  bool get isExpire => response.statusCode == Helper.API_EXPIRE;

  bool get isServerError =>
      response.statusCode == Helper.SCHOOL_SERVER_ERROR ||
      response.statusCode == Helper.API_SERVER_ERROR;

  GeneralResponse get serverErrorResponse {
    switch (response.statusCode) {
      case Helper.API_SERVER_ERROR:
        return GeneralResponse(
          statusCode: Helper.API_SERVER_ERROR,
          message: 'api server error',
        );
      case Helper.SCHOOL_SERVER_ERROR:
      default:
        return GeneralResponse(
          statusCode: Helper.SCHOOL_SERVER_ERROR,
          message: 'shool server error',
        );
    }
  }
}
