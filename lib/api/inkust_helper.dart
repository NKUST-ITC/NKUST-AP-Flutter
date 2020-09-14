//dio
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:cookie_jar/cookie_jar.dart';

//overwrite origin Cookie Manager.
import 'package:nkust_ap/api/private_cookie_manager.dart';
import "dart:math";
import 'helper.dart';

class InkustHelper {
  static Dio dio;
  static DioCacheManager _manager;
  static InkustHelper _instance;
  static CookieJar cookieJar;

  static int reLoginReTryCountsLimit = 3;
  static int reLoginReTryCounts = 0;
  static String loginApiKey = "";
  static String host = "inkusts.nkust.edu.tw";

  static Map<String, String> ueserRequestData = {
    "apiKey": null,
    "userId": null,
  };

  bool isLogin = false;

  static InkustHelper get instance {
    if (_instance == null) {
      _instance = InkustHelper();
      dioInit();
    }
    return _instance;
  }

  void setProxy(String proxyIP) {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.findProxy = (uri) {
        return "PROXY " + proxyIP;
      };
    };
  }

  static dioInit() {
    dio = Dio();
    cookieJar = CookieJar();
    if (Helper.isSupportCacheData) {
      _manager = DioCacheManager(CacheConfig(baseUrl: "https://${host}"));
      dio.interceptors.add(_manager.interceptor);
    }

    dio.interceptors.add(PrivateCookieManager(cookieJar));

    var headerRandom = ['13_6', '12_4', '14_0', '13_1', '13_5'];
    final _random = new Random();

    dio.options.headers['user-agent'] =
        'Mozilla/5.0 (iPhone; CPU iPhone OS ${headerRandom[_random.nextInt(headerRandom.length)]} like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148';
  }

  Future<Map<String, dynamic>> inkustLogin() async {
    if (Helper.username == null || Helper.password == null) {
      throw NullThrownError;
    }
    Response res = await dio.post("https://${host}/User/DoLogin2",
        data: {
          "apiKey": loginApiKey,
          "userId": Helper.username,
          "userPw": Helper.password,
          "userKeep": 0
        },
        options: Options(contentType: Headers.formUrlEncodedContentType));

    if (res.statusCode == 200 && res.data["success"] == true) {
      isLogin = true;
      ueserRequestData['apiKey'] = res.data['data']["userKey"];
      ueserRequestData['userId'] = res.data['data']["userIdEncrypt"];
    }
    return res.data;
  }
}
