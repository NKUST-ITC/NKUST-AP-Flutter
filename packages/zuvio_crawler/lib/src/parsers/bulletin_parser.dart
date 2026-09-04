import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

import 'package:zuvio_crawler/src/models/models.dart';

/// Parses the 公告 cards of `/student5/irs/course/<courseId>`.
///
/// Each card:
/// ```html
/// <div class="i-f-f-f-b-top-box">
///   <div class="i-f-f-f-b-t-b-title">王大瑾</div>
///   <div class="i-f-f-f-b-t-b-date">2021-09-07</div>
/// </div>
/// <div class="i-f-f-f-b-middle-box">
///   <div class="i-f-f-f-b-m-b-title">修課注意事項</div>
///   <div class="i-f-f-f-b-m-b-content">…<br/>…</div>
/// </div>
/// ```
List<ZuvioBulletin> parseBulletins(String html) {
  final Document doc = parse(html);
  final List<ZuvioBulletin> out = <ZuvioBulletin>[];
  for (final Element top in doc.querySelectorAll('.i-f-f-f-b-top-box')) {
    final Element? card = top.parent;
    final String author =
        top.querySelector('.i-f-f-f-b-t-b-title')?.text.trim() ?? '';
    final DateTime? date = DateTime.tryParse(
      (top.querySelector('.i-f-f-f-b-t-b-date')?.text.trim() ?? '')
          .replaceFirst(' ', 'T'),
    );
    final Element? middle = card?.querySelector('.i-f-f-f-b-middle-box');
    final String title =
        middle?.querySelector('.i-f-f-f-b-m-b-title')?.text.trim() ?? '';
    final Element? contentEl =
        middle?.querySelector('.i-f-f-f-b-m-b-content');
    final String content = _flattenContent(contentEl);
    if (title.isEmpty && content.isEmpty) continue;
    out.add(
      ZuvioBulletin(
        author: author,
        title: title,
        content: content,
        date: date,
      ),
    );
  }
  return out;
}

String _flattenContent(Element? el) {
  if (el == null) return '';
  final String withBreaks = el.innerHtml
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
  return parse(withBreaks).body?.text.trim() ?? el.text.trim();
}
