import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ap_common/ap_common.dart';
import 'package:ap_common_firebase/ap_common_firebase.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:nkust_ap/api/helper.dart';

//TODO confirm this rule
//ignore_for_file: unreachable_from_main

final String specialSpace = String.fromCharCode(160);

class WebApParser {
  static WebApParser? _instance;

  // ignore: prefer_constructors_over_static_methods
  static WebApParser get instance {
    return _instance ??= WebApParser();
  }

  String clearTransEncoding(List<int> htmlBytes) {
    // htmlBytes is fixed-length list, need copy.
    final List<int> tempData = List<int>.from(htmlBytes);

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
          for (int strIndex = startIndex + 2; strIndex < i; strIndex++) {
            if ((tempData[strIndex] > 47 && tempData[strIndex] < 58) ||
                (tempData[strIndex] > 64 && tempData[strIndex] < 71) ||
                (tempData[strIndex] > 96 && tempData[strIndex] < 103)) {
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
    4 : Not found error message
    500 : server busy
    */
    String rawHtml;
    if (html is Uint8List) {
      rawHtml = clearTransEncoding(html);
    } else if (html is String) {
      rawHtml = html;
      if (rawHtml.contains('onclick="go_change()')) {
        return 4;
      }
      // 驗證碼錯誤
      if (rawHtml.contains('驗證碼')) {
        return -1;
      }
      if (rawHtml.contains("top.location.href='f_index.html'")) {
        return 0;
      }
      if (rawHtml.contains(";top.location.href='index.html'")) {
        final RegExp regex = RegExp(r"alert\('(.*)'\);");
        // log(rawHtml);
        final String? match = regex.allMatches(rawHtml).elementAt(1).group(1);
        log('match $match');
        if (match == null) {
          return 999;
        } else if (match.contains('無此帳號或密碼不正確')) {
          return 1;
        } else if (match.contains('您先前已登入')) {
          return 5;
        } else if (match.contains('繁忙')) {
          return 500;
        }
        return 999;
      }
      if (rawHtml.contains("location.href='relogin.jsp'") ||
          rawHtml.contains("top.location.href='../index.html';")) {
        return 2;
      }
    }
    return 3;
  }

  Map<String, dynamic> apUserInfoParser(String? html) {
    final Map<String, dynamic> data = <String, dynamic>{
      'educationSystem': null,
      'department': null,
      'className': null,
      'id': null,
      'name': null,
      'pictureUrl': null,
    };
    final Document document = parse(html);
    final List<Element> tdElements = document.getElementsByTagName('td');
    if (tdElements.length < 15) {
      // parse data error.
      data['id'] = Helper.username;
      return data;
    }
    try {
      final String imageUrl = document
          .getElementsByTagName('img')[0]
          .attributes['src']!
          .substring(2);
      data['educationSystem'] = tdElements[3].text.replaceAll('學　　制：', '');
      data['department'] = tdElements[4].text.replaceAll('科　　系：', '');
      data['className'] = tdElements[8].text.replaceAll('班　　級：', '');
      data['id'] = tdElements[9].text.replaceAll('學　　號：', '');
      data['name'] = tdElements[10].text.replaceAll('姓　　名：', '');
      data['pictureUrl'] = 'https://webap.nkust.edu.tw/nkust$imageUrl';
    } catch (e, s) {
      if (FirebaseCrashlyticsUtils.isSupported) {
        CrashlyticsUtil.instance.recordError(
          e,
          s,
          reason: document.outerHtml,
        );
      }
    }
    return data;
  }

  Map<String, dynamic> webapToleaveParser(String? html) {
    final Map<String, dynamic> data = <String, dynamic>{};
    final Document document = parse(html);
    final List<Element> inputElements = document.getElementsByTagName('input');
    for (final Element element in inputElements) {
      if (element.attributes['id'] != null) {
        data.addAll(
          <String, dynamic>{
            element.attributes['id']!: element.attributes['value'],
          },
        );
      }
    }
    return data;
  }

  Map<String, dynamic> semestersParser(String? html) {
    final Map<String, dynamic> data = <String, dynamic>{
      'data': <Map<String, dynamic>>[],
      'default': <String, dynamic>{
        'year': '108',
        'value': '2',
        'text': '108學年第二學期(Parse失敗)',
      },
    };
    final Document document = parse(html);

    final List<Element> ymsElements =
        document.getElementById('yms_yms')!.getElementsByTagName('option');
    if (ymsElements.length < 30) {
      //parse fail.
      return data;
    }
    for (int i = 0; i < ymsElements.length; i++) {
      (data['data'] as List<Map<String, dynamic>>).add(
        <String, dynamic>{
          'year': ymsElements[i].attributes['value']!.split('#')[0],
          'value': ymsElements[i].attributes['value']!.split('#')[1],
          'text': ymsElements[i].text,
        },
      );
      if (ymsElements[i].attributes['selected'] != null) {
        //set default
        data['default'] = <String, dynamic>{
          'year': ymsElements[i].attributes['value']!.split('#')[0],
          'value': ymsElements[i].attributes['value']!.split('#')[1],
          'text': ymsElements[i].text,
        };
      }
    }
    return data;
  }

  Map<String, dynamic> scoresParser(String? html) {
    final Document document = parse(html);

    final Map<String, dynamic> data = <String, dynamic>{
      'scores': <Map<String, dynamic>>[],
      'detail': <String, dynamic>{
        'conduct': null,
        'classRank': null,
        'departmentRank': null,
        'average': null,
      },
    };
    //detail part
    try {
      final RegExp exp = RegExp('.{0,4}：([0-9./]{0,})');
      final Iterable<RegExpMatch> matches = exp.allMatches(
        document
            .getElementsByTagName('caption')[0]
            .getElementsByTagName('div')[0]
            .text,
      );
      data['detail'] = <String, dynamic>{
        'conduct': double.parse(matches.elementAt(0).group(1)!),
        'classRank': matches.elementAt(2).group(1),
        'departmentRank': matches.elementAt(3).group(1),
        'average': (matches.elementAt(1).group(1) != '')
            ? double.parse(matches.elementAt(1).group(1)!)
            : 0.0,
      };
    } catch (_) {}
    //scores part

    try {
      final List<Element> table =
          document.getElementsByTagName('table')[1].getElementsByTagName('tr');
      for (int scoresIndex = 1; scoresIndex < table.length; scoresIndex++) {
        final List<Element> td = table[scoresIndex].getElementsByTagName('td');
        (data['scores'] as List<Map<String, dynamic>>).add(
          <String, dynamic>{
            'title': td[1].text,
            'units': td[2].text,
            'hours': td[3].text,
            'required': td[4].text,
            'at': td[5].text,
            'middleScore': td[6].text,
            'semesterScore': td[7].text,
            'remark': td[8].text,
          },
        );
      }
    } catch (_) {}
    return data;
  }

  Future<Map<String, dynamic>> coursetableParser(dynamic html) async {
    dynamic rawHtml;
    if (html is Uint8List) {
      rawHtml = clearTransEncoding(html);
    } else {
      rawHtml = html;
    }

    final Map<String, List<Map<String, dynamic>>> data =
        <String, List<Map<String, dynamic>>>{
      'courses': <Map<String, dynamic>>[],
      'timeCodes': <Map<String, dynamic>>[],
    };
    final Document document = parse(rawHtml);

    if (document.getElementsByTagName('table').isEmpty) {
      //table not found
      return data;
    }
    try {
      //the top table parse
      final List<Element> topTable =
          document.getElementsByTagName('table')[0].getElementsByTagName('tr');
      for (int i = 1; i < topTable.length; i++) {
        final List<Element> td = topTable[i].getElementsByTagName('td');
        data['courses']?.add(
          <String, dynamic>{
            'code': td[0].text,
            'title': td[1].text.trim(),
            'className': td[2].text,
            'group': td[3].text,
            'units': td[4].text,
            'hours': td[5].text,
            'required': td[6].text,
            'at': td[7].text,
            'sectionTimes': <Map<String, dynamic>>[],
            'instructors': td[9].text.split(','),
            'location': <String, dynamic>{
              'building': '',
              'room': td[10].text,
            },
          },
        );
      }
    } catch (e, s) {
      if (kDebugMode) rethrow;
      if (FirebaseCrashlyticsUtils.isSupported) {
        await CrashlyticsUtil.instance.recordError(
          e,
          s,
          reason: 'Section A = '
              "${document.getElementsByTagName("table")[0].innerHtml}",
        );
      }
    }

    //the second talbe.

    final Element table2 = document.getElementsByTagName('table')[1];
    //make timetable
    final List<Element> trs = table2.getElementsByTagName('tr');
    final List<Element> timeCodeElements = <Element>[];
    try {
      //remark:Best split is regex but... Chinese have some difficulty Q_Q
      for (int i = 1; i < trs.length; i++) {
        final Element timeCodeElement = trs[i].getElementsByTagName('td')[0];
        timeCodeElements.add(timeCodeElement);
        final String temptext = timeCodeElement.text.replaceAll(' ', '');
        if (temptext.length < 10 && i == 1) {
          data['timeCodes']?.add(
            <String, dynamic>{
              'title': '第M節',
              'startTime': '07:10',
              'endTime': '08:00',
            },
          );
          continue;
        }
        final String title = temptext
            .substring(0, temptext.length - 10)
            .replaceAll(specialSpace, '')
            .replaceAll(' ', '');
        final String courseTimeRange = temptext
            .substring(temptext.length - 10)
            .replaceAll(specialSpace, '');
        final List<String> courseTimeSlits = courseTimeRange.split('-');
        final String startTime = courseTimeSlits[0];
        final String endTime = courseTimeSlits[1];
        data['timeCodes']?.add(
          <String, dynamic>{
            'title': title,
            'startTime':
                '${startTime.substring(0, 2)}:${startTime.substring(2, 4)}',
            'endTime': '${endTime.substring(0, 2)}:${endTime.substring(2, 4)}',
          },
        );
      }
    } catch (e, s) {
      if (kDebugMode) rethrow;
      if (FirebaseCrashlyticsUtils.isSupported) {
        final StringBuffer htmlStringBuffer = StringBuffer();
        for (final Element value in timeCodeElements) {
          htmlStringBuffer.write(value.innerHtml);
        }
        await CrashlyticsUtil.instance.recordError(
          e,
          s,
          reason: htmlStringBuffer.toString(),
        );
      }
    }
    //make each day.
    final List<String> weekdays = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    try {
      for (int weekdayIndex = 0;
          weekdayIndex < weekdays.length;
          weekdayIndex++) {
        for (int rwaTimeCodeIndex = 1;
            rwaTimeCodeIndex < data['timeCodes']!.length + 1;
            rwaTimeCodeIndex++) {
          final Element sectionElement =
              table2.getElementsByTagName('tr')[rwaTimeCodeIndex];
          final List<Element> sectionTds =
              sectionElement.getElementsByTagName('td');
          final Element eachDays = sectionTds[weekdayIndex + 1];
          final List<String> splitData = eachDays.outerHtml
              .substring(35, eachDays.outerHtml.length - 11)
              .split('<br>');
          if (splitData.length <= 1) {
            continue;
          }
          String courseName =
              splitData[0].replaceAll('\n', '').replaceAll('(18週)', '');
          if (courseName.lastIndexOf('>') > -1) {
            courseName = courseName
                .substring(courseName.lastIndexOf('>') + 1, courseName.length)
                .replaceAll('&nbsp;', '')
                .replaceAll(';', '');
          }
          courseName = courseName.replaceAll('(1週)', '');
          for (int i = 0; i < data['courses']!.length; i++) {
            if (data['courses']![i]['title'] == courseName) {
              for (int j = 0; j < data['timeCodes']!.length; j++) {
                if (j == rwaTimeCodeIndex - 1) {
                  (data['courses']![i]['sectionTimes'] as List<dynamic>).add(
                    <String, dynamic>{
                      'index': j,
                      'weekday': weekdayIndex + 1,
                    },
                  );
                }
              }
            }
          }
        }
      }
    } catch (e, s) {
      if (kDebugMode) rethrow;
      if (FirebaseCrashlyticsUtils.isSupported) {
        await CrashlyticsUtil.instance.recordError(
          e,
          s,
          reason: 'Section C = ${table2.innerHtml}',
        );
      }
    }
    return data;
  }

  Map<String, dynamic> midtermAlertsParser(String? html) {
    final Map<String, dynamic> data = <String, dynamic>{
      'courses': <Map<String, dynamic>>[],
    };

    final Document document = parse(html);
    final List<Element> table = document.getElementsByTagName('table');
    if (table.length > 1) {
      try {
        final List<Element> td = table[1].getElementsByTagName('tr');
        for (int i = 1; i < td.length; i++) {
          final List<Element> tdData = td[i].getElementsByTagName('td');
          if (tdData.length < 5) {
            continue;
          }
          if (tdData[5].text[0] == '是') {
            (data['courses'] as List<Map<String, dynamic>>).add(
              <String, dynamic>{
                'entry': tdData[0].text,
                'className': tdData[1].text,
                'title': tdData[2].text,
                'group': tdData[3].text,
                'instructors': tdData[4].text,
                'reason': tdData[6].text,
                'remark': tdData[7].text,
              },
            );
          }
        }
      } on Exception catch (e) {
        log(e.toString());
      }
    }
    return data;
  }

  Map<String, dynamic> rewardAndPenaltyParser(String? html) {
    final Map<String, dynamic> data = <String, dynamic>{
      'data': <Map<String, dynamic>>[],
    };

    final Document document = parse(html);
    if (document.getElementsByTagName('table').length < 2) {
      return data;
    }
    final List<Element> table = document
        .getElementsByTagName('table')[1]
        .getElementsByTagName('tr')[1]
        .getElementsByTagName('tr');
    try {
      for (int i = 1; i < table.length; i++) {
        final List<Element> tdData = table[i].getElementsByTagName('td');
        if (tdData.length < 5) {
          continue;
        }
        if (tdData[3].text.length < 2) {
          continue;
        }
        (data['data'] as List<Map<String, dynamic>>).add(
          <String, dynamic>{
            'date': tdData[2].text,
            'type': tdData[3].text,
            'counts': tdData[4].text,
            'reason': tdData[5].text,
          },
        );
      }
    } on Exception catch (e) {
      log(e.toString());
    }
    return data;
  }

  Map<String, dynamic> roomListParser(String? html) {
    final Map<String, dynamic> data = <String, dynamic>{
      'data': <Map<String, dynamic>>[],
    };

    final Document document = parse(html);
    final List<Element> table =
        document.getElementById('room_id')!.getElementsByTagName('option');
    try {
      for (int i = 1; i < table.length; i++) {
        (data['data'] as List<Map<String, dynamic>>).add(
          <String, dynamic>{
            'roomName': table[i].text,
            'roomId': table[i].attributes['value'] ?? '0035',
          },
        );
      }
    } on Exception catch (e) {
      log(e.toString());
    }
    return data;
  }

  Map<String, dynamic> roomCourseTableQueryParser(dynamic html) {
    dynamic rawHtml;

    if (html is Uint8List) {
      rawHtml = clearTransEncoding(html);
    } else {
      rawHtml = html;
    }

    final Document document = parse(rawHtml);

    final Map<String, dynamic> data = <String, dynamic>{
      'courses': <String, dynamic>{},
      'coursetable': <String, List<dynamic>>{
        'timeCodes': <String>[],
        'Monday': <Map<String, dynamic>>[],
        'Tuesday': <Map<String, dynamic>>[],
        'Wednesday': <Map<String, dynamic>>[],
        'Thursday': <Map<String, dynamic>>[],
        'Friday': <Map<String, dynamic>>[],
        'Saturday': <Map<String, dynamic>>[],
        'Sunday': <Map<String, dynamic>>[],
      },
      '_temp_time': <Map<String, dynamic>>{},
      'timeCodes': <Map<String, dynamic>>[],
    };

    final Map<String, dynamic> courseTable =
        data['coursetable'] as Map<String, dynamic>;

    final Map<String, dynamic> courses =
        data['courses'] as Map<String, dynamic>;

    if (document.getElementsByTagName('table').isEmpty) {
      //table not found
      // return data;
    }
    try {
      //the top table parse
      if (document.getElementsByTagName('table').isNotEmpty) {
        final List<Element> topTable = document
            .getElementsByTagName('table')[0]
            .getElementsByTagName('tr');
        for (int i = 1; i < topTable.length; i++) {
          final List<Element> td = topTable[i].getElementsByTagName('td');
          courses.addAll(
            <String, Map<String, dynamic>>{
              "${td[1].text.replaceAll(specialSpace, '')}"
                      "${td[10].text.replaceAll(specialSpace, '')}":
                  <String, dynamic>{
                'code': td[0].text.replaceAll(specialSpace, ''),
                'title': td[1].text.replaceAll(specialSpace, ''),
                'className': td[2].text.replaceAll(specialSpace, ''),
                'group': td[3].text.replaceAll(specialSpace, ''),
                'units': td[4].text.replaceAll(specialSpace, ''),
                'hours': td[5].text.replaceAll(specialSpace, ''),
                'required': td[7].text.replaceAll(specialSpace, ''),
                'at': td[8].text.replaceAll(specialSpace, ''),
                'times': td[9].text.replaceAll(specialSpace, ''),
                'sectionTimes': <Map<String, dynamic>>[],
                'location': null,
                'instructors':
                    td[10].text.replaceAll(specialSpace, '').split(','),
              },
            },
          );
        }
      }
      data['courses'] = courses;
    } on Exception catch (_) {}

    //the second talbe.

    //make timetable
    final List<Element> secondTable = document.getElementsByTagName('table');
    if (secondTable.isNotEmpty) {
      try {
        final List<Element> td = secondTable[1].getElementsByTagName('tr');
        //remark:Best split is regex but... Chinese have some difficulty Q_Q
        for (int i = 1; i < td.length; i++) {
          String temptext =
              td[i].getElementsByTagName('td')[0].text.replaceAll(' ', '');
          temptext = temptext
              .substring(0, temptext.length - 10)
              .replaceAll(specialSpace, '');
          temptext = temptext.substring(1, temptext.length - 1);
          (courseTable['timeCodes'] as List<String>).add(temptext);
        }
      } on Exception catch (_) {}
    }
    //make each day.
    final List<String> keyName = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    String tmpCourseName = '';
    try {
      final Map<String, dynamic> tempTime = <String, dynamic>{};
      for (int key = 0; key < keyName.length; key++) {
        for (int eachSession = 1;
            eachSession <
                (courseTable['timeCodes'] as List<dynamic>).length + 1;
            eachSession++) {
          final Element eachDays = document
              .getElementsByTagName('table')[1]
              .getElementsByTagName('tr')[eachSession]
              .getElementsByTagName('td')[key + 1];

          final List<String> splitData = eachDays.outerHtml
              .substring(
                eachDays.outerHtml.indexOf('; font-family: 細明體') + 20,
                eachDays.outerHtml.indexOf(';</font>'),
              )
              .split('<br>');

          final String eachDaysDate = document
              .getElementsByTagName('table')[1]
              .getElementsByTagName('tr')[eachSession]
              .getElementsByTagName('td')[0]
              .outerHtml;

          final List<String> courseTime = eachDaysDate
              .substring(
                eachDaysDate.indexOf('&nbsp;<br>') + 10,
                eachDaysDate.indexOf('&nbsp;<br><br><'),
              )
              .split('<br>');
          String tempSection =
              courseTime[0].replaceAll(' ', '').replaceAll(specialSpace, '');
          tempSection = tempSection.substring(1, tempSection.length - 1);
          tempTime.addAll(<String, dynamic>{
            tempSection: <String, dynamic>{
              'startTime':
                  //ignore: lines_longer_than_80_chars
                  "${courseTime[1].split('-')[0].substring(0, 2)}:${courseTime[1].split('-')[0].substring(2, 4)}",
              'endTime':
                  //ignore: lines_longer_than_80_chars
                  "${courseTime[1].split('-')[1].substring(0, 2)}:${courseTime[1].split('-')[1].substring(2, 4)}",
              'section': tempSection,
            },
          });

          if (splitData.length <= 1) {
            continue;
          }
          String title = splitData[0].replaceAll('\n', '');

          if (title.lastIndexOf('>') > -1) {
            title = title
                .substring(title.lastIndexOf('>') + 1, title.length)
                .replaceAll('&nbsp;', '')
                .replaceAll(';', '');
          }

          (courseTable[keyName[key]] as List<dynamic>).add(
            <String, dynamic>{
              'title': title.replaceAll('&nbsp;', ''),
              'date': <String, dynamic>{
                'startTime':
                    //ignore: lines_longer_than_80_chars
                    "${courseTime[1].split('-')[0].substring(0, 2)}:${courseTime[1].split('-')[0].substring(2, 4)}",
                'endTime':
                    //ignore: lines_longer_than_80_chars
                    "${courseTime[1].split('-')[1].substring(0, 2)}:${courseTime[1].split('-')[1].substring(2, 4)}",
                'section': tempSection,
              },
              'rawInstructors': splitData[1]
                  .replaceAll(specialSpace, '')
                  .replaceAll('&nbsp;', ''),
              'instructors': splitData[1].replaceAll('&nbsp;', '').split(','),
            },
          );
        }
      }
      data['_temp_time'] = tempTime;
      // mix weekday to course.
      for (int weekKeyIndex = 0;
          weekKeyIndex < keyName.length;
          weekKeyIndex++) {
        final List<dynamic> courses =
            courseTable[keyName[weekKeyIndex]] as List<dynamic>;
        for (final dynamic course in courses) {
          final Map<String, dynamic> temp = <String, dynamic>{
            'weekday': weekKeyIndex + 1,
            //ignore: avoid_dynamic_calls
            'index': data['_temp_time']
                .values
                .toList()
                //ignore: avoid_dynamic_calls
                .indexOf(data['_temp_time'][course['date']['section']]),
          };
          //ignore: avoid_dynamic_calls
          tmpCourseName = "${course['title']}${course['rawInstructors']}";
          //ignore: avoid_dynamic_calls
          data['courses'][tmpCourseName]['sectionTimes'].add(temp);
        }
      }
      // courses to list
      //ignore: avoid_dynamic_calls
      data['courses'] = data['courses'].values.toList();
      data.remove('coursetable');
      //ignore: avoid_dynamic_calls
      data['_temp_time'] = data['_temp_time'].values.toList();
      for (int timeCodeIndex = 0;
          timeCodeIndex < (data['_temp_time'] as List<dynamic>).length;
          timeCodeIndex++) {
        //ignore: avoid_dynamic_calls
        data['timeCodes'].add(<String, dynamic>{
          //ignore: avoid_dynamic_calls
          'title': data['_temp_time'][timeCodeIndex]['section'],
          //ignore: avoid_dynamic_calls
          'startTime': data['_temp_time'][timeCodeIndex]['startTime'],
          //ignore: avoid_dynamic_calls
          'endTime': data['_temp_time'][timeCodeIndex]['endTime'],
        });
      }
      data.remove('_temp_time');
    } catch (e, s) {
      CrashlyticsUtil.instance
          .recordError(e, s, reason: 'course name = $tmpCourseName');
    }

    return data;
  }

  Map<String, dynamic> enrollmentRequestParser(String? html) {
    if (html == null || html.isEmpty) {
      return <String, dynamic>{};
    }

    final Document document = parse(html);

    final Element? form = document.querySelector('form');
    String action = '';
    if (form != null) {
      action = form.attributes['action'] ?? '';
      if (action.endsWith('?')) {
        action = action.substring(0, action.length - 1);
      }
    }

    final List<Element> inputs =
        document.querySelectorAll('input[type=hidden]');
    final Map<String, String> params = <String, String>{};

    for (final Element input in inputs) {
      final String name = input.attributes['name'] ?? '';
      final String value = input.attributes['value'] ?? '';
      if (name.isNotEmpty) {
        params[name] = value;
      }
    }

    return <String, dynamic>{
      'action': action,
      'params': params,
    };
  }

  String? enrollmentLetterPathParser(String? html) {
    if (html == null || html.isEmpty) return null;

    final Document document = parse(html);

    final Element? objectTag = document.querySelector('object#pdf1');
    if (objectTag != null) {
      final String? data = objectTag.attributes['data'];
      if (data != null && data.isNotEmpty) return data;
    }

    final Element? buttonTag = document.querySelector('#download_btn');
    if (buttonTag != null) {
      final String? onclick = buttonTag.attributes['onclick'];
      if (onclick != null) {
        final RegExp regex = RegExp("download_file(['\"](.+?)['\"])");
        final RegExpMatch? match = regex.firstMatch(onclick);
        if (match != null) {
          return match.group(1);
        }
      }
    }

    return null;
  }
}

void main() {
  File('file.txt').readAsString().then((String contents) {
    log(WebApParser.instance.apLoginParser(contents).toString());
  });
}
