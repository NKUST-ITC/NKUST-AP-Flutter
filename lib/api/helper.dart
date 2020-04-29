import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/announcements_data.dart';
import 'package:nkust_ap/models/booking_bus_data.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/models/cancel_bus_data.dart';
import 'package:nkust_ap/models/error_response.dart';
import 'package:nkust_ap/models/event_callback.dart';
import 'package:nkust_ap/models/event_info_response.dart';
import 'package:nkust_ap/models/general_response.dart';
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
import 'package:nkust_ap/utils/preferences.dart';
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

  Future<LoginResponse> login(String username, String password) async {
    try {
      var response = await dio.post(
        '/oauth/token',
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
    } on DioError catch (dioError) {
      throw dioError;
    }
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

  Future<AnnouncementsData> getAllAnnouncements() async {
    try {
      var response = await dio.get("/news/announcements/all");
      if (response.statusCode == 204)
        return AnnouncementsData(data: []);
      else {
        var announcementsData = AnnouncementsData.fromJson(response.data);
        announcementsData.data.sort((a, b) {
          return b.weight.compareTo(a.weight);
        });
        return announcementsData;
      }
    } on DioError catch (dioError) {
      print(dioError);
      throw dioError;
    }
  }

  Future<Response> addAnnouncement(Announcements announcements) async {
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

  Future<Response> updateAnnouncement(Announcements announcements) async {
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

  Future<Response> deleteAnnouncement(Announcements announcements) async {
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

  Future<UserInfo> getUsersInfo() async {
    if (isExpire()) await login(username, password);
    try {
      var response = await dio.get('/user/info');
      return UserInfo.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<SemesterData> getSemester() async {
    if (isExpire()) await login(username, password);
    try {
      var response = await dio.get("/user/semesters");
      return SemesterData.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<ScoreData> getScores(String year, String semester) async {
    if (isExpire()) await login(username, password);
    try {
      var response = await dio.get(
        "/user/scores",
        queryParameters: {
          'year': year,
          'semester': semester,
        },
        cancelToken: cancelToken,
      );
      if (response.statusCode == 204)
        return null;
      else
        return ScoreData.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<CourseData> getCourseTables(String year, String semester) async {
    if (isExpire()) await login(username, password);
    try {
      var response = await dio.get(
        '/user/coursetable',
        queryParameters: {
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

  Future<RewardAndPenaltyData> getRewardAndPenalty(
      String year, String semester) async {
    if (isExpire()) await login(username, password);
    try {
      var response = await dio.get(
        "/user/reward-and-penalty",
        queryParameters: {
          'year': year,
          'semester': semester,
        },
        cancelToken: cancelToken,
      );
      if (response.statusCode == 204)
        return null;
      else
        return RewardAndPenaltyData.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<MidtermAlertsData> getMidtermAlerts(
      String year, String semester) async {
    if (isExpire()) await login(username, password);
    try {
      var response = await dio.get(
        "/user/midterm-alerts",
        queryParameters: {
          'year': year,
          'semester': semester,
        },
        cancelToken: cancelToken,
      );
      if (response.statusCode == 204)
        return null;
      else
        return MidtermAlertsData.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
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

  Future<BusData> getBusTimeTables(DateTime dateTime) async {
    if (isExpire()) await login(username, password);
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
      if (response.statusCode == 204)
        return null;
      else
        return BusData.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<BusReservationsData> getBusReservations() async {
    if (isExpire()) await login(username, password);
    try {
      var response = await dio.get("/bus/reservations");
      if (response.statusCode == 204)
        return null;
      else
        return BusReservationsData.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<BookingBusData> bookingBusReservation(String busId) async {
    if (isExpire()) await login(username, password);
    try {
      var response = await dio.put(
        "/bus/reservations",
        queryParameters: {
          'busId': busId,
        },
      );
      return BookingBusData.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<CancelBusData> cancelBusReservation(String cancelKey) async {
    if (isExpire()) await login(username, password);
    try {
      var response = await dio.delete(
        "/bus/reservations",
        queryParameters: {
          'cancelKey': cancelKey,
        },
      );
      return CancelBusData.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<BusViolationRecordsData> getBusViolationRecords() async {
    if (isExpire()) await login(username, password);
    try {
      var response = await dio.get('/bus/violation-records');
      print(response.statusCode);
      print(response.data);
      if (response.statusCode == 204)
        return null;
      else
        return BusViolationRecordsData.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<NotificationsData> getNotifications(int page) async {
    try {
      var response = await dio.get(
        "/news/school",
        queryParameters: {'page': page},
      );
      return NotificationsData.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<LeaveData> getLeaves(String year, String semester) async {
    if (isExpire()) await login(username, password);
    try {
      var response = await dio.get(
        '/leave/all',
        queryParameters: {
          'year': year,
          'semester': semester,
        },
        cancelToken: cancelToken,
      );
      return LeaveData.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<LeaveSubmitInfoData> getLeavesSubmitInfo() async {
    if (isExpire()) await login(username, password);
    try {
      var response = await dio.get(
        '/leave/submit/info',
        cancelToken: cancelToken,
      );
      return LeaveSubmitInfoData.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<Response> sendLeavesSubmit(LeaveSubmitData data, File image) async {
    if (isExpire()) await login(username, password);
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
      return response;
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<LibraryInfo> getLibraryInfo() async {
    if (isExpire()) await login(username, password);
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
    @required EventInfoCallback callback,
  }) async {
    if (isExpire()) await login(username, password);
    try {
      var response = await dio.post(
        '/event/info',
        data: FormData.fromMap(
          {
            'data': data,
          },
        ),
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200)
        return callback.onSuccess(EventInfoResponse.fromRawJson(response.data));
      else
        callback.onError(GeneralResponse.fromRawJson(response.data));
    } on DioError catch (e) {
      if (e.type == DioErrorType.RESPONSE) {
        callback.onError(GeneralResponse.fromRawJson(e.response.data));
      } else
        callback.onFailure(e);
    }
    return null;
  }

  Future<EventInfoResponse> sendEvent({
    @required String data,
    @required String busId,
    @required EventSendCallback callback,
  }) async {
    if (isExpire()) await login(username, password);
    try {
      var response = await dio.post(
        '/event/send',
        data: FormData.fromMap(
          {
            'data': data,
            'bus_id': busId,
          },
        ),
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200)
        return callback.onSuccess(EventSendResponse.fromRawJson(response.data));
      else
        callback.onError(EventInfoResponse.fromRawJson(response.data));
    } on DioError catch (e) {
      if (e.type == DioErrorType.RESPONSE) {
        callback.onError(EventInfoResponse.fromRawJson(e.response.data));
      } else
        callback.onFailure(e);
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
