@Tags(<String>['live'])
@TestOn('vm')
library;

import 'dart:io';

import 'package:ap_common_core/ap_common_core.dart';
import 'package:nkust_crawler/nkust_crawler.dart';
import 'package:test/test.dart';

import '_helpers.dart';

/// Drives the full read-only crawler flow against the real WebAP /
/// stdsys / acad systems with a real student account. Reads credentials
/// from the environment so they never live in the repo:
///
///     NKUST_USER=...        # student id
///     NKUST_PASS=...        # webap password
///     dart test -P live -r expanded
///
/// Side-effecting endpoints (bus booking / cancellation, leave submit)
/// are intentionally absent — running this test must never mutate state
/// on the school's servers.
void main() {
  final String username = Platform.environment['NKUST_USER'] ?? '';
  final String password = Platform.environment['NKUST_PASS'] ?? '';
  final bool hasCredentials = username.isNotEmpty && password.isNotEmpty;
  final String missingCredsReason =
      'NKUST_USER / NKUST_PASS not set — set both env vars to run this test';

  setUpAll(() async {
    if (!hasCredentials) {
      print('[live] no credentials in env — authenticated tests will skip');
      return;
    }

    print('[live] configuring in-memory storage');
    configureCrawlerStorage(InMemoryKeyValueStore());

    // Force stdsys for userInfo / course / score / semester. WebAP's
    // legacy `ag*` endpoints are unreliable / partially broken in
    // production; stdsys is the path the app uses by default. Login
    // itself still has to run through webap because that's the only
    // entry point that issues a session.
    print('[live] selector = stdsys for userInfo/course/score/semester');
    Helper.selector = CrawlerSelector(
      login: ScraperSource.webap,
      userInfo: ScraperSource.stdsys,
      course: ScraperSource.stdsys,
      score: ScraperSource.stdsys,
      semester: ScraperSource.stdsys,
    );

    print('[live] wiring EuclideanCaptchaSolver with FS-backed templates');
    final EuclideanCaptchaSolver solver =
        EuclideanCaptchaSolver(FileSystemTemplateProvider(findTemplateDir()));
    WebApHelper.instance.captchaSolver = solver;
    NKUSTHelper.instance.captchaSolver = solver;

    print('[live] login as $username (captcha retries up to 5×)');
    final LoginResponse? login = await Helper.instance.login(
      username: username,
      password: password,
    );
    print('[live]   ← session expires at ${login?.expireTime}');
    expect(login, isNotNull, reason: 'login() should return a LoginResponse');
  });

  test(
    'getUsersInfo returns the authenticated student',
    () async {
      print('[live] POST webap ag003 (user info)');
      final UserInfo info = await Helper.instance.getUsersInfo();
      print('[live]   ← id=${info.id} name=${info.name}');
      print('[live]     dept=${info.department} class=${info.className}');
      print('[live]     pictureUrl=${info.pictureUrl}');
      expect(info.id, isNotEmpty);
      expect(info.id.toUpperCase(), username.toUpperCase());
      expect(info.name, isNotEmpty);
    },
    skip: hasCredentials ? false : missingCredsReason,
    timeout: const Timeout(Duration(minutes: 1)),
  );

  test(
    'getSemester returns the current and historical semesters',
    () async {
      print('[live] POST webap ag304_01 (semester list)');
      final SemesterData data = await Helper.instance.getSemester();
      print('[live]   ← ${data.semesters.length} semesters');
      print('[live]     default: ${data.defaultSemester.year}/'
          '${data.defaultSemester.value} '
          '"${data.defaultSemester.text}"');
      expect(data.semesters, isNotEmpty);
      expect(data.defaultSemester.year, isNotEmpty);
      expect(data.defaultSemester.value, isNotEmpty);
    },
    skip: hasCredentials ? false : missingCredsReason,
    timeout: const Timeout(Duration(minutes: 1)),
  );

  test(
    'getCourseTables returns courses for the current semester',
    () async {
      final SemesterData semesters = await Helper.instance.getSemester();
      final Semester sem = semesters.defaultSemester;
      print('[live] POST webap ag222 (course table) for ${sem.year}/${sem.value}');
      final CourseData courses = await Helper.instance.getCourseTables(
        semester: sem,
      );
      print('[live]   ← ${courses.courses.length} courses, '
          '${courses.timeCodes?.length ?? 0} time codes');
      if (courses.courses.isEmpty) {
        print('[live]     (empty — student may not be enrolled this term)');
      } else {
        final Course first = courses.courses.first;
        print('[live]     e.g. "${first.title}" '
            '(${first.location?.building} ${first.location?.room})');
      }
      expect(courses.courses, isNotNull);
      expect(courses.timeCodes, isNotNull);
    },
    skip: hasCredentials ? false : missingCredsReason,
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'getScores returns score data (or null for an empty semester)',
    () async {
      final SemesterData semesters = await Helper.instance.getSemester();
      final Semester sem = semesters.defaultSemester;
      print('[live] webap→stdsys SSO + PDF transcript for ${sem.year}/${sem.value}');
      final ScoreData? scores = await Helper.instance.getScores(
        semester: sem,
      );
      if (scores == null) {
        print('[live]   ← null (no scores yet for this semester)');
      } else {
        print('[live]   ← ${scores.scores.length} score rows');
        print('[live]     conduct=${scores.detail.conduct} '
            'avg=${scores.detail.average}');
      }
      if (scores != null) {
        expect(scores.scores, isNotNull);
      }
    },
    // The stdsys score path returns a transcript PDF and decodes it via
    // [PdfTextExtractor]; the only implementation we ship
    // (`SyncfusionPdfTextExtractor`) transitively depends on `dart:ui`,
    // which is not available under pure-Dart `dart test`. Run this from
    // the Flutter app's smoke harness instead.
    skip: !hasCredentials
        ? missingCredsReason
        : 'getScores via stdsys needs SyncfusionPdfTextExtractor '
            '(Flutter-bound); test from the host app.',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
