import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

Map<String?, dynamic> hiddenInputGet(String? html, {bool? removeTdElement}) {
  String? rawHtml = html;
  if (removeTdElement == true) {
    const String firstMatchString =
        '<td width="40px" nowrap="nowrap" align="left">';
    const String lastMatchString = '</td>';
    int startIndex = rawHtml!.indexOf(firstMatchString);
    while (startIndex > -1) {
      rawHtml = html!.substring(0, startIndex) +
          html.substring(
            html.indexOf(lastMatchString, startIndex) + lastMatchString.length,
          );
      startIndex = html.indexOf(firstMatchString);
    }
  }

  final Document document = parse(html);
  final Map<String?, dynamic> hiddenData = <String?, dynamic>{};
  final List<Element> inputDom = document.getElementsByTagName('input');
  for (int i = 0; i < inputDom.length; i++) {
    if (inputDom[i].attributes['type'] == 'hidden' &&
        inputDom[i].attributes['name'] != null &&
        inputDom[i].attributes['name']!.substring(0, 1) == '_') {
      hiddenData[inputDom[i].attributes['name']] =
          inputDom[i].attributes['value'] ?? '';
    }
  }
  return hiddenData;
}

Map<String?, dynamic> allInputValueParser(String? html) {
  final Document document = parse(html);
  final Map<String?, dynamic> hiddenData = <String?, dynamic>{};
  final List<Element> inputDoc = document.getElementsByTagName('input');
  for (int i = 0; i < inputDoc.length; i++) {
    if (inputDoc[i].attributes['name'] != null) {
      hiddenData[inputDoc[i].attributes['name']] =
          inputDoc[i].attributes['value'] ?? '';
    }
  }
  return hiddenData;
}

Map<String, dynamic> leaveQueryParser(String? html) {
  final Document document = parse(html);
  final List<Map<String, dynamic>> dataList = <Map<String, dynamic>>[];
  final List<String> timeCodeList = <String>[];
  final List<Element> tableDom = document.getElementsByClassName('mGridDetail');
  if (tableDom.isEmpty) {
    return <String, dynamic>{
      'data': <Map<String, dynamic>>[],
      'timeCodes': <String>[]
    };
  }
  final List<Element> trDom = tableDom[0].getElementsByTagName('tr');

  //make timeCode list
  final List<Element> th = trDom[0].getElementsByTagName('th');
  for (int i = 4; i < th.length; i++) {
    timeCodeList.add(th[i].text);
  }

  for (int i = 1; i < trDom.length; i++) {
    final Map<String, dynamic> temp = <String, dynamic>{};

    final List<Element> td = trDom[i].getElementsByTagName('td');
    temp['leaveSheetId'] = td[1].text;
    temp['date'] = td[2].text;
    temp['instructorsComment'] = td[3].text;
    temp['sections'] = <Map<String, dynamic>>[];
    for (int e = 4; e < td.length; e++) {
      if (td[e].text == '　') {
        continue;
      }
      (temp['sections'] as List<dynamic>).add(
        <String, dynamic>{
          'section': timeCodeList[e - 4],
          'reason': td[e].text,
        },
      );
    }
    dataList.add(temp);
  }
  return <String, dynamic>{
    'data': dataList,
    'timeCodes': timeCodeList,
  };
}

Map<String, dynamic>? leaveSubmitInfoParser(String? html) {
  // Leave parser haven't any check, check is unnecessary on this system.
  final Document document = parse(html);

  //TimeCode generate part.
  List<String> timeCodeList = <String>[];
  final List<Element> grids = document.getElementsByClassName('mGrid');
  if (grids.isNotEmpty) {
    final List<Element> timeCode = document
        .getElementsByClassName('mGrid')[0]
        .getElementsByTagName('tr')[0]
        .getElementsByTagName('th');
    if (timeCode.length > 5) {
      for (int i = 3; i < timeCode.length; i++) {
        timeCodeList.add(timeCode[i].text);
      }
    }
  } else {
    timeCodeList = <String>[
      'M',
      '1',
      '2',
      '3',
      '4',
      'A',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
      '13'
    ];
  }
  //LeaveType generate part.
  final List<Map<String, String>> leaveType = <Map<String, String>>[];

  final List<Element> leaveTypeList =
      document.getElementsByClassName('aspNetDisabled');
  if (leaveTypeList.length > 1) {
    for (int i = 1; i < leaveTypeList.length; i++) {
      final List<Element> labels =
          leaveTypeList[i].getElementsByTagName('label');
      final List<Element> inputs =
          leaveTypeList[i].getElementsByTagName('input');
      if (labels.isEmpty) continue;
      leaveType.add(<String, String>{
        'title': labels[0].text,
        'id': inputs[0].attributes['value'].toString(),
      });
    }

    Map<String, dynamic>? tutorData;
    //Get default tutor
    final List<Element> toturSelect = document
        .getElementById('ContentPlaceHolder1_CK001_ddlTeach')!
        .getElementsByTagName('option');
    for (int i = 1; i < toturSelect.length; i++) {
      if (toturSelect[i].attributes['selected'] != null) {
        tutorData = <String, dynamic>{
          'name': toturSelect[i].text,
          'id': toturSelect[i].attributes['value'],
        };
      }
    }

    return <String, dynamic>{
      'tutor': tutorData,
      'type': leaveType,
      'timeCodes': timeCodeList,
    };
  }
  return null;
}
