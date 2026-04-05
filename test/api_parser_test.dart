import 'dart:convert';
import 'dart:io';

import 'package:ap_common/ap_common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nkust_ap/api/parser/ap_parser.dart';
import 'package:nkust_ap/api/parser/bus_parser.dart';
import 'package:nkust_ap/api/parser/leave_parser.dart';
import 'package:nkust_ap/api/parser/mobile_nkust_parser.dart';
import 'package:nkust_ap/api/parser/nkust_parser.dart';
import 'package:nkust_ap/api/parser/stdsys_parser.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';

//ignore_for_file: lines_longer_than_80_chars

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ─── WebApParser: apLoginParser ──────────────────────────────────────
  group('WebApParser.apLoginParser', () {
    test('returns 500 for server busy', () {
      final String html =
          File('assets_test/login/server_busy.html').readAsStringSync();
      expect(WebApParser.instance.apLoginParser(html), 500);
    });

    test('returns 1 for password error', () {
      final String html =
          File('assets_test/login/password_error.html').readAsStringSync();
      expect(WebApParser.instance.apLoginParser(html), 1);
    });

    test('returns 0 for login success', () {
      final String html =
          File('assets_test/login/login_success.html').readAsStringSync();
      expect(WebApParser.instance.apLoginParser(html), 0);
    });

    test('returns -1 for verification code error', () {
      final String html = File('assets_test/login/verification_code_error.html')
          .readAsStringSync();
      expect(WebApParser.instance.apLoginParser(html), -1);
    });

    test('returns 2 for relogin', () {
      final String html =
          File('assets_test/login/relogin.html').readAsStringSync();
      expect(WebApParser.instance.apLoginParser(html), 2);
    });

    test('returns 5 for already logged in', () {
      final String html =
          File('assets_test/login/already_logged_in.html').readAsStringSync();
      expect(WebApParser.instance.apLoginParser(html), 5);
    });
  });

  // ─── WebApParser: apUserInfoParser ───────────────────────────────────
  group('WebApParser.apUserInfoParser', () {
    test('parses user info correctly', () {
      final String html =
          File('assets_test/ap/user_info.html').readAsStringSync();
      final Map<String, dynamic> result =
          WebApParser.instance.apUserInfoParser(html);

      expect(result['educationSystem'], contains('四技'));
      expect(result['department'], contains('資訊工程系'));
      expect(result['className'], contains('資工三甲'));
      expect(result['id'], contains('C110355001'));
      expect(result['name'], contains('王小明'));
      expect(result['pictureUrl'], contains('https://webap.nkust.edu.tw'));
    });
  });

  // ─── WebApParser: semestersParser ────────────────────────────────────
  group('WebApParser.semestersParser', () {
    test('parses semester list and default', () {
      final String html =
          File('assets_test/ap/semesters.html').readAsStringSync();
      final Map<String, dynamic> result =
          WebApParser.instance.semestersParser(html);

      final List<dynamic> data = result['data'] as List<dynamic>;
      expect(data.length, 31);
      expect(data[0]['year'], '113');
      expect(data[0]['value'], '1');
      expect(data[0]['text'], '113學年第一學期');

      final Map<String, dynamic> defaultSemester =
          result['default'] as Map<String, dynamic>;
      expect(defaultSemester['year'], '113');
      expect(defaultSemester['value'], '2');
      expect(defaultSemester['text'], '113學年第二學期');
    });
  });

  // ─── WebApParser: scoresParser ───────────────────────────────────────
  group('WebApParser.scoresParser', () {
    test('parses scores and detail', () {
      final String html =
          File('assets_test/ap/scores.html').readAsStringSync();
      final Map<String, dynamic> result =
          WebApParser.instance.scoresParser(html);

      final Map<String, dynamic> detail =
          result['detail'] as Map<String, dynamic>;
      expect(detail['conduct'], 85.5);
      expect(detail['average'], 82.3);
      expect(detail['classRank'], '5/45');
      expect(detail['departmentRank'], '12/180');

      final List<dynamic> scores = result['scores'] as List<dynamic>;
      expect(scores.length, 3);
      expect(scores[0]['title'], '程式設計');
      expect(scores[0]['units'], '3');
      expect(scores[0]['middleScore'], '88');
      expect(scores[0]['semesterScore'], '90');
    });
  });

  // ─── WebApParser: coursetableParser ──────────────────────────────────
  group('WebApParser.coursetableParser', () {
    test('parses course list and timeCodes', () async {
      final String html =
          File('assets_test/ap/coursetable.html').readAsStringSync();
      final Map<String, dynamic> result =
          await WebApParser.instance.coursetableParser(html);

      final List<dynamic> courses = result['courses'] as List<dynamic>;
      expect(courses.length, 2);
      expect(courses[0]['code'], 'CS101');
      expect(courses[0]['title'], '程式設計');
      expect(courses[0]['instructors'], <String>['王教授']);
      expect(courses[1]['title'], '資料結構');

      final List<dynamic> timeCodes = result['timeCodes'] as List<dynamic>;
      expect(timeCodes.length, greaterThanOrEqualTo(3));
      expect(timeCodes[0]['title'], contains('M'));
      expect(timeCodes[0]['startTime'], '07:10');
      expect(timeCodes[0]['endTime'], '08:00');

      // Verify sectionTimes are populated
      final List<dynamic> sectionTimes =
          courses[0]['sectionTimes'] as List<dynamic>;
      expect(sectionTimes, isNotEmpty);
      // 程式設計 is on Monday (weekday 1)
      expect(
        sectionTimes.any(
          (dynamic st) => st['weekday'] == 1,
        ),
        isTrue,
      );
    });
  });

  // ─── WebApParser: midtermAlertsParser ────────────────────────────────
  group('WebApParser.midtermAlertsParser', () {
    test('parses only alerted courses', () {
      final String html =
          File('assets_test/ap/midterm_alerts.html').readAsStringSync();
      final Map<String, dynamic> result =
          WebApParser.instance.midtermAlertsParser(html);

      final List<dynamic> courses = result['courses'] as List<dynamic>;
      // Only courses with '是' should be included (2 out of 3)
      expect(courses.length, 2);
      expect(courses[0]['title'], '程式設計');
      expect(courses[0]['reason'], '缺課過多');
      expect(courses[0]['remark'], '需加強出席');
      expect(courses[1]['title'], '英文');
      expect(courses[1]['reason'], '成績不佳');
    });
  });

  // ─── WebApParser: rewardAndPenaltyParser ─────────────────────────────
  group('WebApParser.rewardAndPenaltyParser', () {
    test('parses reward and penalty records', () {
      final String html =
          File('assets_test/ap/reward_and_penalty.html').readAsStringSync();
      final Map<String, dynamic> result =
          WebApParser.instance.rewardAndPenaltyParser(html);

      final List<dynamic> data = result['data'] as List<dynamic>;
      expect(data.length, 2);
      expect(data[0]['date'], '2024/03/15');
      expect(data[0]['type'], '嘉獎');
      expect(data[0]['counts'], '1');
      expect(data[0]['reason'], '參與志工服務');
      expect(data[1]['type'], '小功');
    });
  });

  // ─── WebApParser: roomListParser ─────────────────────────────────────
  group('WebApParser.roomListParser', () {
    test('parses room list from select options', () {
      final String html =
          File('assets_test/ap/room_list.html').readAsStringSync();
      final Map<String, dynamic> result =
          WebApParser.instance.roomListParser(html);

      final List<dynamic> data = result['data'] as List<dynamic>;
      expect(data.length, 3);
      expect(data[0]['roomName'], 'E201');
      expect(data[0]['roomId'], '0035');
      expect(data[1]['roomName'], 'E202');
      expect(data[2]['roomName'], 'E301');
    });
  });

  // ─── WebApParser: enrollmentRequestParser ────────────────────────────
  group('WebApParser.enrollmentRequestParser', () {
    test('parses form action and hidden params', () {
      final String html =
          File('assets_test/ap/enrollment_request.html').readAsStringSync();
      final Map<String, dynamic> result =
          WebApParser.instance.enrollmentRequestParser(html);

      expect(result['action'], 'ag003/ag003_01.jsp');
      final Map<String, String> params =
          result['params'] as Map<String, String>;
      expect(params['fncid'], 'AG003');
      expect(params['uid'], 'C110355001');
      expect(params['ls_randnum'], 'ABC123');
    });

    test('returns empty map for null input', () {
      final Map<String, dynamic> result =
          WebApParser.instance.enrollmentRequestParser(null);
      expect(result, isEmpty);
    });
  });

  // ─── WebApParser: enrollmentLetterPathParser ─────────────────────────
  group('WebApParser.enrollmentLetterPathParser', () {
    test('parses PDF path from object tag', () {
      final String html =
          File('assets_test/ap/enrollment_letter.html').readAsStringSync();
      final String? result =
          WebApParser.instance.enrollmentLetterPathParser(html);
      expect(result, '/nkust/ag003/enrollment_letter.pdf');
    });

    test('returns null for null input', () {
      expect(WebApParser.instance.enrollmentLetterPathParser(null), isNull);
    });

    test('returns null for empty input', () {
      expect(WebApParser.instance.enrollmentLetterPathParser(''), isNull);
    });
  });

  // ─── StdsysParser: userInfoParser ────────────────────────────────────
  group('StdsysParser.userInfoParser', () {
    test('parses user info from stdsys HTML', () {
      final String html =
          File('assets_test/stdsys/user_info.html').readAsStringSync();
      final UserInfo result = StdsysParser.userInfoParser(html);

      expect(result.id, 'C110355001');
      expect(result.name, '王小明');
      expect(result.department, '資訊工程系');
      expect(result.educationSystem, '四技');
      expect(result.className, '資工三甲');
      expect(
        result.pictureUrl,
        'https://stdsys.nkust.edu.tw/students/photo/C110355001.jpg',
      );
    });
  });

  // ─── StdsysParser: roomListParser ────────────────────────────────────
  group('StdsysParser.roomListParser', () {
    test('parses JSON room list', () {
      final String json =
          File('assets_test/stdsys/room_list.json').readAsStringSync();
      final Map<String, dynamic> result =
          StdsysParser.instance.roomListParser(json);

      final List<dynamic> data = result['data'] as List<dynamic>;
      expect(data.length, 3);
      expect(data[0]['roomName'], 'E201');
      expect(data[0]['roomId'], '0035');
      expect(data[1]['roomName'], 'E202');
      expect(data[2]['roomName'], 'E301');
    });

    test('returns empty list for null input', () {
      final Map<String, dynamic> result =
          StdsysParser.instance.roomListParser(null);
      expect((result['data'] as List<dynamic>), isEmpty);
    });
  });

  // ─── StdsysParser: studentCourseTableParser ──────────────────────────
  group('StdsysParser.studentCourseTableParser', () {
    test('parses student course table', () {
      final String html =
          File('assets_test/stdsys/course_table.html').readAsStringSync();
      final Map<String, dynamic> result =
          StdsysParser.instance.studentCourseTableParser(html);

      final List<dynamic> courses = result['courses'] as List<dynamic>;
      final List<dynamic> timeCodes = result['timeCodes'] as List<dynamic>;

      expect(timeCodes.length, 4); // M, 1, 2, 3
      expect(timeCodes[0]['title'], 'M');
      expect(timeCodes[0]['startTime'], '07:10');
      expect(timeCodes[0]['endTime'], '08:00');

      expect(courses.length, 2); // 程式設計, 資料結構
      final Map<String, dynamic> course1 = courses.firstWhere(
        (dynamic c) => c['title'] == '程式設計',
      ) as Map<String, dynamic>;
      expect(course1['instructors'], contains('王教授'));
      expect(course1['location']['room'], 'E201');
      final List<dynamic> sectionTimes =
          course1['sectionTimes'] as List<dynamic>;
      // 程式設計: Mon sections 1, 2, 3
      expect(sectionTimes.length, 3);
      expect(
        sectionTimes.every((dynamic st) => st['weekday'] == 1),
        isTrue,
      );
    });
  });

  // ─── Bus Parsers ─────────────────────────────────────────────────────
  group('busTimeTableParser', () {
    test('parses bus timetable JSON', () {
      final String json =
          File('assets_test/bus/timetable.json').readAsStringSync();
      final Map<String, dynamic> input =
          jsonDecode(json) as Map<String, dynamic>;
      // Cast data list elements
      input['data'] = (input['data'] as List<dynamic>)
          .map((dynamic e) => e as Map<String, dynamic>)
          .toList();
      final Map<String, dynamic> result = busTimeTableParser(input);

      final List<dynamic> data = result['data'] as List<dynamic>;
      expect(data.length, 2);
      expect(data[0]['startStation'], '建工');
      expect(data[0]['endStation'], '燕巢');
      expect(data[0]['busId'], '42');
      expect(data[0]['reserveCount'], 30);
      expect(data[0]['limitCount'], 50);
      expect(data[0]['isReserve'], isA<bool>());
      expect(data[0]['departureTime'], isNotEmpty);
      expect(data[1]['startStation'], '燕巢');
    });
  });

  group('busReservationsParser', () {
    test('parses bus reservations JSON', () {
      final String json =
          File('assets_test/bus/reservations.json').readAsStringSync();
      final Map<String, dynamic> input =
          jsonDecode(json) as Map<String, dynamic>;
      input['data'] = (input['data'] as List<dynamic>)
          .map((dynamic e) => e as Map<String, dynamic>)
          .toList();
      final Map<String, dynamic> result = busReservationsParser(input);

      final List<dynamic> data = result['data'] as List<dynamic>;
      expect(data.length, 2);
      expect(data[0]['cancelKey'], 'RSV001');
      expect(data[0]['start'], '建工');
      expect(data[0]['end'], '燕巢');
      expect(data[0]['state'], '已預約');
      expect(data[0]['dateTime'], isNotEmpty);
      expect(data[0]['endTime'], isNotEmpty);
    });
  });

  group('busViolationRecordsParser', () {
    test('parses bus violation records JSON', () {
      final String json =
          File('assets_test/bus/violation_records.json').readAsStringSync();
      final Map<String, dynamic> input =
          jsonDecode(json) as Map<String, dynamic>;
      input['data'] = (input['data'] as List<dynamic>)
          .map((dynamic e) => e as Map<String, dynamic>)
          .toList();
      final Map<String, dynamic> result = busViolationRecordsParser(input);

      final List<dynamic> data = result['reservation'] as List<dynamic>;
      expect(data.length, 2);
      expect(data[0]['startStation'], '建工');
      expect(data[0]['endStation'], '燕巢');
      expect(data[0]['amountend'], 100);
      expect(data[0]['isPayment'], false);
      expect(data[0]['time'], isNotEmpty);
      expect(data[1]['isPayment'], true);
    });
  });

  group('busRealTime', () {
    test('converts .NET ticks to ISO8601 string', () {
      final String result = busRealTime('637800036000000000');
      expect(result, isNotEmpty);
      // Should be parseable as DateTime
      expect(() => DateTime.parse(result), returnsNormally);
    });

    test('handles int input', () {
      final String result = busRealTime(637800036000000000);
      expect(() => DateTime.parse(result), returnsNormally);
    });
  });

  // ─── Leave Parsers ───────────────────────────────────────────────────
  group('leaveQueryParser', () {
    test('parses leave records and timeCodes', () {
      final String html =
          File('assets_test/leave/leave_query.html').readAsStringSync();
      final Map<String, dynamic> result = leaveQueryParser(html);

      final List<dynamic> timeCodes = result['timeCodes'] as List<dynamic>;
      expect(timeCodes, <String>['M', '1', '2', '3', '4']);

      final List<dynamic> data = result['data'] as List<dynamic>;
      expect(data.length, 2);
      expect(data[0]['leaveSheetId'], 'L001');
      expect(data[0]['date'], '2024/03/15');
      expect(data[0]['instructorsComment'], '已核准');
      final List<dynamic> sections =
          data[0]['sections'] as List<dynamic>;
      expect(sections.length, 2);
      expect(sections[0]['section'], '1');
      expect(sections[0]['reason'], '事假');

      expect(data[1]['leaveSheetId'], 'L002');
      final List<dynamic> sections2 =
          data[1]['sections'] as List<dynamic>;
      expect(sections2.length, 4); // M, 1, 2, 3 are 病假
    });

    test('returns empty for HTML without mGridDetail', () {
      final Map<String, dynamic> result =
          leaveQueryParser('<html><body></body></html>');
      expect((result['data'] as List<dynamic>), isEmpty);
      expect((result['timeCodes'] as List<dynamic>), isEmpty);
    });
  });

  group('leaveSubmitInfoParser', () {
    test('parses leave submit info', () {
      final String html =
          File('assets_test/leave/leave_submit_info.html').readAsStringSync();
      final Map<String, dynamic>? result = leaveSubmitInfoParser(html);

      expect(result, isNotNull);
      expect(result!['tutor']['name'], '王導師');
      expect(result['tutor']['id'], 'T001');

      final List<dynamic> types = result['type'] as List<dynamic>;
      expect(types.length, 3); // 事假, 病假, 公假
      expect(types[0]['title'], '事假');
      expect(types[0]['id'], '1');

      final List<dynamic> timeCodes = result['timeCodes'] as List<dynamic>;
      expect(timeCodes, <String>['M', '1', '2', '3', '4', 'A']);
    });
  });

  group('hiddenInputGet', () {
    test('extracts hidden inputs starting with underscore', () {
      const String html = '''
        <html><body>
        <input type="hidden" name="_VIEWSTATE" value="abc123" />
        <input type="hidden" name="_EVENTVALIDATION" value="xyz789" />
        <input type="hidden" name="normalField" value="ignore" />
        <input type="text" name="_textField" value="ignore" />
        </body></html>
      ''';
      final Map<String?, dynamic> result = hiddenInputGet(html);
      expect(result['_VIEWSTATE'], 'abc123');
      expect(result['_EVENTVALIDATION'], 'xyz789');
      expect(result.containsKey('normalField'), isFalse);
    });
  });

  group('allInputValueParser', () {
    test('extracts all input values', () {
      const String html = '''
        <html><body>
        <input name="field1" value="value1" />
        <input name="field2" value="value2" />
        <input name="field3" value="" />
        </body></html>
      ''';
      final Map<String?, dynamic> result = allInputValueParser(html);
      expect(result['field1'], 'value1');
      expect(result['field2'], 'value2');
      expect(result['field3'], '');
    });
  });

  // ─── Nkust Parser ────────────────────────────────────────────────────
  group('acadParser', () {
    test('parses academic notifications', () {
      final String html =
          File('assets_test/nkust/acad.html').readAsStringSync();
      final List<Map<String, dynamic>> result =
          acadParser(html: html, baseIndex: 0);

      expect(result.length, 3);
      expect(result[0]['link'], '/news/001');
      expect(result[0]['info']['title'], '113學年度第二學期選課公告');
      expect(result[0]['info']['date'], contains('2024/03/15'));
      expect(result[0]['info']['department'], contains('教務處'));
      expect(result[0]['info']['index'], 0);

      expect(result[1]['link'], '/news/002');
      expect(result[1]['info']['title'], '校園防疫措施公告');
      expect(result[1]['info']['index'], 1);

      expect(result[2]['info']['index'], 2);
    });

    test('respects baseIndex parameter', () {
      final String html =
          File('assets_test/nkust/acad.html').readAsStringSync();
      final List<Map<String, dynamic>> result =
          acadParser(html: html, baseIndex: 10);

      expect(result[0]['info']['index'], 10);
      expect(result[1]['info']['index'], 11);
      expect(result[2]['info']['index'], 12);
    });
  });

  // ─── MobileNkustParser ──────────────────────────────────────────────
  group('MobileNkustParser.userInfo', () {
    test('parses user info from mobile portal', () {
      final String html =
          File('assets_test/mobile/user_info.html').readAsStringSync();
      final UserInfo result = MobileNkustParser.userInfo(html);

      expect(result.id, 'C110355001');
      expect(result.department, '資訊工程系');
      expect(result.name, '王小明');
    });

    test('returns empty UserInfo for missing user-header', () {
      final UserInfo result =
          MobileNkustParser.userInfo('<html><body></body></html>');
      expect(result.id, '');
    });
  });

  group('MobileNkustParser.scores', () {
    test('parses scores from mobile portal', () {
      final String html =
          File('assets_test/mobile/scores.html').readAsStringSync();
      final ScoreData result = MobileNkustParser.scores(html);

      expect(result.scores.length, 2);
      expect(result.scores[0].title, '程式設計');
      expect(result.scores[0].units, '3');
      expect(result.scores[0].middleScore, '88');
      expect(result.scores[0].semesterScore, '90');
      expect(result.scores[1].title, '資料結構');

      expect(result.detail.average, 82.3);
      expect(result.detail.conduct, 85.5);
      expect(result.detail.classRank, '5/45');
      expect(result.detail.departmentRank, '12/180');
    });

    test('returns empty ScoreData for missing datatable', () {
      final ScoreData result =
          MobileNkustParser.scores('<html><body></body></html>');
      expect(result.scores, isEmpty);
    });
  });

  group('MobileNkustParser.courseTable', () {
    test('parses course table from embedded JSON', () {
      final String html =
          File('assets_test/mobile/course_table.html').readAsStringSync();
      final CourseData result = MobileNkustParser.courseTable(html);

      expect(result.courses.length, 2);
      expect(result.courses[0].code, 'CS101');
      expect(result.courses[0].title, '程式設計');
      expect(result.courses[0].className, '資工三甲');
      expect(result.courses[0].instructors, <String>['王教授']);
      expect(result.courses[0].location?.room, 'E201');

      // 程式設計: Mon periods 2,3,4
      expect(result.courses[0].times.length, 3);
      for (final SectionTime st in result.courses[0].times) {
        expect(st.weekday, 1); // Monday
      }

      // 資料結構: Wed periods 2,3,4
      expect(result.courses[1].times.length, 3);
      for (final SectionTime st in result.courses[1].times) {
        expect(st.weekday, 3); // Wednesday
      }

      // timeCodes: M, 1, 2, 3, 4
      expect(result.timeCodes.length, 5);
      expect(result.timeCodes[0].title, '第M節');
      expect(result.timeCodes[0].startTime, '07:10');
      expect(result.timeCodes[0].endTime, '08:00');
    });
  });

  group('MobileNkustParser.getCSRF', () {
    test('extracts CSRF token', () {
      final String html =
          File('assets_test/mobile/csrf.html').readAsStringSync();
      final String result = MobileNkustParser.getCSRF(html);
      expect(result, 'CfDJ8ABC123XYZ789');
    });

    test('returns empty string when token not found', () {
      final String result =
          MobileNkustParser.getCSRF('<html><body></body></html>');
      expect(result, '');
    });
  });

  group('MobileNkustParser.midtermAlerts', () {
    test('returns empty list (not yet implemented)', () {
      final MidtermAlertsData result =
          MobileNkustParser.midtermAlerts('<html></html>');
      expect(result.courses, isEmpty);
    });
  });
}
