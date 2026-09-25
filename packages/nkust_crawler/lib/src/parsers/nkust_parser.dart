
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

/// Whitespace-tolerant match for the `%置頂%` pin marker the acad list
/// appends to a title's text.
final RegExp _pinnedMarker = RegExp(r'%\s*置頂\s*%');

List<Map<String, dynamic>> acadParser({
  required String? html,
  required int baseIndex,
}) {
  final List<Map<String, dynamic>> dataList = <Map<String, dynamic>>[];
  final Document document = parse(html);
  final List<Element> tdElements = document.getElementsByTagName('tr');
  for (final Element element in tdElements) {
    //find date
    final Map<String, dynamic> temp = <String, dynamic>{};
    final Map<String, dynamic> info = <String, dynamic>{};
    final List<Element> dTxtList = element.getElementsByClassName('d-txt');
    if (dTxtList.isNotEmpty) {
      // The revamped acad list wraps the title link in its own `.d-txt`,
      // so a row now has [date, title, department]; the plain list keeps
      // [date, department]. `first`/`last` is correct for both, but they
      // collapse to the same element when a row only carries one, so
      // only fill `department` when there are genuinely two or more.
      info['date'] = _clean(dTxtList.first.text);
      info['department'] =
          dTxtList.length >= 2 ? _clean(dTxtList.last.text) : '';
    }
    final List<Element> anchors = element.getElementsByTagName('a');
    final String? link =
        anchors.isEmpty ? null : anchors.first.attributes['href'];
    if (link != null && link.isNotEmpty) {
      info['index'] = baseIndex;
      baseIndex++;
      final String rawTitle = anchors.first.text.trim();
      info['pinned'] = _pinnedMarker.hasMatch(rawTitle);
      info['title'] = rawTitle.replaceAll(_pinnedMarker, '').trim();
      temp['link'] = link;
      temp['info'] = info;
      dataList.add(temp);
    }
  }
  return dataList;
}

String _clean(String raw) =>
    raw.replaceAll('	', '').replaceAll('\n', '').trim();
