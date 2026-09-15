import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nkust_ap/utils/academic_calendar_parser.dart';
import 'package:nkust_ap/utils/academic_calendar_source.dart';

/// Reading the registry's own PDFs is the app's primary source, so these run
/// against the real documents rather than a hand-written sample: the thing
/// most likely to break is the school changing a layout, and only the real
/// file can catch that.
void main() {
  ParsedCalendar parse(String code) {
    final Uint8List bytes =
        File('assets_test/calendar/$code.pdf').readAsBytesSync();
    final ParsedCalendar? parsed = parseCalendarDocument(bytes);
    expect(parsed, isNotNull, reason: '$code.pdf no longer parses');
    return parsed!;
  }

  group('parseCalendarDocument', () {
    test('reads the semester off the heading', () {
      expect(parse('115-1').code, '115-1');
      expect(parse('115-2').code, '115-2');
    });

    test('matches what the CI script publishes', () {
      // The counts committed in assets/calendar, which the Python parser
      // produced from these same files. Different extractor, same answer.
      expect(parse('115-1').events.length, 44);
      expect(parse('115-2').events.length, 46);
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
      expect(merged.length, lessThanOrEqualTo(44 + 46));
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
  });
}
