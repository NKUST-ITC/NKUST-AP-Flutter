import 'package:test/test.dart';
import 'package:zuvio_crawler/src/models/models.dart';
import 'package:zuvio_crawler/src/parsers/course_parser.dart';

import 'support.dart';

void main() {
  test('flattens every semester into a single course list', () {
    final List<ZuvioCourse> courses =
        parseCourseList(jsonFixture('courses.json'));
    expect(courses, hasLength(3));
    expect(courses.map((ZuvioCourse c) => c.courseId),
        <String>['1000001', '1000002', '900003']);
  });

  test('maps course fields', () {
    final ZuvioCourse first =
        parseCourseList(jsonFixture('courses.json')).first;
    expect(first.courseName, '資料結構');
    expect(first.teacherName, '示範老師甲');
    expect(first.semesterName, '113-2');
    expect(first.pinned, isTrue);
    expect(first.unreadCount, 3);
  });

  test('tolerates a payload without semesters', () {
    expect(parseCourseList(<String, dynamic>{'status': true}), isEmpty);
  });
}
