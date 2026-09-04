
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

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
      // [date, department]. Reading first/last is correct for both.
      info['date'] = _clean(dTxtList.first.text);
      info['department'] = _clean(dTxtList.last.text);
    }
    if (element.getElementsByTagName('a').isNotEmpty) {
      info['index'] = baseIndex;
      baseIndex++;
      info['title'] =
          element.getElementsByTagName('a')[0].text.replaceAll('%置頂%', '').trim();
      temp['link'] = element.getElementsByTagName('a')[0].attributes['href'];
      temp['info'] = info;
      dataList.add(temp);
    }
  }
  return dataList;
}

String _clean(String raw) =>
    raw.replaceAll('	', '').replaceAll('\n', '').trim();
