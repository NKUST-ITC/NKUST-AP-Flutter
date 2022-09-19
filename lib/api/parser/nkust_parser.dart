import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

List<Map<String, dynamic>> acadParser({
  required String? html,
  required int baseIndex,
}) {
  List<Map<String, dynamic>> dataList = [];
  var document = parse(html);
  var tdElements = document.getElementsByTagName("tr");
  tdElements.forEach((element) {
    //find date
    Map<String, dynamic> temp = {};
    Map<String, dynamic> info = {};
    final List<Element> dTxtList = element.getElementsByClassName("d-txt");
    if (element.getElementsByClassName("d-txt").length > 0) {
      info["date"] = dTxtList[0].text.replaceAll("	", "").replaceAll("\n", "");
      info["department"] =
          dTxtList[1].text.replaceAll("	", "").replaceAll("\n", "");
    }
    if (element.getElementsByTagName("a").length > 0) {
      info["index"] = baseIndex;
      baseIndex++;
      info["title"] =
          (element.getElementsByTagName("a")[0].attributes["title"]);
      temp["link"] = (element.getElementsByTagName("a")[0].attributes["href"]);
      temp["info"] = info;
      dataList.add(temp);
    }
  });
  return dataList;
}
