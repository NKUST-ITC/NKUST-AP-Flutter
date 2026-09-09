import 'package:test/test.dart';
import 'package:zuvio_crawler/src/models/models.dart';
import 'package:zuvio_crawler/src/parsers/course_info_parser.dart';

import 'support.dart';

void main() {
  ZuvioInfoSection sectionNamed(ZuvioCourseInfo info, String title) =>
      info.sections.firstWhere((ZuvioInfoSection s) => s.title == title);

  String valueOf(ZuvioInfoSection s, String label) =>
      s.rows.firstWhere((ZuvioInfoRow r) => r.label == label).value;

  test('reads simple label/value rows', () {
    final ZuvioCourseInfo info =
        parseCourseInfo(fixture('course_info.html'));
    final ZuvioInfoSection basic = sectionNamed(info, '學期 113-2');
    expect(valueOf(basic, '授課教師'), '示範老師甲');
    expect(valueOf(basic, '修課人數'), '48');
  });

  test('reads grid rows pairing header cells with value cells', () {
    final ZuvioInfoSection perf = sectionNamed(
      parseCourseInfo(fixture('course_info.html')),
      '答題表現',
    );
    expect(valueOf(perf, '題目回答率'), '61%');
    expect(valueOf(perf, '正確題數'), '27/30');
  });

  test('disambiguates every 全班排名 row by its metric or section', () {
    final ZuvioCourseInfo info =
        parseCourseInfo(fixture('course_info.html'));
    final List<String> labels = <String>[
      for (final ZuvioInfoSection s in info.sections)
        for (final ZuvioInfoRow r in s.rows) r.label,
    ];
    expect(labels, contains('回答題數排名'));
    expect(labels, contains('正確率排名'));
    expect(labels, contains('出席排名'));
    expect(labels, isNot(contains('全班排名')));

    final ZuvioInfoSection perf = sectionNamed(info, '答題表現');
    expect(valueOf(perf, '回答題數排名'), '5/48');
    expect(valueOf(perf, '正確率排名'), '3/48');
    expect(valueOf(sectionNamed(info, '出席表現'), '出席排名'), '8/48');
  });
}
