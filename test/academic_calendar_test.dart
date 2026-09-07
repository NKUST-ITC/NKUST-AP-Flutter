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
  group('category', () {
    test('marks the two exam weeks', () {
      expect(
        event('2026-11-02', '2026-11-08', '第一學期期中考試').category,
        AcademicCategory.exam,
      );
      expect(
        event('2027-01-04', '2027-01-10', '第一學期期末考試').category,
        AcademicCategory.exam,
      );
    });

    test('leaves application deadlines to the registrar', () {
      expect(
        event('2026-12-31', '2026-12-31', '研究生申請學位考試截止日').category,
        AcademicCategory.registrar,
      );
      expect(
        event('2026-09-07', '2026-09-07', '研究生申請學位考試（9/7 起）').category,
        AcademicCategory.registrar,
      );
    });

    test('leaves the other sittings unmarked', () {
      expect(
        event('2026-11-30', '2026-12-04', '英文大會考').category,
        AcademicCategory.general,
      );
      expect(
        event('2026-11-25', '2026-11-25', '物理、化學競賽').category,
        AcademicCategory.general,
      );
    });

    test('still recognises the other categories', () {
      expect(
        event('2026-09-25', '2026-09-25', '中秋節放假一天').category,
        AcademicCategory.holiday,
      );
      expect(
        event('2026-09-07', '2026-09-16', '115-1學期選課加退選').category,
        AcademicCategory.enrollment,
      );
    });
  });
}
