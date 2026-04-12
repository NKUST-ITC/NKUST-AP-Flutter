import 'package:ap_common/ap_common.dart';

/// Capability interface for fetching course table data.
///
/// Implemented by: [WebApHelper], [StdsysHelper], [MobileNkustHelper]
abstract class CourseProvider {
  Future<CourseData> getCourseTable({String? year, String? semester});
}
