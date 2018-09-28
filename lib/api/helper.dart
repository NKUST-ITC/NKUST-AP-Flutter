import 'dart:async';
import 'package:dio/dio.dart';
import 'dart:convert';

const HOST = "kuas.grd.idv.tw";
const PORT = '14769';

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

  login(String username, String password) async {
    dio.options.headers = _createBasicAuth(username, password);
    try {
      var response = await dio.get("/latest/token");
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request.headers);
        print(e.response.request.baseUrl);
      } else {
        print(e.message);
      }
      return null;
    }
  }

  Future<Response> getSemester() async {
    try {
      var response = await dio.get("/latest/ap/semester");
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
          .get("/latest/ap/users/coursetables/" + year + "/" + semester);
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
