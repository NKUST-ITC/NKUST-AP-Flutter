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
  var inputDoc = document.getElementsByTagName("input");
  for (int i = 0; i < inputDoc.length; i++) {
    if (inputDoc[i].attributes["name"] != null) {
      hiddenData[inputDoc[i].attributes["name"]] =
          inputDoc[i].attributes["value"] ?? "";
    }
  }
  return hiddenData;
}

Map<String, dynamic> leaveQueryParser(String html) {
  var document = parse(html);
  List<Map<String, dynamic>> dataList = [];
  List<String> timeCodeList = [];
  var tableDom = document.getElementsByClassName("mGridDetail");
  if (tableDom.length < 1) {
    return {"data": [], "timeCodes": []};
  }
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

Map<String, dynamic> leaveSubmitInfoParser(String html) {
  // Leave parser haven't any check, check is unnecessary on this system.
  var document = parse(html);

  //TimeCode generate part.
  List<String> timeCodeList = [];
  var _timeCode = document
      .getElementsByClassName("mGrid")[0]
      .getElementsByTagName("tr")[0]
      .getElementsByTagName("th");
  if (_timeCode.length > 5) {
    for (int i = 3; i < _timeCode.length; i++) {
      timeCodeList.add(_timeCode[i].text);
    }
  }

  //LeaveType generate part.
  List<Map<String, String>> leaveType = [];

  var _leaveType = document.getElementsByClassName("aspNetDisabled");
  if (_leaveType.length > 1) {
    for (int i = 1; i < _leaveType.length; i++) {
      final labels = _leaveType[i].getElementsByTagName("label");
      final inputs = _leaveType[i].getElementsByTagName("input");
      if (labels.length == 0) continue;
      leaveType.add({
        "title": labels[0].text,
        "id": inputs[0].attributes["value"].toString(),
      });
    }

    Map<String, dynamic> tutorData;
    //Get default tutor
    var _toturSelect = document
        .getElementById("ContentPlaceHolder1_CK001_ddlTeach")
        .getElementsByTagName("option");
    for (int i = 1; i < _toturSelect.length; i++) {
      if (_toturSelect[i].attributes["selected"] != null) {
        tutorData = {
          "name": _toturSelect[i].text,
          "id": _toturSelect[i].attributes["value"],
        };
      }
    }

    return {
      "tutor": tutorData,
      "type": leaveType,
      "timeCodes": timeCodeList,
    };
  }
  return null;
}
