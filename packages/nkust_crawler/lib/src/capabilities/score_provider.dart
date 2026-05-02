import 'package:ap_common_core/ap_common_core.dart';

/// Capability interface for fetching student scores.
///
/// Implemented by: [WebApHelper], [StdsysHelper]
abstract class ScoreProvider {
  Future<ScoreData?> getScores({required String year, required String semester});
}
