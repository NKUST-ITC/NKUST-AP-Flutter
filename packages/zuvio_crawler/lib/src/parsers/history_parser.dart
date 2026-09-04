import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

import 'package:zuvio_crawler/src/models/models.dart';

final RegExp _openAt = RegExp('開放時間：([0-9: -]+)');

/// Parses the 點名紀錄 tab of `/student5/irs/history/<courseId>`.
///
/// Each `.i-h-r-rollcall-row` carries a status class
/// (`i-h-r-r-r-punctual` / `-late` / `-nonarrival`), a `.i-h-r-r-r-top`
/// with the check-in timestamp (or `-`) and a `.i-h-r-r-r-bottom` with
/// `準時／遲到／未到` plus `開放時間：<datetime>`.
List<ZuvioAttendanceRecord> parseAttendanceHistory(String html) {
  final Document doc = parse(html);
  final List<ZuvioAttendanceRecord> out = <ZuvioAttendanceRecord>[];
  for (final Element row
      in doc.querySelectorAll('.i-h-r-rollcall-row')) {
    final String classes = row.className;
    final ZuvioAnswerStatus status = classes.contains('nonarrival')
        ? ZuvioAnswerStatus.missed
        : classes.contains('late')
            ? ZuvioAnswerStatus.late
            : ZuvioAnswerStatus.onTime;

    final String top =
        row.querySelector('.i-h-r-r-r-top')?.text.trim() ?? '';
    final String bottom =
        row.querySelector('.i-h-r-r-r-bottom')?.text.trim() ?? '';

    final DateTime? openAt =
        _parseDateTime(_openAt.firstMatch(bottom)?.group(1)?.trim());
    final DateTime? checkedInAt =
        top == '-' || top.isEmpty ? null : _parseDateTime(top);

    final DateTime? date = openAt ?? checkedInAt;
    if (date == null) continue;
    out.add(
      ZuvioAttendanceRecord(
        date: date,
        status: status,
        checkedInAt: checkedInAt,
      ),
    );
  }
  return out;
}

final RegExp _folderId = RegExp(r'irs_questions\(\s*\d+\s*,\s*(\d+)\s*\)');

/// Parses the 問答紀錄 folder list. Each `.i-h-a-folder-row` links to
/// `irs_questions(<courseId>, <folderId>)`; per-folder answered counts
/// load lazily via `app_v2/getFolderAnsweredAmount`.
List<ZuvioHistoryEntry> parseAnswerFolders(String html) {
  final Document doc = parse(html);
  final List<ZuvioHistoryEntry> out = <ZuvioHistoryEntry>[];
  for (final Element row in doc.querySelectorAll('.i-h-a-folder-row')) {
    final String name =
        row.querySelector('.i-h-a-f-r-folder-name')?.text.trim() ?? '';
    final RegExpMatch? m =
        _folderId.firstMatch(row.attributes['onclick'] ?? '');
    if (name.isEmpty || m == null) continue;
    out.add(ZuvioHistoryEntry(folderId: m.group(1)!, title: name));
  }
  return out;
}

DateTime? _parseDateTime(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw.replaceFirst(' ', 'T'));
}
