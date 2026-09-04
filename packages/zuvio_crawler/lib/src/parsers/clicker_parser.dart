import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

import 'package:zuvio_crawler/src/models/models.dart';

/// Parses the 題目列表 hub (`/student5/irs/clickers/<courseId>`).
///
/// When nothing is playing the page shows「目前沒有播放任何題目」and this
/// returns null. A live question renders inside `#irs-clicker-question`
/// (or `[data-question-id]`) with its name and answered state.
ZuvioClickerQuestion? parseLiveClicker(String html) {
  if (html.contains('目前沒有播放任何題目') ||
      html.contains('目前沒有播放題目')) {
    return null;
  }
  final Document doc = parse(html);
  final Element? node = doc.querySelector('#irs-clicker-question') ??
      doc.querySelector('.i-c-c-question') ??
      doc.querySelector('[data-question-id]');
  if (node == null) return null;

  final String id = node.attributes['data-question-id'] ?? '';
  final String name = (node.querySelector('.i-c-c-q-name')?.text ??
          node.querySelector('.question-name')?.text ??
          node.text)
      .trim();
  if (name.isEmpty) return null;

  return ZuvioClickerQuestion(
    id: id,
    name: name,
    isLive: true,
    answered: html.contains('i-c-c-q-answered') ||
        html.contains('作答資料處理中'),
  );
}
