import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

import 'package:zuvio_crawler/src/models/models.dart';

final RegExp _questionId = RegExp(r'irs_question\((\d+)\)');

ZuvioQuestionResult _result(String miniText, {bool essay = false}) {
  final String t = miniText.trim();
  if (t.contains('正確')) return ZuvioQuestionResult.correct;
  if (t.contains('錯誤') || t.contains('未達')) {
    return ZuvioQuestionResult.wrong;
  }
  return essay
      ? ZuvioQuestionResult.submitted
      : ZuvioQuestionResult.unanswered;
}

ZuvioQuestionResult _listResult(String miniClass, {bool essay = false}) {
  if (miniClass.contains('green')) return ZuvioQuestionResult.correct;
  if (miniClass.contains('red') || miniClass.contains('gray')) {
    return ZuvioQuestionResult.wrong;
  }
  return essay
      ? ZuvioQuestionResult.submitted
      : ZuvioQuestionResult.unanswered;
}

Element? _byClass(Element scope, String needle) {
  for (final Element e in scope.querySelectorAll('div')) {
    if (e.className.contains(needle)) return e;
  }
  return null;
}

/// Parses `/student5/irs/questions/<courseId>/<folderId>` — the question
/// list for one history folder.
List<ZuvioQuestion> parseQuestionList(String html) {
  final Document doc = parse(html);
  final List<ZuvioQuestion> out = <ZuvioQuestion>[];
  for (final Element box in doc.querySelectorAll('.i-c-l-q-question-box')) {
    final RegExpMatch? m =
        _questionId.firstMatch(box.attributes['onclick'] ?? '');
    if (m == null) continue;
    final String type =
        box.querySelector('.i-c-l-q-q-b-t-t-b-text')?.text.trim() ?? '';
    final String text =
        box.querySelector('.i-c-l-q-q-b-t-description')?.text.trim() ?? '';
    final Element? mini = _byClass(box, 'mini-box');
    out.add(
      ZuvioQuestion(
        id: m.group(1)!,
        type: type,
        text: text,
        result: _listResult(
          mini?.className ?? '',
          essay: type.contains('問答'),
        ),
      ),
    );
  }
  return out;
}

/// Parses `/student5/irs/question/<questionId>`.
///
/// `.i-a-c-q-t-question-box` carries `data-question-type` (`essay` /
/// `choice(s)`). Essay → the student's answer is the disabled
/// `<textarea>`. Choices → per `.option-box`:
///   `_click`     → student picked it, and it was right
///   `_uncorrect` → student picked it, and it was wrong
///   child `.o-b-correct` div → this option is a correct answer
/// package:html's `element.classes` only splits on spaces while Zuvio
/// pads the attribute with newlines/tabs, so class checks go through the
/// raw `className` string.
ZuvioQuestionDetail? parseQuestionDetail(String html) {
  final Document doc = parse(html);
  final Element? box = _byClass(doc.documentElement!, 'i-a-c-q-t-question-box');
  if (box == null) return null;

  final String type = _byClass(box, 'i-a-c-q-t-q-b-top-box')?.text.trim() ?? '';
  final String text =
      box.querySelector('.i-a-c-q-t-q-b-m-b-description')?.text.trim() ?? '';
  final String dataType =
      box.attributes['data-question-type']?.trim() ?? '';
  final Element? mini =
      _byClass(doc.documentElement!, 'i-a-c-q-t-m-b-a-mini-box');
  final String miniText = mini?.text ?? '';

  if (dataType == 'essay' || type.contains('問答')) {
    final String? answer =
        box.querySelector('.i-a-c-q-t-q-b-b-b-textareas textarea')?.text;
    return ZuvioQuestionDetail(
      type: type.isEmpty ? '問答題' : type,
      kind: ZuvioQuestionKind.essay,
      text: text,
      result: _result(miniText, essay: true),
      options: const <ZuvioQuestionOption>[],
      essayAnswer: answer?.trim(),
    );
  }

  final List<ZuvioQuestionOption> options = <ZuvioQuestionOption>[];
  for (final Element opt in box.querySelectorAll('div')) {
    final String cn = opt.className;
    if (!cn.contains('i-a-c-q-t-q-b-b-b-option-box')) continue;
    final bool clicked = cn.contains('_click');
    final bool uncorrect = cn.contains('_uncorrect');
    options.add(
      ZuvioQuestionOption(
        order: opt
                .querySelector('.i-a-c-q-t-q-b-b-b-o-b-display-order')
                ?.text
                .trim() ??
            '',
        text: opt
                .querySelector('.i-a-c-q-t-q-b-b-b-o-b-label')
                ?.text
                .trim() ??
            '',
        isCorrect:
            opt.querySelector('.i-a-c-q-t-q-b-b-b-o-b-correct') != null ||
                clicked,
        isSelected: clicked || uncorrect,
      ),
    );
  }

  return ZuvioQuestionDetail(
    type: type,
    kind: type.contains('多選')
        ? ZuvioQuestionKind.multiple
        : ZuvioQuestionKind.single,
    text: text,
    result: _result(miniText),
    options: options,
  );
}
