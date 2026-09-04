import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

import 'package:zuvio_crawler/src/models/models.dart';

final RegExp _bulletinId = RegExp(r'irs_getBulletin\((\d+)\)');
final RegExp _saveToDisk =
    RegExp(r'''SaveToDisk\(\s*['"]([^'"]+)['"]\s*,\s*['"]([^'"]+)['"]''');

/// Parses the 公告 list of `/student5/irs/course/<courseId>/0`.
///
/// Each card is `<div class="i-f-f-forum-box" onclick="irs_getBulletin(id)">`
/// containing `.i-f-f-f-b-top-box` (author + date) and
/// `.i-f-f-f-b-middle-box` (title + preview). The full body and any
/// attachments only appear on the detail page.
List<ZuvioBulletin> parseBulletins(String html) {
  final Document doc = parse(html);
  final List<ZuvioBulletin> out = <ZuvioBulletin>[];
  for (final Element card in doc.querySelectorAll('.i-f-f-forum-box')) {
    final ZuvioBulletin? b = _card(card);
    if (b != null) out.add(b);
  }
  return out;
}

/// Parses `/student5/irs/bulletin/<bulletinId>` — the full announcement
/// plus the `公告附件` list, whose file boxes call
/// `SaveToDisk('<url>', '<filename>')`.
ZuvioBulletin? parseBulletinDetail(String html, {required String id}) {
  final Document doc = parse(html);
  final Element? card = doc.querySelector('.i-f-f-forum-box') ??
      doc.querySelector('.i-f-f-f-b-top-box')?.parent;
  if (card == null) return null;

  final ZuvioBulletin? base = _card(card, fallbackId: id);
  if (base == null) return null;

  final List<ZuvioAttachment> attachments = <ZuvioAttachment>[];
  for (final Element box
      in doc.querySelectorAll('.i-f-f-f-b-f-l-file-box')) {
    final RegExpMatch? m =
        _saveToDisk.firstMatch(box.attributes['onclick'] ?? '');
    if (m != null) {
      attachments.add(
        ZuvioAttachment(url: m.group(1)!, name: m.group(2)!),
      );
    }
  }

  return ZuvioBulletin(
    id: base.id,
    author: base.author,
    title: base.title,
    content: base.content,
    date: base.date,
    attachments: attachments,
  );
}

ZuvioBulletin? _card(Element card, {String fallbackId = ''}) {
  final RegExpMatch? idMatch =
      _bulletinId.firstMatch(card.attributes['onclick'] ?? '');
  final String id = idMatch?.group(1) ?? fallbackId;

  final Element? top = card.querySelector('.i-f-f-f-b-top-box');
  final Element? middle = card.querySelector('.i-f-f-f-b-middle-box');
  final String author =
      top?.querySelector('.i-f-f-f-b-t-b-title')?.text.trim() ?? '';
  final DateTime? date = DateTime.tryParse(
    (top?.querySelector('.i-f-f-f-b-t-b-date')?.text.trim() ?? '')
        .replaceFirst(' ', 'T'),
  );
  final String title =
      middle?.querySelector('.i-f-f-f-b-m-b-title')?.text.trim() ?? '';
  final Element? contentEl =
      middle?.querySelector('.i-f-f-f-b-m-b-content-text') ??
          middle?.querySelector('.i-f-f-f-b-m-b-content');
  final String content = _flatten(contentEl);

  if (id.isEmpty && title.isEmpty && content.isEmpty) return null;
  return ZuvioBulletin(
    id: id,
    author: author,
    title: title,
    content: content,
    date: date,
  );
}

String _flatten(Element? el) {
  if (el == null) return '';
  final String withBreaks = el.innerHtml
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
  return parse(withBreaks).body?.text.trim() ?? el.text.trim();
}
