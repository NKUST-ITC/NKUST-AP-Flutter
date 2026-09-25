import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter_test/flutter_test.dart';
import 'package:nkust_ap/utils/academic_calendar_parser.dart';
import 'package:nkust_ap/utils/academic_calendar_source.dart';

/// Reading the registry's own PDFs is the app's primary source, so these run
/// against the real documents rather than a hand-written sample: the thing
/// most likely to break is the school changing a layout, and only the real
/// file can catch that.
/// Set to rewrite the golden files from what the parser currently produces:
///
///     UPDATE_CALENDAR_GOLDEN=1 flutter test test/academic_calendar_pdf_test.dart
///
/// Then read `git diff` before committing — the point of the goldens is that
/// a change to them is something a person looked at.
const String _updateGolden = 'UPDATE_CALENDAR_GOLDEN';

void main() {
  ParsedCalendar parse(String code) {
    final Uint8List bytes =
        File('assets_test/calendar/$code.pdf').readAsBytesSync();
    final ParsedCalendar? parsed = parseCalendarDocument(bytes);
    expect(parsed, isNotNull, reason: '$code.pdf no longer parses');
    return parsed!;
  }

  void checkGolden(String code, List<Map<String, String>> events) {
    final File file = File('assets_test/calendar/$code.expected.json');
    if (Platform.environment.containsKey(_updateGolden)) {
      file.writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(events)}\n',
      );
      return;
    }
    final List<dynamic> expected =
        jsonDecode(file.readAsStringSync()) as List<dynamic>;
    // Length first: a mismatched entry reads far better than a diff of
    // forty-odd maps does.
    expect(events.length, expected.length);
    expect(events, expected);
  }

  group('parseCalendarDocument', () {
    test('reads the semester off the heading', () {
      expect(parse('115-1').code, '115-1');
      expect(parse('115-2').code, '115-2');
    });

    test('reproduces every entry the CI script publishes', () {
      // The goldens are the Python parser's output for these same bytes, so
      // this holds two independent readers — different language, different
      // PDF library — to the same answer, entry for entry. A count alone
      // would not notice a title losing a character or a range ending in
      // the wrong year, which is exactly how this would break.
      checkGolden('115-1', parse('115-1').events);
      checkGolden('115-2', parse('115-2').events);
    });

    test('a first semester crosses into the new year, a second does not', () {
      final List<Map<String, String>> first = parse('115-1').events;
      final List<Map<String, String>> second = parse('115-2').events;
      expect(first.first['start'], startsWith('2026-'));
      expect(first.last['end'], startsWith('2027-01'));
      expect(second.first['start'], startsWith('2027-'));
      expect(second.last['end'], startsWith('2027-'));
    });

    test('entries come out in date order', () {
      final List<Map<String, String>> events = parse('115-1').events;
      for (int i = 1; i < events.length; i++) {
        expect(
          events[i - 1]['start']!.compareTo(events[i]['start']!) <= 0,
          isTrue,
        );
      }
    });

    test('the output is what the app already knows how to read', () {
      final String raw = jsonEncode(parse('115-1').events);
      expect(jsonDecode(raw), isA<List<dynamic>>());
      final Map<String, dynamic> first =
          (jsonDecode(raw) as List<dynamic>).first as Map<String, dynamic>;
      expect(first.keys, containsAll(<String>['start', 'end', 'title']));
    });

    test('rejects a document that is not a calendar', () {
      expect(parseCalendarDocument(Uint8List.fromList(<int>[1, 2, 3])), isNull);
    });

    test('survives the trip through a background isolate', () async {
      // How it is actually called: the result has to cross an isolate
      // boundary, which a direct call would never exercise.
      final Uint8List bytes =
          File('assets_test/calendar/115-1.pdf').readAsBytesSync();
      final ParsedCalendar? parsed =
          await compute(parseCalendarDocument, bytes);
      expect(parsed?.code, parse('115-1').code);
      expect(parsed?.events, parse('115-1').events);
    });
  });

  group('window selection', () {
    late Map<String, List<Map<String, String>>> parsed;

    setUpAll(() {
      parsed = <String, List<Map<String, String>>>{
        '115-1': parse('115-1').events,
        '115-2': parse('115-2').events,
      };
    });

    test('picks the semester today falls in', () {
      expect(pickCurrentSemester(parsed, DateTime(2026, 10, 15)), '115-1');
      expect(pickCurrentSemester(parsed, DateTime(2027, 3, 15)), '115-2');
    });

    test('before any of them, picks the one that starts first', () {
      expect(pickCurrentSemester(parsed, DateTime(2020, 6, 15)), '115-1');
    });

    test('a missing neighbour just shortens the window', () {
      expect(semestersAround(parsed.keys, '115-1'), <String>['115-1', '115-2']);
      expect(semestersAround(parsed.keys, '115-2'), <String>['115-1', '115-2']);
      expect(
        semestersAround(<String>['114-2', '115-1', '115-2'], '115-1'),
        <String>['114-2', '115-1', '115-2'],
      );
    });

    test('merging drops entries the registry printed on both sheets', () {
      final List<Map<String, String>> merged =
          mergeSemesters(parsed, <String>['115-1', '115-2']);
      final Set<String> keys = merged
          .map((Map<String, String> e) =>
              '${e['start']} ${e['end']} ${e['title']}')
          .toSet();
      expect(keys.length, merged.length);
      expect(
        merged.length,
        lessThanOrEqualTo(parsed['115-1']!.length + parsed['115-2']!.length),
      );
    });
  });

  group('parseCsv', () {
    test('reads the sheet the registry publishes', () {
      const String csv = 'Group,Subgroup,Filename,URL\n'
          '115學年度,中文版,115學年度第2學期行事曆 (NEW!!),/var/file/cal115-2.pdf\n'
          '115學年度,英文版,Calendar,/var/file/en115-2.pdf\n';
      final List<({String name, String url})> listed = listCalendarPdfs(csv);
      expect(listed.length, 1);
      expect(listed.first.url, 'https://acad.nkust.edu.tw/var/file/cal115-2.pdf');
    });

    test('keeps a quoted field containing a comma in one piece', () {
      const String csv = 'Group,Subgroup,Filename,URL\n'
          '115,中文版,"行事曆,修訂版",/a.pdf\n';
      expect(listCalendarPdfs(csv).first.name, '行事曆,修訂版');
    });

    test('ignores rows that are not a Chinese PDF', () {
      const String csv = 'Group,Subgroup,Filename,URL\n'
          '115,中文版,doc,/a.docx\n'
          '115,英文版,pdf,/b.pdf\n';
      expect(listCalendarPdfs(csv), isEmpty);
    });

    test('refuses to be pointed anywhere but the registry', () {
      // The sheet is published by the school, not owned by the app: a row
      // naming somewhere else must not become a request from every install.
      const String csv = 'Group,Subgroup,Filename,URL\n'
          '115,中文版,a,https://evil.example/cal.pdf\n'
          '115,中文版,b,http://acad.nkust.edu.tw/plain.pdf\n'
          '115,中文版,c,https://acad.nkust.edu.tw.evil.example/x.pdf\n'
          '115,中文版,d,//evil.example/protocol-relative.pdf\n'
          // Credentials before an @ make the real host the one after it.
          '115,中文版,e,https://acad.nkust.edu.tw@evil.example/x.pdf\n'
          '115,中文版,f,https://acad.nkust.edu.tw:8080/x.pdf\n';
      expect(listCalendarPdfs(csv), isEmpty);
    });

    test('keeps an absolute url that is already the registry', () {
      const String csv = 'Group,Subgroup,Filename,URL\n'
          '115,中文版,a,https://acad.nkust.edu.tw/var/file/cal.pdf\n';
      expect(listCalendarPdfs(csv).single.url,
          'https://acad.nkust.edu.tw/var/file/cal.pdf');
    });
  });

  group('wanted', () {
    List<CalendarListing> listing(List<String> names) => <CalendarListing>[
          for (final String name in names)
            (name: name, url: 'https://$calendarHost/$name.pdf'),
        ];

    test('downloads only the window, not the whole archive', () {
      final List<CalendarListing> all = listing(<String>[
        '113學年度第1學期行事曆',
        '113學年度第2學期行事曆',
        '114學年度第1學期行事曆',
        '114學年度第2學期行事曆',
        '115學年度第1學期行事曆',
        '115學年度第2學期行事曆',
      ]);
      final List<String> picked = wanted(all, DateTime(2026, 10, 15))
          .map((CalendarListing e) => e.name)
          .toList();
      expect(picked, <String>[
        '114學年度第2學期行事曆',
        '115學年度第1學期行事曆',
        '115學年度第2學期行事曆',
      ]);
    });

    test('falls back to a capped slice when a name does not read', () {
      final List<CalendarListing> all =
          listing(<String>['一', '二', '三', '四', '五', '六']);
      expect(wanted(all, DateTime(2026, 10, 15)).length, maxDocuments);
    });
  });
}
