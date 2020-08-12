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
