import 'package:zuvio_crawler/src/models/models.dart';

/// Parses the `app_v2/getFeedbackList` payload:
/// `{ "feedbacks": [ { "content": "...", "created_at": "2023-11-29 11:53",
///    "reply_id": "...", "reply_status": "CHECKED" } ] }`.
List<ZuvioFeedbackMessage> parseFeedbackList(Map<String, dynamic> json) {
  final Object? raw = json['feedbacks'];
  if (raw is! List<dynamic>) return <ZuvioFeedbackMessage>[];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(ZuvioFeedbackMessage.fromJson)
      .toList();
}
