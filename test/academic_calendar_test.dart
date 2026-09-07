import 'package:flutter_test/flutter_test.dart';
import 'package:nkust_ap/utils/academic_calendar.dart';

AcademicCalendarEvent event(String start, String end, String title) {
  return AcademicCalendarEvent.fromJson(<String, dynamic>{
    'start': start,
    'end': end,
    'title': title,
  });
}

void main() {
  final AcademicCalendarEvent midterm =
      event('2026-11-02', '2026-11-08', '第一學期期中考試');
  final AcademicCalendarEvent finals =
      event('2027-01-04', '2027-01-10', '第一學期期末考試');
  final AcademicCalendarEvent english =
      event('2026-11-30', '2026-12-04', '英文大會考');
  final List<AcademicCalendarEvent> calendar = <AcademicCalendarEvent>[
    midterm,
    english,
    finals,
  ];

  group('isMajorExam', () {
    test('matches only the midterm and final weeks', () {
      expect(midterm.isMajorExam, isTrue);
      expect(finals.isMajorExam, isTrue);
      expect(english.isMajorExam, isFalse);
    });

    test('other sittings are not marked', () {
      expect(english.category, AcademicCategory.general);
      expect(
        event('2026-11-25', '2026-11-25', '物理、化學競賽').category,
        AcademicCategory.general,
      );
      expect(
        event('2026-12-31', '2026-12-31', '研究生申請學位考試截止日').category,
        AcademicCategory.registrar,
      );
      expect(
        event('2026-09-25', '2026-09-25', '中秋節放假一天').category,
        AcademicCategory.holiday,
      );
    });

    test('shortens the banner label', () {
      expect(midterm.shortTitle, '期中考');
      expect(finals.shortTitle, '期末考');
      expect(english.shortTitle, '英文大會考');
    });
  });

  group('nextMajorExam', () {
    test('picks the nearest upcoming one', () {
      expect(nextMajorExam(calendar, DateTime(2026, 9, 7)), midterm);
    });

    test('keeps returning the exam while it is running', () {
      expect(nextMajorExam(calendar, DateTime(2026, 11, 2)), midterm);
      expect(nextMajorExam(calendar, DateTime(2026, 11, 8)), midterm);
    });

    test('moves on the day after it ends', () {
      expect(nextMajorExam(calendar, DateTime(2026, 11, 9)), finals);
    });

    test('never returns an unmarked sitting', () {
      expect(nextMajorExam(calendar, DateTime(2026, 11, 30)), finals);
    });

    test('returns null once both are behind us', () {
      expect(nextMajorExam(calendar, DateTime(2027, 1, 11)), isNull);
    });
  });

  group('daysUntil', () {
    test('counts down to the first day', () {
      expect(midterm.daysUntil(DateTime(2026, 11, 1)), 1);
      expect(midterm.daysUntil(DateTime(2026, 9, 7)), 56);
    });

    test('is zero once it has started', () {
      expect(midterm.daysUntil(DateTime(2026, 11, 2)), 0);
      expect(midterm.daysUntil(DateTime(2026, 11, 5)), 0);
    });

    test('ignores the time of day', () {
      expect(midterm.daysUntil(DateTime(2026, 11, 1, 23, 59)), 1);
    });
  });

  group('covers', () {
    test('includes both endpoints', () {
      expect(midterm.covers(DateTime(2026, 11, 2)), isTrue);
      expect(midterm.covers(DateTime(2026, 11, 8)), isTrue);
      expect(midterm.covers(DateTime(2026, 11, 1)), isFalse);
      expect(midterm.covers(DateTime(2026, 11, 9)), isFalse);
    });
  });

  group('eventsThisWeek', () {
    test('spans Monday to Sunday around the given day', () {
      // 2026-11-04 is a Wednesday, so the week is 11/02 – 11/08.
      final List<AcademicCalendarEvent> week =
          eventsThisWeek(calendar, DateTime(2026, 11, 4));
      expect(week, <AcademicCalendarEvent>[midterm]);
    });

    test('includes a range that only overlaps the edge', () {
      // 英文大會考 starts on Monday 11/30, seen from the 11/23 week's Sunday.
      expect(
        eventsThisWeek(calendar, DateTime(2026, 11, 29)),
        isEmpty,
      );
      expect(
        eventsThisWeek(calendar, DateTime(2026, 11, 30)),
        <AcademicCalendarEvent>[english],
      );
    });
  });
}
