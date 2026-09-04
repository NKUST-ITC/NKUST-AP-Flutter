import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

import 'package:zuvio_crawler/src/models/models.dart';

/// Parses `/student5/irs/feedback/<id>` — one 私訊老師 thread: the
/// student's `.i-f-f-feedback-box` message and, when present, the
/// teacher's `.i-f-f-feedback-reply-box`.
ZuvioFeedbackThread? parseFeedbackThread(String html) {
  final Document doc = parse(html);
  final Element? q = doc.querySelector('.i-f-f-feedback-box');
  if (q == null) return null;

  String pick(Element? scope, String sel) =>
      scope?.querySelector(sel)?.text.trim() ?? '';
  DateTime? date(String raw) =>
      DateTime.tryParse(raw.replaceFirst(' ', 'T'));

  final Element? r = doc.querySelector('.i-f-f-feedback-reply-box');
  return ZuvioFeedbackThread(
    question: pick(q, '.i-f-f-f-b-m-b-text').isNotEmpty
        ? pick(q, '.i-f-f-f-b-m-b-text')
        : pick(q, '[class*=m-b-text]'),
    questionAt: date(pick(q, '.i-f-f-f-b-t-b-date')),
    reply: r == null
        ? null
        : (pick(r, '.i-f-f-f-r-b-m-b-text').isNotEmpty
            ? pick(r, '.i-f-f-f-r-b-m-b-text')
            : pick(r, '[class*=m-b-text]')),
    replyAuthor: r == null ? null : pick(r, '.i-f-f-f-r-b-t-b-title'),
    replyAt: r == null ? null : date(pick(r, '.i-f-f-f-r-b-t-b-date')),
  );
}

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
