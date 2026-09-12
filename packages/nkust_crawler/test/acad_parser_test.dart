import 'dart:io';

import 'package:nkust_crawler/src/parsers/nkust_parser.dart';
import 'package:test/test.dart';

String _fixture(String name) =>
    File('test/fixtures/$name').readAsStringSync();

void main() {
  group('acadParser — pre-revamp layout [date, department]', () {
    late final List<Map<String, dynamic>> rows =
        acadParser(html: _fixture('acad_old.html'), baseIndex: 0);

    test('reads date, department, title and link', () {
      expect(rows, hasLength(2));
      expect(rows[0]['info']['date'], '2024/03/15');
      expect(rows[0]['info']['department'], '教務處');
      expect(rows[0]['info']['title'], '113學年度第二學期選課公告');
      expect(rows[0]['link'], '/news/001');
      expect(rows[1]['info']['department'], '學務處');
      expect(rows[1]['link'], '/news/002');
    });

    test('numbers rows from baseIndex', () {
      final List<Map<String, dynamic>> shifted =
          acadParser(html: _fixture('acad_old.html'), baseIndex: 10);
      expect(shifted[0]['info']['index'], 10);
      expect(shifted[1]['info']['index'], 11);
    });
  });

  group('acadParser — revamped layout [date, title, department]', () {
    late final List<Map<String, dynamic>> rows =
        acadParser(html: _fixture('acad_new.html'), baseIndex: 0);

    test('department comes from the last cell, not the title', () {
      expect(rows, hasLength(2));
      expect(rows[0]['info']['department'], '課務組');
      expect(
        rows[0]['info']['title'],
        isNot(contains('課務組')),
      );
    });

    test('trims the padded date', () {
      expect(rows[0]['info']['date'], '2026-05-21');
    });

    test('strips the %置頂% marker and records pinned state', () {
      expect(rows[0]['info']['title'],
          '【選課訊息】115-1學期各學制初選、加退選重要通知，請查照。');
      expect(rows[0]['info']['pinned'], isTrue);
      expect(rows[1]['info']['pinned'], isFalse);
    });

    test('drops a row whose <a> has no usable href', () {
      // acad_new.html has a third <tr> with `<a href="">` — it must not
      // appear (a link-less notification is unopenable and its empty
      // href would also collapse dedup keys downstream).
      expect(
        rows.every(
          (Map<String, dynamic> r) => (r['link'] as String).isNotEmpty,
        ),
        isTrue,
      );
    });
  });

  test('a row with a single .d-txt leaves department empty, not the date',
      () {
    const String html = '''
      <table><tr>
        <td><div class="d-txt">2026-09-01</div></td>
        <td><a href="/x">only one cell</a></td>
      </tr></table>
    ''';
    final List<Map<String, dynamic>> rows =
        acadParser(html: html, baseIndex: 0);
    expect(rows, hasLength(1));
    expect(rows[0]['info']['date'], '2026-09-01');
    expect(rows[0]['info']['department'], '');
  });
}
