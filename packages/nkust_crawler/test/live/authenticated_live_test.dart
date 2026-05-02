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
///     dart test --tags live
///
/// Side-effecting endpoints (bus booking / cancellation, leave submit)
/// are intentionally absent — running this test must never mutate state
/// on the school's servers.
void main() {
  final String username = Platform.environment['NKUST_USER'] ?? '';
  final String password = Platform.environment['NKUST_PASS'] ?? '';
  final bool hasCredentials = username.isNotEmpty && password.isNotEmpty;

  setUpAll(() async {
    if (!hasCredentials) return;

    configureCrawlerStorage(InMemoryKeyValueStore());

    final EuclideanCaptchaSolver solver =
        EuclideanCaptchaSolver(FileSystemTemplateProvider(findTemplateDir()));
    WebApHelper.instance.captchaSolver = solver;
    NKUSTHelper.instance.captchaSolver = solver;

    final LoginResponse? login = await Helper.instance.login(
      username: username,
      password: password,
    );
    expect(login, isNotNull, reason: 'login() should return a LoginResponse');
  });

  test(
    'getUsersInfo returns the authenticated student',
    () async {
      final UserInfo info = await Helper.instance.getUsersInfo();
      expect(info.id, isNotEmpty);
      expect(info.id.toUpperCase(), username.toUpperCase());
      expect(info.name, isNotEmpty);
    },
    skip: hasCredentials ? false : 'NKUST_USER / NKUST_PASS not set',
    timeout: const Timeout(Duration(minutes: 1)),
  );

  test(
    'getSemester returns the current and historical semesters',
    () async {
      final SemesterData data = await Helper.instance.getSemester();
      expect(data.semesters, isNotEmpty);
      expect(data.defaultSemester.year, isNotEmpty);
      expect(data.defaultSemester.value, isNotEmpty);
    },
    skip: hasCredentials ? false : 'NKUST_USER / NKUST_PASS not set',
    timeout: const Timeout(Duration(minutes: 1)),
  );

  test(
    'getCourseTables returns courses for the current semester',
    () async {
      final SemesterData semesters = await Helper.instance.getSemester();
      final CourseData courses = await Helper.instance.getCourseTables(
        semester: semesters.defaultSemester,
      );
      // Some semesters legitimately have zero courses (e.g. summer term
      // for students who didn't enrol), so we only assert the shape.
      expect(courses.courses, isNotNull);
      expect(courses.timeCodes, isNotNull);
    },
    skip: hasCredentials ? false : 'NKUST_USER / NKUST_PASS not set',
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'getScores returns score data (or null for an empty semester)',
    () async {
      final SemesterData semesters = await Helper.instance.getSemester();
      final ScoreData? scores = await Helper.instance.getScores(
        semester: semesters.defaultSemester,
      );
      // Account that hasn't enrolled in the current semester yet returns
      // null; verify either null or a populated payload, never a malformed
      // partial.
      if (scores != null) {
        expect(scores.scores, isNotNull);
      }
    },
    skip: hasCredentials ? false : 'NKUST_USER / NKUST_PASS not set',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
