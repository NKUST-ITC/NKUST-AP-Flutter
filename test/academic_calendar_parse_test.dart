import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nkust_ap/utils/academic_calendar.dart';

String doc(List<Map<String, dynamic>> events) => jsonEncode(events);

const Map<String, dynamic> _valid = <String, dynamic>{
  'start': '2026-11-02',
  'end': '2026-11-08',
  'title': '第一學期期中考試',
};

void main() {
  group('accepts', () {
    test('a well-formed document', () {
      final List<AcademicCalendarEvent>? events =
          parseAcademicCalendar(doc(<Map<String, dynamic>>[_valid]));
      expect(events, isNotNull);
      expect(events!.single.title, '第一學期期中考試');
      expect(events.single.category, AcademicCategory.exam);
    });

    test('an entry with no end date, treating it as a single day', () {
      final List<AcademicCalendarEvent>? events = parseAcademicCalendar(
        doc(<Map<String, dynamic>>[
          <String, dynamic>{'start': '2026-09-25', 'title': '中秋節放假一天'},
        ]),
      );
      expect(events!.single.isRange, isFalse);
      expect(events.single.end, DateTime(2026, 9, 25));
    });

    test('and sorts by start date', () {
      final List<AcademicCalendarEvent>? events = parseAcademicCalendar(
        doc(<Map<String, dynamic>>[
          <String, dynamic>{'start': '2027-01-04', 'title': '期末'},
          <String, dynamic>{'start': '2026-11-02', 'title': '期中'},
        ]),
      );
      expect(
        events!.map((AcademicCalendarEvent e) => e.title),
        <String>['期中', '期末'],
      );
    });
  });

  group('rejects the whole document when', () {
    void rejects(String name, String raw) {
      test(name, () => expect(parseAcademicCalendar(raw), isNull));
    }

    rejects('it is not JSON', 'not json at all');
    rejects('it is an object rather than a list', '{"events": []}');
    rejects('it is empty', '[]');
    rejects('an entry is not an object', '["2026-11-02"]');

    // DateTime.tryParse rolls these over instead of failing — 2026-13-45
    // comes back as 2027-02-14 — so a typo would otherwise land as a
    // plausible entry on the wrong day.
    rejects(
      'a date is out of range',
      doc(<Map<String, dynamic>>[
        <String, dynamic>{'start': '2026-13-45', 'title': '壞月份'},
      ]),
    );

    rejects(
      'a date is a day the month does not have',
      doc(<Map<String, dynamic>>[
        <String, dynamic>{'start': '2026-02-30', 'title': '二月三十'},
      ]),
    );

    rejects(
      'a date is not a date at all',
      doc(<Map<String, dynamic>>[
        <String, dynamic>{'start': '下週一', 'title': '不是日期'},
      ]),
    );

    rejects(
      'the end date is the one out of range',
      doc(<Map<String, dynamic>>[
        <String, dynamic>{
          'start': '2026-11-02',
          'end': '2026-11-32',
          'title': '壞結束日',
        },
      ]),
    );

    rejects(
      'start is missing',
      doc(<Map<String, dynamic>>[
        <String, dynamic>{'end': '2026-11-08', 'title': '沒有開始'},
      ]),
    );

    rejects(
      'start is the wrong type',
      doc(<Map<String, dynamic>>[
        <String, dynamic>{'start': 20261102, 'title': '數字'},
      ]),
    );

    rejects(
      'the title is blank',
      doc(<Map<String, dynamic>>[
        <String, dynamic>{'start': '2026-11-02', 'title': '   '},
      ]),
    );

    rejects(
      'only one entry out of many is bad',
      doc(<Map<String, dynamic>>[
        _valid,
        <String, dynamic>{'start': '2026-11-02'},
        _valid,
      ]),
    );

    // The shape Remote Config used to hold. It reached DateTime.parse as a
    // null and took the page down with it, which is why nothing partial is
    // allowed through here.
    rejects('it is the old {week, events} shape', '{"week": 9, "events": []}');
  });
}
