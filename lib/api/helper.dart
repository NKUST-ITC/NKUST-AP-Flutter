import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:intl/intl.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/announcements_data.dart';
import 'package:nkust_ap/models/api/api_models.dart';
import 'package:nkust_ap/models/api/leave_response.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/models/reward_and_penalty_data.dart';
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

  Future<AnnouncementsData> getAllAnnouncements() async {
    try {
      var response = await dio.get("/$VERSION/news/all");
      var jsonArray = jsonCodec.decode(response.data);
      return AnnouncementsData.fromJson(jsonArray);
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
          'value': semester,
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
          'value': semester,
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
    var formatter = new DateFormat('yyyy-MM-dd');
    var date = formatter.format(dateTime);
    try {
      var response = await dio.get("/$VERSION/bus/timetables?date=$date",
          cancelToken: cancelToken);
      return BusData.fromJson(response.data);
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
          'value': semester,
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
          'value': semester,
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

  Future<BusReservationsData> getBusReservations() async {
    try {
      var response = await dio.get("/$VERSION/bus/reservations");
      return BusReservationsData.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<Response> bookingBusReservation(String busId) async {
    try {
      var response = await dio.put("/$VERSION/bus/reservations/$busId");
      return response;
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<Response> cancelBusReservation(String cancelKey) async {
    try {
      var response = await dio.delete("/$VERSION/bus/reservations/$cancelKey");
      return response;
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<LeaveResponse> getLeaves(String year, String semester) async {
    try {
      var response = await dio.get("/$VERSION/leaves/$year/$semester",
          cancelToken: cancelToken);
      return LeaveResponse.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<NotificationData> getNotifications(int page) async {
    try {
      var response = await dio.get("/$VERSION/notifications/$page");
      return NotificationData.fromJson(response.data);
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
