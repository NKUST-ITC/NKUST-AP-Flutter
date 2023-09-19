import 'dart:convert';
import 'dart:io';

import 'package:ap_common/models/private_cookies_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/io.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/api/parser/api_tool.dart';
import 'package:nkust_ap/api/parser/bus_parser.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/booking_bus_data.dart';
import 'package:nkust_ap/models/bus_data.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/models/cancel_bus_data.dart';

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}

class BusEncrypt {
  //0 is from first, 1 is from last.
  static int? seedDirection;

  static String? seedValue;

  BusEncrypt({required String jsCode}) {
    jsEncryptCodeParser(jsCode);
  }

  void jsEncryptCodeParser(String content) {
    // http://bus.kuas.edu.tw/API/Scripts/a1
    final RegExp seedFromFirstRegex = RegExp(r"encA2\('((\d|\w){0,32})'");
    final RegExp seedFromLastRegex =
        RegExp(r"encA2\(e(\w|\d|\s|\W){0,3}'((\d|\w){0,32})'\)");

    final Iterable<RegExpMatch> firstMatches =
        seedFromFirstRegex.allMatches(content);
    final Iterable<RegExpMatch> lastMatches =
        seedFromLastRegex.allMatches(content);
    String? seedFromFirst;
    String? seedFromLast;

    if (firstMatches.isNotEmpty) {
      seedFromFirst = firstMatches.toList()[firstMatches.length - 1].group(1);
    }
    if (lastMatches.isNotEmpty) {
      seedFromLast = lastMatches.toList()[lastMatches.length - 1].group(2);
    }
    findEndString(content, seedFromFirst);
    if (findEndString(content, seedFromFirst) >
        findEndString(content, seedFromLast)) {
      seedDirection = 0;
      seedValue = seedFromFirst;
      return;
    }
    seedDirection = 1;
    seedValue = seedFromLast;
  }

  String encA1(String value) {
    if (seedDirection == null || seedValue == null) {
      throw Exception('Seed get error');
    }
    if (seedDirection == 0) {
      return generateMd5('$seedValue$value');
    }
    return generateMd5('$value$seedValue');
  }

  String loginEncrypt(String username, String password) {
    String g = '419191959';
    String i = '930672927';
    String j = '1088434686';
    String k = '260123741';

    g = generateMd5('J$g');
    i = generateMd5('E$i');
    j = generateMd5('R$j');
    k = generateMd5('Y$k');
    final String usernameMD5 = generateMd5(username + encA1(g));
    final String passwordMD5 =
        generateMd5('$username${password}JERRY${encA1(i)}');

    String l = generateMd5('$usernameMD5${passwordMD5}KUAS${encA1(j)}');
    l = generateMd5(l + usernameMD5 + encA1('ITALAB') + encA1(k));
    l = generateMd5('$l${password}MIS$k');

    return json.encode(
      <String, String>{
        'a': l,
        'b': g,
        'c': i,
        'd': j,
        'e': k,
        'f': passwordMD5
      },
    );
  }

  int findEndString(String content, String? targetString) {
    if (targetString == null) {
      return -1;
    }
    int index = -1;
    int res = 0;
    while (res != -1) {
      res = content.indexOf(targetString, res);
      if (res != -1) {
        index = res;
        res += 1;
      }
    }
    return index;
  }
}

class BusHelper {
  BusHelper() {
    dioInit();
  }

  late Dio dio;
  late DioCacheManager _manager;
  static BusHelper? _instance;
  late CookieJar cookieJar;

  static int reLoginReTryCountsLimit = 5;
  static int reLoginReTryCounts = 0;

  bool isLogin = false;

  static String? userTimeTableSelectCacheKey;
  static String userRecordsCacheKey = '${Helper.username}_busUserRecords';
  static String userViolationRecordsCacheKey =
      '${Helper.username}_busViolationRecords';
  static late BusEncrypt busEncryptObject;
  static String busHost = 'http://bus.kuas.edu.tw/';

  //ignore: prefer_constructors_over_static_methods
  static BusHelper get instance {
    return _instance ??= BusHelper();
  }

  void setProxy(String proxyIP) {
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final HttpClient client = HttpClient();
      client.findProxy = (Uri uri) {
        return 'PROXY $proxyIP';
      };
      return client;
    };
  }

  void dioInit() {
    // Use PrivateCookieManager to overwrite origin CookieManager, because
    // Cookie name of the NKUST ap system not follow the RFC6265. :(
    dio = Dio();
    if (Helper.isSupportCacheData) {
      _manager =
          DioCacheManager(CacheConfig(baseUrl: 'http://bus.kuas.edu.tw'));
      dio.interceptors.add(_manager.interceptor as Interceptor);
      _manager.clearAll();
    }

    cookieJar = CookieJar();
    dio.interceptors.add(PrivateCookieManager(cookieJar));
    dio.options.headers['user-agent'] =
        'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36';
    dio.options.headers['Connection'] = 'close';
    dio.options.connectTimeout = const Duration(
      milliseconds: Constants.timeoutMs,
    );
    dio.options.receiveTimeout = const Duration(
      milliseconds: Constants.timeoutMs,
    );
    if (Platform.isIOS || Platform.isMacOS || Platform.isAndroid) {
      dio.httpClientAdapter = NativeAdapter();
    }
  }

  Future<void> loginPrepare() async {
    // Get global cookie. Only cookies get from the root directory can be used.
    await dio.head(busHost);
    // This function will download encrypt js bus login required.
    final Response<String> res =
        await dio.get<String>('http://bus.kuas.edu.tw/API/Scripts/a1');
    busEncryptObject = BusEncrypt(jsCode: res.data!);
  }

  Future<Map<String, dynamic>?> busLogin() async {
    /*
    Return type Map<String, dynamic>(from Json)
    response data (from NKUST)
    {
      'success': true,
      'code': 200,
      'message': 'User Name',
      'count': 1,
      'data': {}
    }
    Code:
    200: Login success.
    400: Wrong campus or not found user.
    302: Wrong password.
    */
    if (Helper.username == null || Helper.password == null) {
      throw 'NullThrownError';
    }

    await loginPrepare();

    final Response<Map<String, dynamic>> res =
        await dio.post<Map<String, dynamic>>(
      '${busHost}API/Users/login',
      data: <String, String?>{
        'account': Helper.username,
        'password': Helper.password,
        'n': busEncryptObject.loginEncrypt(
          Helper.username!,
          Helper.password!,
        )
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    if (res.data!['code'] == 200 && res.data!['success'] == true) {
      isLogin = true;
    }
    return res.data;
  }

  Future<BusData> timeTableQuery({
    required String year,
    required String month,
    required String day,
  }) async {
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw 'NullThrownError';
    }

    if (!isLogin) {
      await busLogin();
    }

    final Future<BusReservationsData> userRecord = busReservations();

    userTimeTableSelectCacheKey =
        '${Helper.username}_busCacheTimTable$year$month$day';
    Options options;
    dynamic requestData;
    if (!Helper.isSupportCacheData) {
      requestData = <String, dynamic>{
        'data': json.encode(<String, String?>{
          'y': year,
          'm': month,
          'd': day,
        }),
        'operation': '全部',
        'page': 1,
        'start': 0,
        'limit': 90
      };
      options = Options(contentType: Headers.formUrlEncodedContentType);
    } else {
      dio.options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
      requestData = formUrlEncoded(
        <String, dynamic>{
          'data': json.encode(<String, String?>{
            'y': year,
            'm': month,
            'd': day,
          }),
          'operation': '全部',
          'page': 1,
          'start': 0,
          'limit': 90
        },
      );
      options = buildCacheOptions(
        const Duration(seconds: 60),
        primaryKey: userTimeTableSelectCacheKey,
      );
    }
    final Response<Map<String, dynamic>> res =
        await dio.post<Map<String, dynamic>>(
      '${busHost}API/Frequencys/getAll',
      data: requestData,
      options: options,
    );

    if (res.data!['code'] == 400 &&
        (res.data!['message'] as String).contains('未登入或是登入逾')) {
      // Remove fail cache.
      if (Helper.isSupportCacheData) {
        _manager.delete(userTimeTableSelectCacheKey!);
      }
      reLoginReTryCounts += 1;
      await busLogin();
      return timeTableQuery(year: year, month: month, day: day);
    }
    reLoginReTryCounts = 0;
    return BusData.fromJson(
      busTimeTableParser(res.data!, busReservations: await userRecord),
    );
  }

  Future<BookingBusData> busBook({required String busId}) async {
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw 'NullThrownError';
    }

    if (!isLogin) {
      await busLogin();
    }
    if (Helper.isSupportCacheData) {
      _manager.delete(userRecordsCacheKey);
      _manager.delete(userTimeTableSelectCacheKey!);
    }

    final Response<Map<String, dynamic>> res =
        await dio.post<Map<String, dynamic>>(
      '${busHost}API/Reserves/add',
      data: <String, dynamic>{
        'busId': int.parse(busId),
      },
    );

    if (res.data!['code'] == 400 &&
        (res.data!['message'] as String).contains('未登入或是登入逾')) {
      reLoginReTryCounts += 1;
      await busLogin();
      return busBook(busId: busId);
    }
    return BookingBusData.fromJson(res.data!);
  }

  Future<CancelBusData> busUnBook({required String busId}) async {
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw 'NullThrownError';
    }

    if (!isLogin) {
      await busLogin();
    }
    final Response<Map<String, dynamic>> res =
        await dio.post<Map<String, dynamic>>(
      '${busHost}API/Reserves/remove',
      data: <String, dynamic>{
        'reserveId': int.parse(busId),
      },
    );

    if (res.data!['code'] == 400 &&
        (res.data!['message'] as String).contains('未登入或是登入逾')) {
      reLoginReTryCounts += 1;
      await busLogin();
      return busUnBook(busId: busId);
    }
    // Clear all cookie, because we can't sure user on which page.
    // two page can cencel bus.
    if (Helper.isSupportCacheData) _manager.clearAll();

    return CancelBusData.fromJson(res.data!);
  }

  Future<BusReservationsData> busReservations() async {
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw 'NullThrownError';
    }

    if (!isLogin) {
      await busLogin();
    }
    Options options;
    dynamic requestData;
    if (!Helper.isSupportCacheData) {
      requestData = <String, dynamic>{
        'page': 1,
        'start': 0,
        'limit': 90,
      };
      options = Options(contentType: Headers.formUrlEncodedContentType);
    } else {
      dio.options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
      requestData = formUrlEncoded(<String, dynamic>{
        'page': 1,
        'start': 0,
        'limit': 90,
      });
      options = buildCacheOptions(
        const Duration(seconds: 60),
        primaryKey: userRecordsCacheKey,
      );
    }

    final Response<Map<String, dynamic>> res =
        await dio.post<Map<String, dynamic>>(
      '${busHost}API/Reserves/getOwn',
      data: requestData,
      options: options,
    );

    if (res.data!['code'] == 400 &&
        (res.data!['message'] as String).contains('未登入或是登入逾')) {
      if (Helper.isSupportCacheData) _manager.delete(userRecordsCacheKey);
      reLoginReTryCounts += 1;
      await busLogin();
      return busReservations();
    }
    reLoginReTryCounts = 0;
    return BusReservationsData.fromJson(
      busReservationsParser(res.data!),
    );
  }

  Future<BusViolationRecordsData> busViolationRecords() async {
    if (reLoginReTryCounts > reLoginReTryCountsLimit) {
      throw 'NullThrownError';
    }

    if (!isLogin) {
      await busLogin();
    }
    Options options;
    dynamic requestData;
    if (!Helper.isSupportCacheData) {
      requestData = <String, int>{
        'page': 1,
        'start': 0,
        'limit': 200,
      };
      options = Options(contentType: Headers.formUrlEncodedContentType);
    } else {
      dio.options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
      requestData = formUrlEncoded(<String, int>{
        'page': 1,
        'start': 0,
        'limit': 200,
      });
      options = buildCacheOptions(
        const Duration(seconds: 60),
        primaryKey: userViolationRecordsCacheKey,
      );
    }

    final Response<Map<String, dynamic>> res =
        await dio.post<Map<String, dynamic>>(
      '${busHost}API/Illegals/getOwn',
      data: requestData,
      options: options,
    );

    if (res.data!['code'] == 400 &&
        (res.data!['message'] as String).contains('未登入或是登入逾')) {
      if (Helper.isSupportCacheData) {
        _manager.delete(userViolationRecordsCacheKey);
      }
      reLoginReTryCounts += 1;
      await busLogin();
      return busViolationRecords();
    }
    reLoginReTryCounts = 0;
    return BusViolationRecordsData.fromJson(
      busViolationRecordsParser(res.data!),
    );
  }
}
