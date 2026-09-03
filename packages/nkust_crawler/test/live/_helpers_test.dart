import 'package:test/test.dart';

import '_helpers.dart';

void main() {
  group('currentAcademicSemester', () {
    test('March 2026 → 114-2', () {
      final sem = currentAcademicSemester(DateTime(2026, 3, 15));
      expect(sem.year, '114');
      expect(sem.value, '2');
    });

    test('May 2026 → 114-2', () {
      final sem = currentAcademicSemester(DateTime(2026, 5, 2));
      expect(sem.year, '114');
      expect(sem.value, '2');
    });

    test('September 2026 → 114-2', () {
      final sem = currentAcademicSemester(DateTime(2026, 9, 30));
      expect(sem.year, '114');
      expect(sem.value, '2');
    });

    test('October 2026 → 115-1', () {
      final sem = currentAcademicSemester(DateTime(2026, 10, 1));
      expect(sem.year, '115');
      expect(sem.value, '1');
    });

    test('December 2026 → 115-1', () {
      final sem = currentAcademicSemester(DateTime(2026, 12, 31));
      expect(sem.year, '115');
      expect(sem.value, '1');
    });

    test('January 2027 → 115-1', () {
      final sem = currentAcademicSemester(DateTime(2027, 1, 15));
      expect(sem.year, '115');
      expect(sem.value, '1');
    });

    test('February 2027 → 115-1', () {
      final sem = currentAcademicSemester(DateTime(2027, 2, 28));
      expect(sem.year, '115');
      expect(sem.value, '1');
    });

    test('March 2027 → 115-2', () {
      final sem = currentAcademicSemester(DateTime(2027, 3, 1));
      expect(sem.year, '115');
      expect(sem.value, '2');
    });
  });
}
