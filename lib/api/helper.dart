import 'package:dio/dio.dart';
import 'dart:convert';

class Helper {
  static const PORT = '14769';

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
      baseUrl: 'https://kuas.grd.idv.tw:$PORT',
      connectTimeout: 5000,
      receiveTimeout: 5000,
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

  _createBasicAuth(String username, String password) {
    var text = username + ":" + password;
    var encoded = utf8.encode(text);
    return {
      "Authorization": "Basic " + base64.encode(encoded.toList(growable: false))
    };
  }
}
