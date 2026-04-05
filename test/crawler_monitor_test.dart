@Tags(<String>['integration'])
import 'dart:io';

import 'package:ap_common/ap_common.dart';
import 'package:ap_common_core/injector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nkust_ap/api/ap_helper.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/api/parser/ap_parser.dart';
import 'package:nkust_ap/api/stdsys_helper.dart';

//ignore_for_file: lines_longer_than_80_chars, avoid_print

/// No-op implementation of [CrashlyticsUtil] for test environments
/// where Firebase is not initialized.
class _NoopCrashlyticsUtil extends CrashlyticsUtil {
  const _NoopCrashlyticsUtil();

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace stack, {
    dynamic reason,
    Iterable<Object>? information,
    bool? printDetails,
  }) async {}

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {}

  @override
  Future<void> log(String message) async {}

  @override
  Future<void> setCustomKey(String key, Object value) async {}
}

/// Crawler monitor integration tests.
///
/// These tests make real HTTP requests to school servers to validate
/// that endpoints are reachable and HTML/JSON structures haven't changed.
///
/// Required environment variables:
///   NKUST_USERNAME — student ID
///   NKUST_PASSWORD — password
///
/// Run manually:
///   flutter test test/crawler_monitor_test.dart --tags integration
///
/// These tests are NOT run during normal CI — only via the scheduled
/// crawler-monitor workflow.

/// Endpoints to health-check (no auth required).
const Map<String, String> _healthCheckEndpoints = <String, String>{
  'WebAP': 'https://webap.nkust.edu.tw/nkust/index.html',
  'Stdsys': 'https://stdsys.nkust.edu.tw/',
  'Leave': 'https://leave.nkust.edu.tw/',
  'Mobile': 'https://mobile.nkust.edu.tw/',
  'Bus (VMS)': 'https://vms.nkust.edu.tw/',
  '校務公告': 'https://acad.nkust.edu.tw/',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final String? username = Platform.environment['NKUST_USERNAME'];
  final String? password = Platform.environment['NKUST_PASSWORD'];

  if (username == null || password == null) {
    print('⚠ NKUST_USERNAME / NKUST_PASSWORD not set — skipping integration tests');
    return;
  }

  // ─── Setup ─────────────────────────────────────────────────────────────
  setUpAll(() {
    // Register no-op CrashlyticsUtil so helpers don't crash
    // when Firebase is not initialized.
    injector.registerSingleton<CrashlyticsUtil>(
      () => const _NoopCrashlyticsUtil(),
    );
    Helper.username = username;
    Helper.password = password;
    Helper.isSupportCacheData = false;
  });

  // ─── Health Check（不需帳密，純偵測網站是否存活）──────────────────────
  group('Health Check', () {
    final Dio healthDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        followRedirects: true,
        validateStatus: (int? status) => status != null && status < 500,
      ),
    );

    for (final MapEntry<String, String> entry
        in _healthCheckEndpoints.entries) {
      test('${entry.key} is reachable', () async {
        final Response<dynamic> response = await healthDio.get<dynamic>(
          entry.value,
        );
        expect(
          response.statusCode,
          lessThan(500),
          reason: '${entry.key} returned HTTP ${response.statusCode}',
        );
        print('  ✓ ${entry.key}: HTTP ${response.statusCode}');
      });
    }
  });

  // ─── WebAP ─────────────────────────────────────────────────────────────
  group('WebAP', () {
    test('login succeeds', () async {
      final loginResponse = await WebApHelper.instance.login(
        username: username,
        password: password,
      );
      expect(loginResponse.expireTime, isNotNull);
      expect(WebApHelper.instance.isLogin, isTrue);
    });

    test('user info has expected fields', () async {
      final UserInfo userInfo = await WebApHelper.instance.userInfoCrawler();
      expect(userInfo.id, isNotEmpty);
      expect(userInfo.name, isNotEmpty);
      print('  ✓ userInfo: id=${userInfo.id}, name=${userInfo.name}');
    });

    test('semesters returns non-empty list', () async {
      final SemesterData semesters = await WebApHelper.instance.semesters();
      expect(semesters.data, isNotEmpty);
      expect(semesters.defaultSemester, isNotNull);
      print('  ✓ semesters: ${semesters.data.length} entries, default=${semesters.defaultSemester.text}');
    });

    test('scores has expected structure', () async {
      final SemesterData semesters = await WebApHelper.instance.semesters();
      final Semester semester = semesters.defaultSemester;
      final ScoreData scores = await WebApHelper.instance.scores(
        semester.year,
        semester.value,
      );
      expect(scores, isNotNull);
      print('  ✓ scores: ${scores.scores.length} courses');
    });

    test('course table has expected structure', () async {
      final SemesterData semesters = await WebApHelper.instance.semesters();
      final Semester semester = semesters.defaultSemester;
      final Response<dynamic> query = await WebApHelper.instance.apQuery(
        'ag222',
        <String, String?>{
          'arg01': semester.year,
          'arg02': semester.value,
        },
        bytesResponse: true,
      );
      final Map<String, dynamic> result =
          await WebApParser.instance.coursetableParser(query.data);
      expect(result.containsKey('courses'), isTrue);
      expect(result.containsKey('timeCodes'), isTrue);
      final List<dynamic> courses = result['courses'] as List<dynamic>;
      print('  ✓ courseTable: ${courses.length} courses');
    });

    test('midterm alerts has expected structure', () async {
      final SemesterData semesters = await WebApHelper.instance.semesters();
      final Semester semester = semesters.defaultSemester;
      final Response<dynamic> query = await WebApHelper.instance.apQuery(
        'ag009',
        <String, String?>{
          'arg01': semester.year,
          'arg02': semester.value,
        },
      );
      final Map<String, dynamic> result =
          WebApParser.instance.midtermAlertsParser(query.data as String);
      expect(result.containsKey('courses'), isTrue);
      print('  ✓ midtermAlerts: ${(result['courses'] as List).length} alerts');
    });

    test('reward and penalty has expected structure', () async {
      final SemesterData semesters = await WebApHelper.instance.semesters();
      final Semester semester = semesters.defaultSemester;
      final Response<dynamic> query = await WebApHelper.instance.apQuery(
        'ak010',
        <String, String?>{
          'arg01': semester.year,
          'arg02': semester.value,
        },
      );
      final Map<String, dynamic> result =
          WebApParser.instance.rewardAndPenaltyParser(query.data as String);
      expect(result.containsKey('data'), isTrue);
      print('  ✓ rewardAndPenalty: ${(result['data'] as List).length} records');
    });

    test('room list has expected structure', () async {
      final Response<dynamic> query = await WebApHelper.instance.apQuery(
        'ag302_01',
        null,
      );
      final Map<String, dynamic> result =
          WebApParser.instance.roomListParser(query.data as String);
      expect(result.containsKey('data'), isTrue);
      expect((result['data'] as List), isNotEmpty);
      print('  ✓ roomList: ${(result['data'] as List).length} rooms');
    });
  });

  // ─── Stdsys ────────────────────────────────────────────────────────────
  group('Stdsys', () {
    test('login via bridge succeeds', () async {
      await WebApHelper.instance.loginToStdsys();
      print('  ✓ stdsys login bridge OK');
    });

    test('user info has expected fields', () async {
      final UserInfo userInfo = await StdsysHelper.instance.getUserInfo();
      expect(userInfo.id, isNotEmpty);
      expect(userInfo.name, isNotEmpty);
      print('  ✓ stdsys userInfo: id=${userInfo.id}, name=${userInfo.name}');
    });

    test('course table has expected structure', () async {
      final SemesterData semesters = await WebApHelper.instance.semesters();
      final Semester semester = semesters.defaultSemester;
      final CourseData courseData = await StdsysHelper.instance.getCourseTable(
        year: semester.year,
        semester: semester.value,
      );
      expect(courseData, isNotNull);
      print('  ✓ stdsys courseTable: ${courseData.courses.length} courses');
    });

    test('room list returns data', () async {
      final SemesterData semesters = await WebApHelper.instance.semesters();
      final Semester semester = semesters.defaultSemester;
      // Campus 1 = 建工
      final result = await StdsysHelper.instance.roomList(
        '1',
        semester.year,
        semester.value,
      );
      expect(result.data, isNotEmpty);
      print('  ✓ stdsys roomList: ${result.data.length} rooms');
    });
  });

  // ─── Leave ─────────────────────────────────────────────────────────────
  group('Leave', () {
    test('login via bridge succeeds', () async {
      await WebApHelper.instance.loginToLeave();
      print('  ✓ leave login bridge OK');
    });
  });

  // ─── Mobile (bridge) ──────────────────────────────────────────────────
  group('Mobile', () {
    test('login via bridge succeeds', () async {
      await WebApHelper.instance.loginToMobile();
      print('  ✓ mobile login bridge OK');
    });
  });
}
