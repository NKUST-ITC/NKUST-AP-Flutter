import 'dart:convert';
import 'dart:io';

import 'package:ap_common/ap_common.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:nkust_ap/api/api_config.dart';
import 'package:nkust_crawler/nkust_crawler.dart';
import 'package:nkust_ap/api/parser/vms_bus_parser.dart';

/// Scraper for the NKUST school bus system at `vms.nkust.edu.tw`.
///
/// Extracted from the original `MobileNkustHelper` which bundled two
/// unrelated concerns — the mobile.nkust.edu.tw portal scraper and the
/// vms.nkust.edu.tw bus integration — so the mobile portal code can be
/// removed without collateral damage to the bus flow. VMS has its own
/// form-POST login and session; it does not depend on the mobile portal
/// or on sharing cookies with WebAP.
class VmsBusHelper implements BusProvider {
  static const String baseUrl = 'https://vms.nkust.edu.tw/';

  static const String timetablePageUrl = '${baseUrl}Bus/Bus/Timetable';
  static const String timetableApiUrl = '${baseUrl}Bus/Bus/GetTimetableGrid';
  static const String bookApiUrl = '${baseUrl}Bus/Bus/CreateReserve';
  static const String unbookApiUrl = '${baseUrl}Bus/Bus/CancelReserve';
  static const String userRecordPageUrl = '${baseUrl}Bus/Bus/Reserve';
  static const String userRecordApiUrl = '${baseUrl}Bus/Bus/GetReserveGrid';
  static const String violationRecordsPageUrl = '${baseUrl}Bus/Bus/Illegal';
  static const String violationRecordsApiUrl =
      '${baseUrl}Bus/Bus/GetIllegalGrid';

  static VmsBusHelper? _instance;
  static VmsBusHelper get instance => _instance ??= VmsBusHelper();

  late Dio dio;
  late CookieJar cookieJar;

  /// Tracks whether [loginVms] has completed successfully at least once
  /// for the current process. Cleared by [Helper.clearSetting] via the
  /// registered cleanup callback so logout routes through one place.
  bool isLogin = false;

  VmsBusHelper() {
    dioInit();
  }

  void dioInit() {
    cookieJar = CookieJar();
    dio = Dio(
      BaseOptions(
        followRedirects: false,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: <String, String>{
          'user-agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
                  '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Encoding': 'gzip, deflate, br',
          'Accept-Language': 'zh-TW,zh;q=0.9,en-US;q=0.8,en;q=0.7',
          'Connection': 'keep-alive',
        },
        validateStatus: (int? status) => status != null && status < 500,
      ),
    );

    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS || Platform.isAndroid)) {
      dio.httpClientAdapter = NativeAdapter();
    }

    dio.interceptors.add(SafeCookieManager(cookieJar));
  }

  /// Logs into VMS via its direct form POST. A successful login returns
  /// a 302 redirect to the landing page, which Dio surfaces as a
  /// DioException because [dioInit] sets `followRedirects: false`. Treat
  /// 302 as the success path, rethrow anything else.
  Future<void> loginVms({
    required String username,
    required String password,
  }) async {
    try {
      await _request(
        baseUrl,
        postUrl: baseUrl,
        data: <String, dynamic>{
          'Account': username,
          'Password': password,
          'RememberMe': 'true',
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode != 302) rethrow;
    }
    isLogin = true;
  }

  /// Two-step CSRF form POST: GET [url] to read the page's
  /// `__RequestVerificationToken`, then POST [postUrl] with [data] and
  /// the extracted token merged in.
  Future<Response<dynamic>> _request(
    String url, {
    Map<String, dynamic>? headers,
    String? postUrl,
    Map<String, dynamic>? postHeaders,
    Map<String, dynamic>? data,
  }) async {
    Response<dynamic> response = await dio.get<dynamic>(
      url,
      options: Options(headers: headers),
    );

    if (data != null && postUrl != null) {
      final Map<String, dynamic> requestData = <String, dynamic>{
        '__RequestVerificationToken': getCSRF(response.data),
        ...data,
      };

      response = await dio.post<dynamic>(
        postUrl,
        data: requestData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: postHeaders,
        ),
      );
    }

    return response;
  }

  Future<BusData> busTimeTableQuery({required DateTime fromDateTime}) async {
    final String year = fromDateTime.year.toString();
    final String month = fromDateTime.month.toString().padLeft(2, '0');
    final String day = fromDateTime.day.toString().padLeft(2, '0');
    final String dateStr = '$year/$month/$day';

    final Response<String> pageResponse = await dio.get<String>(
      timetablePageUrl,
      options: Options(headers: <String, String>{'Referer': baseUrl}),
    );

    final Map<String, dynamic> busInfo = VmsBusParser.busInfo(pageResponse.data);
    final String csrf = getCSRF(pageResponse.data);

    final List<List<String>> routes = <List<String>>[
      <String>['建工', '燕巢'],
      <String>['燕巢', '建工'],
      <String>['第一', '建工'],
      <String>['建工', '第一'],
    ];

    final Iterable<Future<List<Map<String, dynamic>>>> futures =
        routes.map((List<String> route) async {
      final Response<dynamic> response = await dio.post<dynamic>(
        timetableApiUrl,
        data: <String, String>{
          'driveDate': dateStr,
          'beginStation': route[0],
          'endStation': route[1],
          '__RequestVerificationToken': csrf,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: <String, String>{'Referer': timetablePageUrl},
        ),
      );
      return VmsBusParser.busTimeTable(
        response.data,
        time: dateStr,
        startStation: route[0],
        endStation: route[1],
      );
    });

    final List<List<Map<String, dynamic>>> results = await Future.wait(futures);
    final List<Map<String, dynamic>> allBuses =
        results.expand((List<Map<String, dynamic>> list) => list).toList();

    return BusData.fromJson(<String, dynamic>{
      'data': allBuses,
      ...busInfo,
    });
  }

  Future<BookingBusData> busBook({required String busId}) async {
    final Response<dynamic> response = await _request(
      timetablePageUrl,
      postUrl: bookApiUrl,
      data: <String, String>{'busId': busId},
      headers: <String, String>{'Referer': baseUrl},
      postHeaders: <String, String>{'Referer': timetablePageUrl},
    );

    final Map<String, dynamic> data = _parseJsonResponse(response);
    return BookingBusData(
      success: (data['success'] as bool) && data['title'] == '預約成功',
    );
  }

  Future<CancelBusData> busUnBook({required String busId}) async {
    final Response<dynamic> response = await _request(
      timetablePageUrl,
      postUrl: unbookApiUrl,
      data: <String, String>{'reserveId': busId},
      headers: <String, String>{'Referer': baseUrl},
      postHeaders: <String, String>{'Referer': timetablePageUrl},
    );

    final Map<String, dynamic> data = _parseJsonResponse(response);
    return CancelBusData(
      success: (data['success'] as bool) && data['title'] == '取消成功',
    );
  }

  Future<BusReservationsData> busUserRecord() async {
    final Response<dynamic> pageResponse = await dio.get<dynamic>(
      userRecordPageUrl,
      options: Options(headers: <String, String>{'Referer': baseUrl}),
    );

    final String csrf = getCSRF(pageResponse.data);

    final List<List<String>> routes = <List<String>>[
      <String>['建工', '燕巢'],
      <String>['燕巢', '建工'],
      <String>['第一', '建工'],
      <String>['建工', '第一'],
    ];

    final Iterable<Future<List<Map<String, dynamic>>>> futures =
        routes.map((List<String> route) async {
      final Response<dynamic> response = await dio.post<dynamic>(
        userRecordApiUrl,
        data: <String, dynamic>{
          'reserveStateCode': 0,
          'beginStation': route[0],
          'endStation': route[1],
          'pageNum': 1,
          'pageSize': 99,
          '__RequestVerificationToken': csrf,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: <String, String>{'Referer': userRecordPageUrl},
        ),
      );
      return VmsBusParser.busUserRecords(
        '<table>${response.data}</table>',
        startStation: route[0],
        endStation: route[1],
      );
    });

    final List<List<Map<String, dynamic>>> results = await Future.wait(futures);
    final List<Map<String, dynamic>> allRecords =
        results.expand((List<Map<String, dynamic>> list) => list).toList();

    return BusReservationsData.fromJson(<String, dynamic>{'data': allRecords});
  }

  Future<BusViolationRecordsData> busViolationRecords() async {
    final Future<Response<dynamic>> paidFuture = _request(
      violationRecordsPageUrl,
      postUrl: violationRecordsApiUrl,
      data: <String, dynamic>{'paid': true, 'pageNum': 1, 'pageSize': 100},
      headers: <String, String>{'Referer': baseUrl},
      postHeaders: <String, String>{'Referer': violationRecordsPageUrl},
    );

    final Future<Response<dynamic>> notPaidFuture = _request(
      violationRecordsPageUrl,
      postUrl: violationRecordsApiUrl,
      data: <String, dynamic>{'paid': false, 'pageNum': 1, 'pageSize': 100},
      headers: <String, String>{'Referer': baseUrl},
      postHeaders: <String, String>{'Referer': violationRecordsPageUrl},
    );

    final List<Response<dynamic>> responses =
        await Future.wait(<Future<Response<dynamic>>>[paidFuture, notPaidFuture]);

    final List<Map<String, dynamic>> result = <Map<String, dynamic>>[
      ...VmsBusParser.busViolationRecords(
        '<table>${responses[0].data}</table>',
        paidStatus: true,
      ),
      ...VmsBusParser.busViolationRecords(
        '<table>${responses[1].data}</table>',
        paidStatus: false,
      ),
    ];

    return BusViolationRecordsData.fromJson(
      <String, dynamic>{'reservation': result},
    );
  }

  Map<String, dynamic> _parseJsonResponse(Response<dynamic> response) {
    if (response.data is String &&
        response.headers['Content-Type']?[0].contains('text/html') == true) {
      return jsonDecode(response.data as String) as Map<String, dynamic>;
    }
    return response.data as Map<String, dynamic>;
  }

  // -- BusProvider interface --

  @override
  Future<BusData> getTimeTable({required DateTime dateTime}) =>
      busTimeTableQuery(fromDateTime: dateTime);

  @override
  Future<BookingBusData> bookBus({required String busId}) =>
      busBook(busId: busId);

  @override
  Future<CancelBusData> cancelBus({required String busId}) =>
      busUnBook(busId: busId);

  @override
  Future<BusReservationsData> getReservations() => busUserRecord();

  @override
  Future<BusViolationRecordsData> getViolationRecords() =>
      busViolationRecords();
}
