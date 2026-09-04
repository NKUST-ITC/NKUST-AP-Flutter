import 'package:test/test.dart';
import 'package:zuvio_crawler/src/models/models.dart';
import 'package:zuvio_crawler/src/parsers/question_parser.dart';

import 'support.dart';

void main() {
  group('parseQuestionList', () {
    test('reads id, type and text for every question box', () {
      final List<ZuvioQuestion> list =
          parseQuestionList(fixture('question_list.html'));
      expect(list, hasLength(3));
      expect(list[0].id, '14000001');
      expect(list[0].type, '單選題');
      expect(list[0].text, '堆疊的操作原則為何？');
    });

    test('maps the result mini-box colour', () {
      final List<ZuvioQuestion> list =
          parseQuestionList(fixture('question_list.html'));
      expect(list[0].result, ZuvioQuestionResult.correct);
      expect(list[1].result, ZuvioQuestionResult.wrong);
      expect(list[2].result, ZuvioQuestionResult.submitted);
    });
  });

  group('parseQuestionDetail - single choice', () {
    test('flags the selected wrong option and the correct option', () {
      final ZuvioQuestionDetail d =
          parseQuestionDetail(fixture('question_single.html'))!;
      expect(d.kind, ZuvioQuestionKind.single);
      expect(d.text, '堆疊的操作原則為何？');
      expect(d.result, ZuvioQuestionResult.wrong);
      expect(d.options, hasLength(3));

      final ZuvioQuestionOption picked =
          d.options.firstWhere((ZuvioQuestionOption o) => o.text == '隨機存取');
      expect(picked.isSelected, isTrue);
      expect(picked.isCorrect, isFalse);

      final ZuvioQuestionOption answer =
          d.options.firstWhere((ZuvioQuestionOption o) => o.text == 'LIFO');
      expect(answer.isCorrect, isTrue);
      expect(answer.isSelected, isFalse);
    });
  });

  group('parseQuestionDetail - multiple choice', () {
    test('a picked correct option is both selected and correct', () {
      final ZuvioQuestionDetail d =
          parseQuestionDetail(fixture('question_multiple.html'))!;
      expect(d.kind, ZuvioQuestionKind.multiple);
      expect(d.result, ZuvioQuestionResult.correct);

      final ZuvioQuestionOption picked =
          d.options.firstWhere((ZuvioQuestionOption o) => o.text == '陣列');
      expect(picked.isSelected, isTrue);
      expect(picked.isCorrect, isTrue);

      final ZuvioQuestionOption other =
          d.options.firstWhere((ZuvioQuestionOption o) => o.text == '佇列');
      expect(other.isCorrect, isTrue);
      expect(other.isSelected, isFalse);
    });
  });

  group('parseQuestionDetail - essay', () {
    test('reads the disabled textarea answer and marks it submitted', () {
      final ZuvioQuestionDetail d =
          parseQuestionDetail(fixture('question_essay.html'))!;
      expect(d.kind, ZuvioQuestionKind.essay);
      expect(d.result, ZuvioQuestionResult.submitted);
      expect(d.options, isEmpty);
      expect(d.essayAnswer, startsWith('遞迴透過函式自我呼叫'));
    });
  });
}
