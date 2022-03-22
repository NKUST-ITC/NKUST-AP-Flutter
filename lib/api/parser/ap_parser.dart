import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ap_common/utils/crashlytics_utils.dart';
import 'package:ap_common_firebase/utils/firebase_crashlytics_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

class WebApParser {
  static WebApParser _instance;

  // ignore: prefer_constructors_over_static_methods
  static WebApParser get instance {
    return _instance ??= WebApParser();
  }

  String clearTransEncoding(List<int> htmlBytes) {
    // htmlBytes is fixed-length list, need copy.
    var tempData = new List<int>.from(htmlBytes);

    //Add /r/n on first word.
    tempData.insert(0, 10);
    tempData.insert(0, 13);

    int startIndex = 0;
    for (int i = 0; i < tempData.length - 1; i++) {
      //check i and i+1 is /r/n
      if (tempData[i] == 13 && tempData[i + 1] == 10) {
        if (i - startIndex - 2 <= 4 && i - startIndex - 2 > 0) {
          //check in this range word is number or A~F (Hex)
          int removeCount = 0;
          for (int _strIndex = startIndex + 2; _strIndex < i; _strIndex++) {
            if ((tempData[_strIndex] > 47 && tempData[_strIndex] < 58) ||
                (tempData[_strIndex] > 64 && tempData[_strIndex] < 71) ||
                (tempData[_strIndex] > 96 && tempData[_strIndex] < 103)) {
              removeCount++;
            }
          }
          if (removeCount == i - startIndex - 2) {
            tempData.removeRange(startIndex, i + 2);
          }
          //Subtract offset
          i -= i - startIndex - 2;
          startIndex -= i - startIndex - 2;
        }
        startIndex = i;
      }
    }

    return utf8.decode(tempData, allowMalformed: true);
  }

  int apLoginParser(dynamic html) {
    /*
    Retrun type Int
    0 : Login Success
    1 : Password error or not found user
    2 : Relogin
    3 : Not found login message
    */
    if (html is Uint8List) {
      html = clearTransEncoding(html);
    }

    if (html.indexOf('onclick="go_change()') > -1) {
      return 4;
    }
    // 驗證碼錯誤
    if (html.indexOf("驗證碼") > -1) {
      return -1;
    }
    if (html.indexOf("top.location.href='f_index.html'") > -1) {
      return 0;
    }
    if (html.indexOf(";top.location.href='index.html'") > -1) {
      return 1;
    }
    if (html.indexOf("location.href='relogin.jsp'") > -1 ||
        html.indexOf("top.location.href='../index.html';") > -1) {
      return 2;
    }
    return 3;
  }

  Map<String, dynamic> apUserInfoParser(String html) {
    Map<String, dynamic> data = {
      "educationSystem": null,
      "department": null,
      "className": null,
      "id": null,
      "name": null,
      "pictureUrl": null
    };
    var document = parse(html);
    var tdElements = document.getElementsByTagName("td");
    if (tdElements.length < 15) {
      // parse data error.
      return data;
    }
    try {
      String imageUrl = document
          .getElementsByTagName("img")[0]
          .attributes["src"]
          .substring(2);
      data['educationSystem'] = (tdElements[3].text.replaceAll("學　　制：", ""));
      data['department'] = (tdElements[4].text.replaceAll("科　　系：", ""));
      data['className'] = (tdElements[8].text.replaceAll("班　　級：", ""));
      data['id'] = (tdElements[9].text.replaceAll("學　　號：", ""));
      data['name'] = (tdElements[10].text.replaceAll("姓　　名：", ""));
      data['pictureUrl'] = "https://webap.nkust.edu.tw/nkust$imageUrl";
    } catch (e, s) {
      if (FirebaseCrashlyticsUtils.isSupported)
        FirebaseCrashlyticsUtils.instance.recordError(
          e,
          s,
          reason: document.outerHtml,
        );
    }
    return data;
  }

  Map<String, dynamic> webapToleaveParser(String html) {
    Map<String, dynamic> data = {};
    var document = parse(html);
    var _inputElements = document.getElementsByTagName("input");
    _inputElements.forEach((element) {
      data.addAll({element.attributes['id']: element.attributes['value']});
    });

    return data;
  }

  Map<String, dynamic> semestersParser(String html) {
    Map<String, dynamic> data = {
      "data": [],
      "default": {"year": "108", "value": "2", "text": "108學年第二學期(Parse失敗)"}
    };
    var document = parse(html);

    var ymsElements =
        document.getElementById("yms_yms").getElementsByTagName("option");
    if (ymsElements.length < 30) {
      //parse fail.
      return data;
    }
    for (int i = 0; i < ymsElements.length; i++) {
      data['data'].add({
        "year": ymsElements[i].attributes["value"].split("#")[0],
        "value": ymsElements[i].attributes["value"].split("#")[1],
        "text": ymsElements[i].text
      });
      if (ymsElements[i].attributes["selected"] != null) {
        //set default
        data['default'] = {
          "year": ymsElements[i].attributes["value"].split("#")[0],
          "value": ymsElements[i].attributes["value"].split("#")[1],
          "text": ymsElements[i].text
        };
      }
    }
    return data;
  }

  Map<String, dynamic> scoresParser(String html) {
    var document = parse(html);

    Map<String, dynamic> data = {
      "scores": [],
      "detail": {
        "conduct": null,
        "classRank": null,
        "departmentRank": null,
        'average': null
      }
    };
    //detail part
    try {
      RegExp exp = new RegExp(r".{0,4}：([0-9./]{0,})");
      var matches = exp.allMatches(document
          .getElementsByTagName('caption')[0]
          .getElementsByTagName("div")[0]
          .text);
      data['detail'] = {
        "conduct": double.parse(matches.elementAt(0).group(1)),
        "classRank": matches.elementAt(2).group(1),
        "departmentRank": matches.elementAt(3).group(1),
        "average": (matches.elementAt(1).group(1) != "")
            ? double.parse(matches.elementAt(1).group(1))
            : 0.0
      };
    } catch (e) {}
    //scores part

    try {
      var table =
          document.getElementsByTagName("table")[1].getElementsByTagName("tr");
      for (int scoresIndex = 1; scoresIndex < table.length; scoresIndex++) {
        var td = table[scoresIndex].getElementsByTagName('td');
        data['scores'].add({
          "title": td[1].text,
          'units': td[2].text,
          'hours': td[3].text,
          'required': td[4].text,
          'at': td[5].text,
          'middleScore': td[6].text,
          'semesterScore': td[7].text,
          'remark': td[8].text,
        });
      }
    } catch (e) {}

    return data;
  }

  Future<Map<String, dynamic>> coursetableParser(dynamic html) async {
    if (html is Uint8List) {
      html = clearTransEncoding(html);
    }

    Map<String, dynamic> data = {
      "courses": [],
      "timeCodes": [],
    };
    var document = parse(html);

    if (document.getElementsByTagName("table").length == 0) {
      //table not found
      return data;
    }
    try {
      //the top table parse
      var topTable =
          document.getElementsByTagName("table")[0].getElementsByTagName("tr");
      for (int i = 1; i < topTable.length; i++) {
        var td = topTable[i].getElementsByTagName('td');
        data['courses'].add({
          'code': td[0].text,
          'title': td[1].text.trim(),
          'className': td[2].text,
          'group': td[3].text,
          'units': td[4].text,
          'hours': td[5].text,
          'required': td[6].text,
          'at': td[7].text,
          'sectionTimes': [],
          "instructors": td[9].text.split(","),
          'location': {'room': td[10].text}
        });
      }
    } catch (e, s) {
      if (kDebugMode) throw e;
      if (FirebaseCrashlyticsUtils.isSupported)
        await FirebaseCrashlyticsUtils.instance.recordError(
          e,
          s,
          reason:
              "Section A = ${document.getElementsByTagName("table")[0].innerHtml}",
        );
    }

    //the second talbe.

    final Element table2 = document.getElementsByTagName("table")[1];
    //make timetable
    final trs = table2.getElementsByTagName("tr");
    final List<Element> timeCodeElements = [];
    try {
      //remark:Best split is regex but... Chinese have some difficulty Q_Q
      for (int i = 1; i < trs.length; i++) {
        final timeCodeElement = trs[i].getElementsByTagName('td')[0];
        timeCodeElements.add(timeCodeElement);
        var _temptext = timeCodeElement.text.replaceAll(" ", "");
        if (_temptext.length < 10 && i == 1) {
          data['timeCodes'].add(
            {
              "title": "第M節",
              "startTime": "07:10",
              "endTime": "08:00",
            },
          );
          continue;
        }
        final title = _temptext
            .substring(0, _temptext.length - 10)
            .replaceAll(String.fromCharCode(160), "")
            .replaceAll(" ", "");
        final courseTimeRange = _temptext
            .substring(_temptext.length - 10)
            .replaceAll(String.fromCharCode(160), "");
        final courseTimeSlits = courseTimeRange.split('-');
        final startTime = courseTimeSlits[0];
        final endTime = courseTimeSlits[1];
        data['timeCodes'].add(
          {
            "title": title,
            "startTime":
                "${startTime.substring(0, 2)}:${startTime.substring(2, 4)}",
            "endTime": "${endTime.substring(0, 2)}:${endTime.substring(2, 4)}",
          },
        );
      }
    } catch (e, s) {
      if (kDebugMode) throw e;
      if (FirebaseCrashlyticsUtils.isSupported) {
        String html = '';
        for (var value in timeCodeElements) {
          html += value.innerHtml;
        }
        await FirebaseCrashlyticsUtils.instance.recordError(
          e,
          s,
          reason: html,
        );
      }
    }
    //make each day.
    List weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    try {
      for (int weekdayIndex = 0;
          weekdayIndex < weekdays.length;
          weekdayIndex++) {
        for (int rwaTimeCodeIndex = 1;
            rwaTimeCodeIndex < data['timeCodes'].length + 1;
            rwaTimeCodeIndex++) {
          final sectionElement =
              table2.getElementsByTagName("tr")[rwaTimeCodeIndex];
          final sectionTds = sectionElement.getElementsByTagName("td");
          final eachDays = sectionTds[weekdayIndex + 1];
          final splitData = (eachDays.outerHtml
              .substring(35, eachDays.outerHtml.length - 11)
              .split("<br>"));
          if (splitData.length <= 1) {
            continue;
          }
          String courseName = splitData[0].replaceAll("\n", "");
          if (courseName.lastIndexOf(">") > -1) {
            courseName = courseName
                .substring(courseName.lastIndexOf(">") + 1, courseName.length)
                .replaceAll("&nbsp;", '')
                .replaceAll(";", '');
          }
          courseName = courseName.replaceAll('(1週)', '');
          for (var i = 0; i < data['courses'].length; i++) {
            if (data['courses'][i]['title'] == courseName) {
              for (var j = 0; j < data['timeCodes'].length; j++) {
                if (j == rwaTimeCodeIndex - 1) {
                  data['courses'][i]['sectionTimes'].add(
                    {
                      "index": j,
                      "weekday": weekdayIndex + 1,
                    },
                  );
                }
              }
            }
          }
        }
      }
    } catch (e, s) {
      if (kDebugMode) throw e;
      if (FirebaseCrashlyticsUtils.isSupported)
        await FirebaseCrashlyticsUtils.instance.recordError(
          e,
          s,
          reason: "Section C = ${table2.innerHtml}",
        );
    }
    return data;
  }

  Map<String, dynamic> midtermAlertsParser(String html) {
    Map<String, dynamic> data = {"courses": []};

    var document = parse(html);
    var table = document.getElementsByTagName("table");
    if (table.length > 1)
      try {
        final td = table[1].getElementsByTagName("tr");
        for (int i = 1; i < td.length; i++) {
          var tdData = td[i].getElementsByTagName("td");
          if (tdData.length < 5) {
            continue;
          }
          if (tdData[5].text[0] == "是") {
            data["courses"].add({
              "entry": tdData[0].text,
              "className": tdData[1].text,
              "title": tdData[2].text,
              "group": tdData[3].text,
              "instructors": tdData[4].text,
              "reason": tdData[6].text,
              "remark": tdData[7].text
            });
          }
        }
      } on Exception catch (e) {
        print(e);
      }
    return data;
  }

  Map<String, dynamic> rewardAndPenaltyParser(String html) {
    Map<String, dynamic> data = {"data": []};

    var document = parse(html);
    if (document.getElementsByTagName("table").length < 2) {
      return data;
    }
    var table = document
        .getElementsByTagName("table")[1]
        .getElementsByTagName("tr")[1]
        .getElementsByTagName("tr");
    try {
      for (int i = 1; i < table.length; i++) {
        var tdData = table[i].getElementsByTagName("td");
        if (tdData.length < 5) {
          continue;
        }
        if (tdData[3].text.length < 2) {
          continue;
        }
        data["data"].add({
          "date": tdData[2].text,
          "type": tdData[3].text,
          "counts": tdData[4].text,
          "reason": tdData[5].text
        });
      }
    } on Exception catch (e) {
      print(e);
    }
    return data;
  }

  Map<String, dynamic> roomListParser(String html) {
    Map<String, dynamic> data = {"data": []};

    var document = parse(html);
    var table =
        document.getElementById("room_id").getElementsByTagName("option");
    try {
      for (int i = 1; i < table.length; i++) {
        data["data"].add({
          "roomName": table[i].text,
          "roomId": table[i].attributes["value"]
        });
      }
    } on Exception catch (e) {
      print(e);
    }
    return data;
  }

  Map<String, dynamic> roomCourseTableQueryParser(dynamic html) {
    if (html is Uint8List) {
      html = clearTransEncoding(html);
    }

    var document = parse(html);

    Map<String, dynamic> data = {
      "courses": {},
      "coursetable": {
        "timeCodes": [],
        "Monday": [],
        "Tuesday": [],
        "Wednesday": [],
        "Thursday": [],
        "Friday": [],
        "Saturday": [],
        "Sunday": []
      },
      "_temp_time": {},
      "timeCodes": []
    };

    if (document.getElementsByTagName("table").length == 0) {
      //table not found
      // return data;
    }
    try {
      //the top table parse
      var topTable =
          document.getElementsByTagName("table")[0].getElementsByTagName("tr");
      for (int i = 1; i < topTable.length; i++) {
        var td = topTable[i].getElementsByTagName('td');
        data['courses'].addAll({
          "${td[1].text.replaceAll(String.fromCharCode(160), '')}${td[10].text.replaceAll(String.fromCharCode(160), '')}":
              {
            'code': td[0].text.replaceAll(String.fromCharCode(160), ""),
            'title': td[1].text.replaceAll(String.fromCharCode(160), ""),
            'className': td[2].text.replaceAll(String.fromCharCode(160), ""),
            'group': td[3].text.replaceAll(String.fromCharCode(160), ""),
            'units': td[4].text.replaceAll(String.fromCharCode(160), ""),
            'hours': td[5].text.replaceAll(String.fromCharCode(160), ""),
            'required': td[7].text.replaceAll(String.fromCharCode(160), ""),
            'at': td[8].text.replaceAll(String.fromCharCode(160), ""),
            'times': td[9].text.replaceAll(String.fromCharCode(160), ""),
            'sectionTimes': [],
            'location': {
              'room': null,
              'building': null,
            },
            "instructors":
                td[10].text.replaceAll(String.fromCharCode(160), "").split(",")
          }
        });
      }
    } on Exception catch (_) {
    } on RangeError catch (_) {}

    //the second talbe.

    //make timetable
    var secondTable = document.getElementsByTagName("table");
    if (secondTable.length > 0)
      try {
        final td = secondTable[1].getElementsByTagName("tr");
        //remark:Best split is regex but... Chinese have some difficulty Q_Q
        for (int i = 1; i < td.length; i++) {
          var _temptext =
              td[i].getElementsByTagName('td')[0].text.replaceAll(" ", "");
          _temptext = _temptext
              .substring(0, _temptext.length - 10)
              .replaceAll(String.fromCharCode(160), "");
          _temptext = _temptext.substring(1, _temptext.length - 1);
          data['coursetable']['timeCodes'].add(_temptext);
        }
      } on Exception catch (_) {}
    //make each day.
    List keyName = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    String tmpCourseName = '';
    try {
      for (int key = 0; key < keyName.length; key++) {
        for (int eachSession = 1;
            eachSession < data['coursetable']['timeCodes'].length + 1;
            eachSession++) {
          var eachDays = document
              .getElementsByTagName("table")[1]
              .getElementsByTagName("tr")[eachSession]
              .getElementsByTagName("td")[key + 1];

          var splitData = (eachDays.outerHtml
              .substring(eachDays.outerHtml.indexOf("; font-family: 細明體") + 20,
                  eachDays.outerHtml.indexOf(";</font>"))
              .split("<br>"));

          var _eachDaysDate = document
              .getElementsByTagName("table")[1]
              .getElementsByTagName("tr")[eachSession]
              .getElementsByTagName("td")[0]
              .outerHtml;

          var courseTime = _eachDaysDate
              .substring(_eachDaysDate.indexOf("&nbsp;<br>") + 10,
                  _eachDaysDate.indexOf("&nbsp;<br><br><"))
              .split("<br>");
          var _tempSection = courseTime[0]
              .replaceAll(" ", "")
              .replaceAll(String.fromCharCode(160), "");
          _tempSection = _tempSection.substring(1, _tempSection.length - 1);
          data['_temp_time'].addAll({
            _tempSection: {
              "startTime":
                  "${courseTime[1].split('-')[0].substring(0, 2)}:${courseTime[1].split('-')[0].substring(2, 4)}",
              "endTime":
                  "${courseTime[1].split('-')[1].substring(0, 2)}:${courseTime[1].split('-')[1].substring(2, 4)}",
              'section': _tempSection
            }
          });

          if (splitData.length <= 1) {
            continue;
          }
          String title = splitData[0].replaceAll("\n", "");

          if (title.lastIndexOf(">") > -1) {
            title = title
                .substring(title.lastIndexOf(">") + 1, title.length)
                .replaceAll("&nbsp;", '')
                .replaceAll(";", '');
          }

          data['coursetable'][keyName[key]].add({
            'title': title.replaceAll("&nbsp;", ""),
            'date': {
              "startTime":
                  "${courseTime[1].split('-')[0].substring(0, 2)}:${courseTime[1].split('-')[0].substring(2, 4)}",
              "endTime":
                  "${courseTime[1].split('-')[1].substring(0, 2)}:${courseTime[1].split('-')[1].substring(2, 4)}",
              'section': _tempSection
            },
            'rawInstructors': splitData[1]
                .replaceAll(String.fromCharCode(160), "")
                .replaceAll("&nbsp;", ""),
            'instructors': splitData[1].replaceAll("&nbsp;", "").split(","),
          });
        }
      }
      // mix weekday to course.
      for (int weekKeyIndex = 0;
          weekKeyIndex < keyName.length;
          weekKeyIndex++) {
        for (var course in data['coursetable'][keyName[weekKeyIndex]]) {
          var _temp = {
            "weekday": weekKeyIndex + 1,
            "index": data['_temp_time']
                .values
                .toList()
                .indexOf(data['_temp_time'][course['date']['section']]),
          };
          tmpCourseName = "${course['title']}${course['rawInstructors']}";
          data['courses'][tmpCourseName]['sectionTimes'].add(_temp);
        }
      }
      // courses to list
      data['courses'] = data['courses'].values.toList();
      data.remove('coursetable');
      data['_temp_time'] = data['_temp_time'].values.toList();
      for (int timeCodeIndex = 0;
          timeCodeIndex < data['_temp_time'].length;
          timeCodeIndex++) {
        data['timeCodes'].add({
          "title": data['_temp_time'][timeCodeIndex]['section'],
          "startTime": data['_temp_time'][timeCodeIndex]['startTime'],
          "endTime": data['_temp_time'][timeCodeIndex]['endTime']
        });
      }
      data.remove('_temp_time');
    } catch (e, s) {
      CrashlyticsUtils.instance
          .recordError(e, s, reason: "course name = $tmpCourseName");
    }

    return data;
  }
}

void main() {
  new File('file.txt').readAsString().then((String contents) {
    print(WebApParser.instance.apLoginParser(contents));
  });
}
