import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' show parse;

List<Map<String, dynamic>> acadParser({
  @required String html,
  @required int baseIndex,
}) {
  List<Map<String, dynamic>> dataList = [];
  var document = parse(html);
  var tdElements = document.getElementsByTagName("tr");
  tdElements.forEach((element) {
    //find date
    Map<String, dynamic> temp = {};
    Map<String, dynamic> info = {};

    if (element.getElementsByClassName("d-txt").length > 0) {
      info["date"] = element
          .getElementsByClassName("d-txt")[0]
          .text
          .replaceAll("	", "")
          .replaceAll("\n", "");
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
