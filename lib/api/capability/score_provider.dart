import 'package:ap_common/ap_common.dart';

/// Capability interface for fetching student scores.
///
/// Implemented by: [WebApHelper], [StdsysHelper], [MobileNkustHelper]
abstract class ScoreProvider {
  Future<ScoreData?> getScores({required String year, required String semester});
}
