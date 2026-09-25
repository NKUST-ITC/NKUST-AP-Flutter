import 'package:test/test.dart';
import 'package:zuvio_crawler/src/models/models.dart';
import 'package:zuvio_crawler/src/parsers/feedback_parser.dart';

import 'support.dart';

void main() {
  group('parseFeedbackThread', () {
    test('reads the question and the teacher reply', () {
      final ZuvioFeedbackThread? t =
          parseFeedbackThread(fixture('feedback_thread.html'));
      expect(t, isNotNull);
      expect(t!.question, '老師這題的推導可以再說明一次嗎？');
      expect(t.questionAt, DateTime.parse('2025-03-05T14:20'));
      expect(t.reply, '下次上課我會補充完整推導。');
      expect(t.replyAuthor, '示範老師甲');
      expect(t.replyAt, DateTime.parse('2025-03-05T18:03'));
    });

    test('leaves reply fields null when the teacher has not answered', () {
      final ZuvioFeedbackThread t =
          parseFeedbackThread(fixture('feedback_thread_no_reply.html'))!;
      expect(t.question, '請問期中考範圍到第幾章？');
      expect(t.reply, isNull);
      expect(t.replyAuthor, isNull);
      expect(t.replyAt, isNull);
    });
  });

  group('parseFeedbackList', () {
    test('marks a message replied only when reply_id is set', () {
      final List<ZuvioFeedbackMessage> list =
          parseFeedbackList(jsonFixture('feedback_list.json'));
      expect(list, hasLength(2));
      expect(list[0].id, '800001');
      expect(list[0].isMine, isTrue);
      expect(list[0].replied, isTrue);
      expect(list[0].createdAt, DateTime.parse('2025-03-05T14:20'));
      expect(list[1].replied, isFalse);
    });

    test('returns an empty list when the key is missing', () {
      expect(parseFeedbackList(<String, dynamic>{}), isEmpty);
    });
  });
}
