import 'package:ap_common/ap_common.dart';

/// Capability interface for fetching available semesters.
///
/// Implemented by: [WebApHelper], [StdsysHelper]
abstract class SemesterProvider {
  Future<SemesterData?> getSemesters();
}
