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
    if (element.getElementsByClassName('d-txt').isNotEmpty) {
      info['date'] = dTxtList[0].text.replaceAll('	', '').replaceAll('\n', '');
      info['department'] =
          dTxtList[1].text.replaceAll('	', '').replaceAll('\n', '');
    }
    if (element.getElementsByTagName('a').isNotEmpty) {
      info['index'] = baseIndex;
      baseIndex++;
      info['title'] = element.getElementsByTagName('a')[0].attributes['title'];
      temp['link'] = element.getElementsByTagName('a')[0].attributes['href'];
      temp['info'] = info;
      dataList.add(temp);
    }
  }
  return dataList;
}
