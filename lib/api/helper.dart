import 'package:dio/dio.dart';

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

  static void login() async {
    var data = await dio.get("");
  }
}
