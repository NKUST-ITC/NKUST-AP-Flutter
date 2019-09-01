import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:intl/intl.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/announcements_data.dart';
import 'package:nkust_ap/models/booking_bus_data.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/models/cancel_bus_data.dart';
import 'package:nkust_ap/models/leave_info_data.dart';
import 'package:nkust_ap/models/leaves_data.dart';
import 'package:nkust_ap/models/leaves_submit_data.dart';
import 'package:nkust_ap/models/library_info_data.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/models/reward_and_penalty_data.dart';
import 'package:nkust_ap/models/room_data.dart';
import 'package:nkust_ap/models/server_info_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

const HOST = 'nkust.taki.dog';
const PORT = '443';

const VERSION = 'v3';

class Helper {
  static Helper _instance;
  static BaseOptions options;
  static Dio dio;
  static JsonCodec jsonCodec;
  static CancelToken cancelToken;

  static Helper get instance {
    if (_instance == null) {
      _instance = Helper();
      jsonCodec = JsonCodec();
      cancelToken = CancelToken();
    }
    return _instance;
  }

  Helper() {
    options = new BaseOptions(
      baseUrl: 'https://$HOST:$PORT',
      connectTimeout: 10000,
      receiveTimeout: 10000,
    );
    dio = new Dio(options);
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

  Future<Null> initByPreference() async {
    final encrypter =
        Encrypter(AES(Constants.key, Constants.iv, mode: AESMode.cbc));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString(Constants.PREF_USERNAME) ?? '';
    String encryptPassword = prefs.getString(Constants.PREF_PASSWORD) ?? '';
    String password = '';
    try {
      password = encrypter.decrypt64(encryptPassword);
    } catch (e) {
      password = encryptPassword;
      await prefs.setString(
          Constants.PREF_PASSWORD, encrypter.encrypt(encryptPassword).base64);
      throw e;
    }
    dio.options.headers = _createBasicAuth(username, password);
    return null;
  }

  Future<LoginResponse> login(String username, String password) async {
    dio.options.headers = _createBasicAuth(username, password);
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
      return loginResponse;
    } on DioError catch (dioError) {
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
      return AnnouncementsData.fromJson(response.data);
    } on DioError catch (dioError) {
      print(dioError);
      throw dioError;
    }
  }

  Future<UserInfo> getUsersInfo() async {
    try {
      var response = await dio.get('/user/info');
      return UserInfo.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<String> getUsersPicture() async {
    try {
      var response = await dio.get("/$VERSION/ap/users/picture");
      return response.data;
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<SemesterData> getSemester() async {
    try {
      var response = await dio.get("/user/semesters");
      return SemesterData.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<ScoreData> getScores(String year, String semester) async {
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
      var response = await dio.get("/news/school/$page");
      return NotificationsData.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<LeavesData> getLeaves(String year, String semester) async {
    try {
      var response = await dio.get(
        '/leaves',
        queryParameters: {
          'year': year,
          'semester': semester,
        },
        cancelToken: cancelToken,
      );
      return LeavesData.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<LeavesSubmitInfoData> getLeavesSubmitInfo() async {
    try {
      var response = await dio.get(
        '/leaves/submit/info',
        cancelToken: cancelToken,
      );
      return LeavesSubmitInfoData.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<Response> sendLeavesSubmit(LeavesSubmitData data) async {
    try {
      var response = await dio.post(
        '/leaves/submit',
        data: data.toJson(),
        cancelToken: cancelToken,
      );
      return response;
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<LibraryInfo> getLibraryInfo() async {
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

  _createBasicAuth(String username, String password) {
    var text = username + ":" + password;
    var encoded = utf8.encode(text);
    return {
      "Connection": "Keep-Alive",
      "Authorization": "Basic " + base64.encode(encoded.toList(growable: false))
    };
  }

  _createBearerTokenAuth(String token) {
    return {
      'Authorization': 'Bearer $token',
    };
  }
}
