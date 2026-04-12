import 'dart:convert';
import 'dart:io';

import 'package:ap_common/ap_common.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/io.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:nkust_ap/api/api_config.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/api/parser/bus_parser.dart';
import 'package:nkust_ap/api/capability/bus_provider.dart';
import 'package:nkust_ap/api/relogin_mixin.dart';
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
        'f': passwordMD5,
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

class BusHelper with ReloginMixin implements BusProvider {
  BusHelper() {
    dioInit();
  }

  late Dio dio;
  static BusHelper? _instance;
  late CookieJar cookieJar;

  @override
  int get maxRelogins => 5;

  bool isLogin = false;

  static late BusEncrypt busEncryptObject;
  static String busHost = 'http://bus.kuas.edu.tw/';

  //ignore: prefer_constructors_over_static_methods
  static BusHelper get instance {
    return _instance ??= BusHelper();
  }

  void setProxy(String proxyIP) {
    ApiConfig.setProxy(dio, proxyIP);
  }

  void dioInit() {
    final (:dio, :cookieJar) = ApiConfig.createScraperDio();
    this.dio = dio;
    this.cookieJar = cookieJar;
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
        ),
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    if (res.data!['code'] == 200 && res.data!['success'] == true) {
      isLogin = true;
    }
    return res.data;
  }

  /// Checks if a Bus API response indicates an expired session.
  static bool _isBusSessionExpired(Object error) =>
      error is BusSessionExpiredException;

  Future<BusData> timeTableQuery({
    required String year,
    required String month,
    required String day,
  }) async {
    return withAutoRelogin(
      action: () => _doTimeTableQuery(year: year, month: month, day: day),
      relogin: () => busLogin(),
      isSessionExpired: _isBusSessionExpired,
    );
  }

  Future<BusData> _doTimeTableQuery({
    required String year,
    required String month,
    required String day,
  }) async {
    if (!isLogin) await busLogin();

    final Future<BusReservationsData> userRecord = busReservations();

    final Response<Map<String, dynamic>> res =
        await dio.post<Map<String, dynamic>>(
      '${busHost}API/Frequencys/getAll',
      data: <String, dynamic>{
        'data': json.encode(<String, String?>{
          'y': year,
          'm': month,
          'd': day,
        }),
        'operation': '全部',
        'page': 1,
        'start': 0,
        'limit': 90,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    _checkBusSessionExpired(res.data!);
    return BusData.fromJson(
      busTimeTableParser(res.data!, busReservations: await userRecord),
    );
  }

  Future<BookingBusData> busBook({required String busId}) async {
    return withAutoRelogin(
      action: () async {
        if (!isLogin) await busLogin();

        final Response<Map<String, dynamic>> res =
            await dio.post<Map<String, dynamic>>(
          '${busHost}API/Reserves/add',
          data: <String, dynamic>{
            'busId': int.parse(busId),
          },
        );

        _checkBusSessionExpired(res.data!);
        return BookingBusData.fromJson(res.data!);
      },
      relogin: () => busLogin(),
      isSessionExpired: _isBusSessionExpired,
    );
  }

  Future<CancelBusData> busUnBook({required String busId}) async {
    return withAutoRelogin(
      action: () async {
        if (!isLogin) await busLogin();

        final Response<Map<String, dynamic>> res =
            await dio.post<Map<String, dynamic>>(
          '${busHost}API/Reserves/remove',
          data: <String, dynamic>{
            'reserveId': int.parse(busId),
          },
        );

        _checkBusSessionExpired(res.data!);
        return CancelBusData.fromJson(res.data!);
      },
      relogin: () => busLogin(),
      isSessionExpired: _isBusSessionExpired,
    );
  }

  Future<BusReservationsData> busReservations() async {
    return withAutoRelogin(
      action: () async {
        if (!isLogin) await busLogin();

        final Response<Map<String, dynamic>> res =
            await dio.post<Map<String, dynamic>>(
          '${busHost}API/Reserves/getOwn',
          data: <String, dynamic>{
            'page': 1,
            'start': 0,
            'limit': 90,
          },
          options: Options(contentType: Headers.formUrlEncodedContentType),
        );

        _checkBusSessionExpired(res.data!);
        return BusReservationsData.fromJson(
          busReservationsParser(res.data!),
        );
      },
      relogin: () => busLogin(),
      isSessionExpired: _isBusSessionExpired,
    );
  }

  Future<BusViolationRecordsData> busViolationRecords() async {
    return withAutoRelogin(
      action: () async {
        if (!isLogin) await busLogin();

        final Response<Map<String, dynamic>> res =
            await dio.post<Map<String, dynamic>>(
          '${busHost}API/Illegals/getOwn',
          data: <String, int>{
            'page': 1,
            'start': 0,
            'limit': 200,
          },
          options: Options(contentType: Headers.formUrlEncodedContentType),
        );

        _checkBusSessionExpired(res.data!);
        return BusViolationRecordsData.fromJson(
          busViolationRecordsParser(res.data!),
        );
      },
      relogin: () => busLogin(),
      isSessionExpired: _isBusSessionExpired,
    );
  }

  /// Throws [BusSessionExpiredException] if the server response indicates
  /// an expired session.
  void _checkBusSessionExpired(Map<String, dynamic> data) {
    if (data['code'] == 400 &&
        (data['message'] as String).contains('未登入或是登入逾')) {
      isLogin = false;
      throw BusSessionExpiredException(data['message'] as String);
    }
  }

  // -- BusProvider interface implementations --

  @override
  Future<BusData> getTimeTable({required DateTime dateTime}) =>
      timeTableQuery(
        year: '${dateTime.year}',
        month: '${dateTime.month}',
        day: '${dateTime.day}',
      );

  @override
  Future<BookingBusData> bookBus({required String busId}) =>
      busBook(busId: busId);

  @override
  Future<CancelBusData> cancelBus({required String busId}) =>
      busUnBook(busId: busId);

  @override
  Future<BusReservationsData> getReservations() => busReservations();

  @override
  Future<BusViolationRecordsData> getViolationRecords() =>
      busViolationRecords();
}
