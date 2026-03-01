import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:ap_common/ap_common.dart';

class StdsysParser {
  static StdsysParser? _instance;

  // ignore: prefer_constructors_over_static_methods
  static StdsysParser get instance {
    return _instance ??= StdsysParser();
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

  Map<String, dynamic> roomListParser(String? jsonString) {
    final Map<String, dynamic> data = <String, dynamic>{
      'data': <Map<String, dynamic>>[],
    };

    if (jsonString == null || jsonString.isEmpty) {
      return data;
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

      for (final item in jsonList) {
        (data['data'] as List<Map<String, dynamic>>).add(
          <String, dynamic>{
            'roomName': item['text'],
            'roomId': item['value'] ?? '0035',
          },
        );
      }
    } on Exception catch (e) {
      log(e.toString());
    }

    return data;
  }

  Map<String, dynamic> studentCourseTableParser(dynamic html) {
    dynamic rawHtml;

    if (html is Uint8List) {
      rawHtml = clearTransEncoding(html);
    } else {
      rawHtml = html;
    }

    final Document document = parse(rawHtml);

    // Result structure
    final Map<String, dynamic> courses = <String, dynamic>{};
    final Map<String, dynamic> tempTime = <String, dynamic>{};
    final List<Map<String, dynamic>> timeCodes = <Map<String, dynamic>>[];

    // stdsys 個人課表只有 1 個 timetable（不像 roomCourseTableQuery 有 2 個）
    // 欄位：td[0]=節次時間, td[1]=週一, td[2]=週二, ... td[7]=週日
    final List<Element> tables = document.getElementsByTagName('table');
    if (tables.isEmpty) {
      log('[stdsys] no table found');
      return <String, dynamic>{'courses': <dynamic>[], 'timeCodes': timeCodes};
    }

    final Element timetable = tables[0];
    final List<Element> rows = timetable.getElementsByTagName('tr');
    log('[stdsys] timetable rows: ${rows.length}');

    final List<String> dayKeys = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    // 節次索引追蹤（依插入順序）
    final List<String> sectionOrder = <String>[];

    // 正規表達式：時間格式 HH:MM
    final RegExp timeRegex = RegExp(r'^\d{2}:\d{2}$');

    try {
      for (int rowIdx = 1; rowIdx < rows.length; rowIdx++) {
        final List<Element> tds = rows[rowIdx].getElementsByTagName('td');
        if (tds.length < 2) continue;

        // ── 解析 td[0]：節次 + 時間 ──────────────────────────────────
        // 格式（text）："M\n07:10\n|\n\n08:00" 或 "1\n08:10\n|\n\n09:00"
        final List<String> timeParts = tds[0]
            .text
            .split(RegExp(r'[\s\r\n|]+'))
            .map((String s) => s.trim())
            .where((String s) => s.isNotEmpty)
            .toList();

        String section = '';
        String startTime = '';
        String endTime = '';

        for (final String part in timeParts) {
          if (timeRegex.hasMatch(part)) {
            if (startTime.isEmpty) {
              startTime = part;
            } else {
              endTime = part;
            }
          } else if (section.isEmpty) {
            section = part;
          }
        }

        if (section.isEmpty) continue;

        // 記錄節次（去重）
        if (!tempTime.containsKey(section)) {
          tempTime[section] = <String, dynamic>{
            'startTime': startTime,
            'endTime': endTime,
            'section': section,
          };
          sectionOrder.add(section);
          timeCodes.add(<String, dynamic>{
            'title': section,
            'startTime': startTime,
            'endTime': endTime,
          });
        }
        final int sectionIndex = sectionOrder.indexOf(section);

        // ── 解析 td[1..7]：各天課程 ─────────────────────────────────
        for (int dayIdx = 0; dayIdx < dayKeys.length; dayIdx++) {
          final int tdIdx = dayIdx + 1;
          if (tdIdx >= tds.length) break;

          final Element dayCell = tds[tdIdx];
          if (dayCell.text.trim().isEmpty) continue;

          // 以 <br> 切割：課名 / 老師 / 教室 / 校區
          final List<String> parts = dayCell.innerHtml
              .split(RegExp(r'<br\s*/?>'))
              .map((String s) => s
                  .replaceAll(RegExp(r'<[^>]*>'), '')
                  .replaceAll('&nbsp;', '')
                  .replaceAll(String.fromCharCode(160), '')
                  .trim())
              .where((String s) => s.isNotEmpty)
              .toList();

          if (parts.isEmpty) continue;

          final String title = parts[0];
          final String rawInstructors =
              parts.length > 1 ? parts[1].replaceAll('老師', '').trim() : '';
          final String room = parts.length > 2 ? parts[2].trim() : '';
          //TODO: 處理校區

          // 以「課名＋老師」作為 key 合併同一門課的多節
          final String courseKey = '$title$rawInstructors';

          if (!courses.containsKey(courseKey)) {
            courses[courseKey] = <String, dynamic>{
              'code': '',
              'title': title,
              'className': '',
              'group': '',
              'units': '',
              'hours': '',
              'required': '',
              'at': '',
              'sectionTimes': <Map<String, dynamic>>[],
              'location': room.isNotEmpty
                  ? <String, dynamic>{'building': '', 'room': room}
                  : null,
              'instructors': rawInstructors.isNotEmpty
                  ? <String>[rawInstructors]
                  : <String>[],
            };
          }

          (courses[courseKey]['sectionTimes'] as List<dynamic>).add(
            <String, dynamic>{
              'weekday': dayIdx + 1,
              'index': sectionIndex,
            },
          );
        }
      }
    } catch (e, s) {
      CrashlyticsUtil.instance
          .recordError(e, s, reason: 'studentCourseTableParser failed');
    }

    log('[stdsys] parsed courses: ${courses.length}, timeCodes: ${timeCodes.length}');

    return <String, dynamic>{
      'courses': courses.values.toList(),
      'timeCodes': timeCodes,
    };
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
              "${td[1].text.replaceAll(String.fromCharCode(160), '')}"
                      "${td[10].text.replaceAll(String.fromCharCode(160), '')}":
                  <String, dynamic>{
                'code': td[0].text.replaceAll(String.fromCharCode(160), ''),
                'title': td[1].text.replaceAll(String.fromCharCode(160), ''),
                'className':
                    td[2].text.replaceAll(String.fromCharCode(160), ''),
                'group': td[3].text.replaceAll(String.fromCharCode(160), ''),
                'units': td[4].text.replaceAll(String.fromCharCode(160), ''),
                'hours': td[5].text.replaceAll(String.fromCharCode(160), ''),
                'required': td[7].text.replaceAll(String.fromCharCode(160), ''),
                'at': td[8].text.replaceAll(String.fromCharCode(160), ''),
                'times': td[9].text.replaceAll(String.fromCharCode(160), ''),
                'sectionTimes': <Map<String, dynamic>>[],
                'location': null,
                'instructors': td[10]
                    .text
                    .replaceAll(String.fromCharCode(160), '')
                    .split(','),
              },
            },
          );
        }
      }
      data['courses'] = courses;
    } on Exception catch (_) {}

    //the second talbe.

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

    //make timetable
    final List<Element> tables = document.getElementsByTagName('table');
    if (tables.length >= 2) {
      final Element timetable = tables[1];
      final List<Element> rows = timetable.querySelectorAll('tbody > tr');
      final Map<String, dynamic> tempTime = <String, dynamic>{};

      try {
        for (var tr in rows) {
          final List<Element> tds = tr.getElementsByTagName('td');
          if (tds.isEmpty) continue;

          //節次與時間
          final Element timeCell = tds[0];
          //節次名稱
          final String section =
              timeCell.querySelector('span')?.text.trim() ?? "";

          //處理時間內容
          final String fullTimeText =
              timeCell.text.replaceAll(section, "").trim();
          final List<String> times = fullTimeText
              .split(RegExp(r'[\s|]+'))
              .where((s) => s.isNotEmpty)
              .toList();

          final String startTime = times.isNotEmpty ? times[0] : "";
          final String endTime = times.length > 1 ? times[1] : "";

          if (section.isNotEmpty) {
            (courseTable['timeCodes'] as List<String>).add(section);

            tempTime[section] = <String, dynamic>{
              'startTime': startTime,
              'endTime': endTime,
              'section': section,
            };
          }

          //週一至週日課程
          for (int key = 0; key < keyName.length; key++) {
            final Element dayCell = tds[key + 1];

            if (dayCell.text.trim().isEmpty) continue;

            //依照<br>割細節(1代碼 2名稱 3老師 4班級)
            final List<String> splitData = dayCell.innerHtml
                .split(RegExp(r'<br\s*/?>'))
                .map((s) => s
                    .replaceAll(RegExp(r'<[^>]*>'), '')
                    .replaceAll('&nbsp;', '')
                    .trim())
                .where((s) => s.isNotEmpty)
                .toList();

            if (splitData.length >= 2) {
              final String title = splitData[1]; //課程名稱
              final String rawInstructors = splitData.length > 2
                  ? splitData[2].replaceAll('老師', '').trim()
                  : "";

              (courseTable[keyName[key]] as List<dynamic>).add(
                <String, dynamic>{
                  'title': title,
                  'date': <String, dynamic>{
                    'startTime': startTime,
                    'endTime': endTime,
                    'section': section,
                  },
                  'rawInstructors': rawInstructors,
                  'instructors': rawInstructors.split(','),
                },
              );
            }
          }
        }

        data['_temp_time'] = tempTime;
      } catch (e, s) {
        CrashlyticsUtil.instance.recordError(e, s, reason: 'Parse grid failed');
      }
    }

    String tmpCourseName = '';
    try {
      for (int weekKeyIndex = 0;
          weekKeyIndex < keyName.length;
          weekKeyIndex++) {
        final List<dynamic> dayCourses =
            courseTable[keyName[weekKeyIndex]] as List<dynamic>;
        for (final dynamic course in dayCourses) {
          final String sectionKey = course['date']['section'] as String;
          final Map<String, dynamic>? targetTime =
              data['_temp_time'][sectionKey] as Map<String, dynamic>;

          if (targetTime == null) continue;

          final Map<String, dynamic> temp = <String, dynamic>{
            'weekday': weekKeyIndex + 1,
            'index': data['_temp_time'].values.toList().indexOf(targetTime),
          };

          tmpCourseName = "${course['title']}${course['rawInstructors']}";

          if (data['courses'][tmpCourseName] != null) {
            data['courses'][tmpCourseName]['sectionTimes'].add(temp);
          }
        }
      }

      data['courses'] =
          (data['courses'] as Map<String, dynamic>).values.toList();
      data.remove('coursetable');
      data['_temp_time'] =
          (data['_temp_time'] as Map<String, dynamic>).values.toList();
      for (int i = 0; i < (data['_temp_time'] as List<dynamic>).length; i++) {
        data['timeCodes'].add(<String, dynamic>{
          'title': (data['_temp_time'][i] as Map<String, dynamic>)['section'],
          'startTime':
              (data['_temp_time'][i] as Map<String, dynamic>)['startTime'],
          'endTime': (data['_temp_time'][i] as Map<String, dynamic>)['endTime'],
        });
      }
      data.remove('_temp_time');
    } catch (e, s) {
      CrashlyticsUtil.instance
          .recordError(e, s, reason: 'Final merge error: $tmpCourseName');
    }

    return data;
  }
}
