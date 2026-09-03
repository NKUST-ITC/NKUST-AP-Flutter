import 'package:ap_common_core/ap_common_core.dart';

/// Capability interface for fetching available semesters.
///
/// Implemented by: [WebApHelper], [StdsysHelper]
abstract class SemesterProvider {
  Future<SemesterData?> getSemesters();
}
