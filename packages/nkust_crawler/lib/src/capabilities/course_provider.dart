import 'package:ap_common_core/ap_common_core.dart';

/// Capability interface for fetching course table data.
///
/// Implemented by: [WebApHelper], [StdsysHelper]
abstract class CourseProvider {
  Future<CourseData> getCourseTable({String? year, String? semester});
}
