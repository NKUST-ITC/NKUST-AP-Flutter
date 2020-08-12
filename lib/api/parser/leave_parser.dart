import 'package:html/parser.dart' show parse;

Map<String, dynamic> hiddenInputGet(String html) {
  var document = parse(html);
  Map<String, dynamic> hiddenData = {};
  var inputDom = document.getElementsByTagName("input");
  for (int i = 0; i < inputDom.length; i++) {
    if (inputDom[i].attributes["type"] == "hidden" &&
        inputDom[i].attributes["name"] != null &&
        inputDom[i].attributes["name"].substring(0, 1) == "_") {
      hiddenData[inputDom[i].attributes["name"]] =
          inputDom[i].attributes["value"] ?? "";
    }
  }
  return hiddenData;
}

Map<String, dynamic> allInputValueParser(String html) {
  var document = parse(html);
  Map<String, dynamic> hiddenData = {};
  var input_dom = document.getElementsByTagName("input");
  for (int i = 0; i < input_dom.length; i++) {
    if (input_dom[i].attributes["name"] != null) {
      hiddenData[input_dom[i].attributes["name"]] =
          input_dom[i].attributes["value"] ?? "";
    }
  }
  return hiddenData;
}

Map<String, dynamic> leaveQueryParser(String html) {
  var document = parse(html);
  List<Map<String, dynamic>> dataList = [];
  List<String> timeCodeList = [];
  var tableDom = document.getElementsByClassName("mGridDetail");
  if (tableDom.length < 1) {}
  var trDom = tableDom[0].getElementsByTagName("tr");

  //make timeCode list
  var th = trDom[0].getElementsByTagName("th");
  for (int i = 4; i < th.length; i++) {
    timeCodeList.add(th[i].text);
  }

  for (int i = 1; i < trDom.length; i++) {
    Map<String, dynamic> temp = {};

    var td = trDom[i].getElementsByTagName("td");
    temp["leaveSheetId"] = td[1].text ?? "";
    temp["date"] = td[2].text ?? "";
    temp["instructorsComment"] = td[3].text ?? "";
    temp["sections"] = [];
    for (int e = 4; e < td.length; e++) {
      if (td[e].text == "　") {
        continue;
      }
      temp["sections"].add(
        {
          "section": timeCodeList[e - 4],
          "reason": td[e].text,
        },
      );
    }
    dataList.add(temp);
  }
  return {"data": dataList, "timeCodes": timeCodeList};
}
