import 'package:zuvio_crawler/src/models/models.dart';

/// Parses the `course/listStudentFullCourses` JSON payload.
///
/// ```json
/// { "status": true,
///   "semesters": [
///     { "semester_name": "113_2", "course_count": "1",
///       "courses": [
///         { "course_id": "1370956", "course_name": "安全程式設計",
///           "teacher_name": "孫勤昱", "semester_name": "113-2",
///           "pinned": false, "course_unread_num": "1" } ] } ] }
/// ```
List<ZuvioCourse> parseCourseList(Map<String, dynamic> json) {
  final List<dynamic> semesters =
      json['semesters'] as List<dynamic>? ?? <dynamic>[];
  final List<ZuvioCourse> out = <ZuvioCourse>[];
  for (final dynamic semester in semesters) {
    if (semester is! Map<String, dynamic>) continue;
    final List<dynamic> courses =
        semester['courses'] as List<dynamic>? ?? <dynamic>[];
    for (final dynamic course in courses) {
      if (course is Map<String, dynamic>) {
        out.add(ZuvioCourse.fromJson(course));
      }
    }
  }
  return out;
}
