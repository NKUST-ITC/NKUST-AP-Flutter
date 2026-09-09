import 'package:test/test.dart';
import 'package:zuvio_crawler/src/models/models.dart';
import 'package:zuvio_crawler/src/parsers/history_parser.dart';

import 'support.dart';

void main() {
  group('parseAttendanceHistory', () {
    test('maps each row to the right status', () {
      final List<ZuvioAttendanceRecord> rows =
          parseAttendanceHistory(fixture('history.html'));
      expect(
        rows.map((ZuvioAttendanceRecord r) => r.status),
        <ZuvioAnswerStatus>[
          ZuvioAnswerStatus.onTime,
          ZuvioAnswerStatus.late,
          ZuvioAnswerStatus.missed,
          ZuvioAnswerStatus.unknown,
        ],
      );
    });

    test('an unrecognized status class reads as unknown, not onTime', () {
      // A row Zuvio marks some other way (公假/病假/a class we haven't
      // seen) must not silently render as "準時" in the app.
      final List<ZuvioAttendanceRecord> rows =
          parseAttendanceHistory(fixture('history.html'));
      expect(rows.last.status, ZuvioAnswerStatus.unknown);
    });

    test('keeps the check-in time when present and drops the "-" placeholder',
        () {
      final List<ZuvioAttendanceRecord> rows =
          parseAttendanceHistory(fixture('history.html'));
      expect(rows[0].checkedInAt, DateTime.parse('2025-03-03T09:02:11'));
      expect(rows[0].date, DateTime.parse('2025-03-03T09:00:00'));
      expect(rows[2].checkedInAt, isNull);
      expect(rows[2].date, DateTime.parse('2025-03-17T09:00:00'));
    });
  });

  group('parseAnswerFolders', () {
    test('reads folder id and title from the onclick handler', () {
      final List<ZuvioHistoryEntry> folders =
          parseAnswerFolders(fixture('history.html'));
      expect(folders, hasLength(2));
      expect(folders.first.folderId, '20301');
      expect(folders.first.title, '第一週 課堂測驗');
      expect(folders.last.folderId, '20302');
    });
  });
}
