import 'dart:async';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:nkust_ap/models/api/api_models.dart';
import 'package:nkust_ap/models/api/error_response.dart';
import 'package:nkust_ap/utils/utils.dart';

const HOST = "kuas.grd.idv.tw";
const PORT = '14769';

const VERSION = 'latest';

class Helper {
  static Helper _instance;
  static Options options;
  static Dio dio;

  static Helper get instance {
    if (_instance == null) {
      _instance = new Helper();
    }
    return _instance;
  }

  Helper() {
    options = new Options(
      baseUrl: 'https://$HOST:$PORT',
      connectTimeout: 20000,
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
    dio.options.headers = _createBasicAuth(username, password);
    try {
      var response = await dio.get("/$VERSION/token");
      if (response == null) print("null");
      return LoginResponse.fromJson(response.data);
    } on DioError catch (dioError) {
      throw dioError;
    }
  }

  Future<Response> getAllNews() async {
    try {
      var response = await dio.get("/$VERSION/news/all");
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
      } else {
        print(e.message);
      }
      throw e;
    }
  }

  Future<Response> getUsersInfo() async {
    try {
      var response = await dio.get("/$VERSION/ap/users/info");
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
      } else {
        print(e.message);
      }
      return null;
    }
  }

  Future<Response> getUsersPicture() async {
    try {
      var response = await dio.get("/$VERSION/ap/users/picture");
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
      } else {
        print(e.message);
      }
      return null;
    }
  }

  Future<Response> getSemester() async {
    try {
      var response = await dio.get("/$VERSION/ap/semester");
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
      } else {
        print(e.message);
      }
      return null;
    }
  }

  Future<Response> getScore(String year, String semester) async {
    try {
      var response =
          await dio.get("/$VERSION/ap/users/scores/" + year + "/" + semester);
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
      } else {
        print(e.message);
      }
      return null;
    }
  }

  Future<Response> getCourseTables(String year, String semester) async {
    try {
      var response = await dio
          .get("/$VERSION/ap/users/coursetables/" + year + "/" + semester);
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
      } else {
        print(e.message);
      }
      return null;
    }
  }

  Future<Response> getBusTimeTables(DateTime dateTime) async {
    var formatter = new DateFormat('yyyy-MM-dd');
    var date = formatter.format(dateTime);
    try {
      var response = await dio.get("/$VERSION/bus/timetables?date=$date");
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
      } else {
        print(e.message);
      }
      return null;
    }
  }

  Future<Response> getBusReservations() async {
    try {
      var response = await dio.get("/$VERSION/bus/reservations");
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
      } else {
        print(e.message);
      }
      return null;
    }
  }

  Future<Response> bookingBusReservation(String busId) async {
    try {
      var response = await dio.put("/$VERSION/bus/reservations/$busId");
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
      } else {
        print(e.message);
      }
      return null;
    }
  }

  Future<Response> cancelBusReservation(String cancelKey) async {
    try {
      var response = await dio.delete("/$VERSION/bus/reservations/$cancelKey");
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
      } else {
        print(e.message);
      }
      return null;
    }
  }

  Future<Response> getNotifications(int page) async {
    try {
      var response = await dio.get("/$VERSION/notifications/$page");
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
      } else {
        print(e.message);
      }
      return null;
    }
  }

  _createBasicAuth(String username, String password) {
    var text = username + ":" + password;
    var encoded = utf8.encode(text);
    return {
      "Authorization": "Basic " + base64.encode(encoded.toList(growable: false))
    };
  }
}
