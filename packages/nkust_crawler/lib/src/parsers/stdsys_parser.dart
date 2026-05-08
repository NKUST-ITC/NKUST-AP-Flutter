import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:ap_common_core/ap_common_core.dart';
import 'package:nkust_crawler/src/abstractions/crash_reporter.dart';
import 'package:nkust_crawler/src/parsers/parser_utils.dart';

class StdsysParser {
  static StdsysParser? _instance;

  // ignore: prefer_constructors_over_static_methods
  static StdsysParser get instance {
    return _instance ??= StdsysParser();
  }

  /// Sink for parser-level errors. See [CrashReporter] for rationale.
  CrashReporter reporter = const NoOpCrashReporter();

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

    final List<Element> rows = document.querySelectorAll('tbody > tr');

    final List<Map<String, dynamic>> courses = [];

    // 節次對應 index
    final List<String> timeKeys = [
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

    // 星期對應
    final Map<String, int> weekdayMap = {
      '一': 1,
      '二': 2,
      '三': 3,
      '四': 4,
      '五': 5,
      '六': 6,
      '日': 7
    };

    for (final Element row in rows) {
      final List<Element> cells = row.querySelectorAll('td');

      // 忽略最後一列「總學分數」
      if (cells.length < 9) continue;

      final String code = cells[0].text.trim();
      final String title = cells[1].text.trim();
      final String required = cells[2].text.trim();
      final String units = cells[3].text.trim();
      final String className = cells[4].text.trim();
      final String timeStr = cells[5].text.trim();
      final String locationStr = cells[6].text.trim();
      final String teacherStr = cells[7].text.trim();

      // 略過沒有上課時間的課程（如線上通識）
      if (timeStr.isEmpty) continue;

      // 教師名稱
      final List<String> instructors = teacherStr
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // 上課地點
      final String room = locationStr;

      // 上課時間
      final List<Map<String, int>> sectionTimes = [];

      final RegExp exp =
          RegExp(r'\((一|二|三|四|五|六|日)\)([A-Z0-9]+(?:-[A-Z0-9]+)?)');
      final Iterable<RegExpMatch> matches = exp.allMatches(timeStr);

      for (final RegExpMatch match in matches) {
        final String wd = match.group(1)!;
        final String periods = match.group(2)!;
        final int weekday = weekdayMap[wd]!;

        if (periods.contains('-')) {
          // 某節到某節，如 3-4 或 5-7
          final List<String> parts = periods.split('-');
          final int startIdx = timeKeys.indexOf(parts[0]);
          final int endIdx = timeKeys.indexOf(parts[1]);

          if (startIdx != -1 && endIdx != -1) {
            for (int i = startIdx; i <= endIdx; i++) {
              sectionTimes.add({'weekday': weekday, 'index': i});
            }
          }
        } else {
          // 單一節次，如 A
          final int idx = timeKeys.indexOf(periods);
          if (idx != -1) {
            sectionTimes.add({'weekday': weekday, 'index': idx});
          }
        }
      }

      courses.add({
        'code': code,
        'title': title,
        'className': className,
        'group': '',
        'units': units,
        'hours': '',
        'required': required,
        'at': '',
        'sectionTimes': sectionTimes,
        'location': {'building': '', 'room': room},
        'instructors': instructors,
      });
    }

    final List<Map<String, dynamic>> timeCodes = [
      {'title': 'M', 'startTime': '07:10', 'endTime': '08:00'},
      {'title': '1', 'startTime': '08:10', 'endTime': '09:00'},
      {'title': '2', 'startTime': '09:10', 'endTime': '10:00'},
      {'title': '3', 'startTime': '10:10', 'endTime': '11:00'},
      {'title': '4', 'startTime': '11:10', 'endTime': '12:00'},
      {'title': 'A', 'startTime': '12:10', 'endTime': '13:00'},
      {'title': '5', 'startTime': '13:30', 'endTime': '14:20'},
      {'title': '6', 'startTime': '14:30', 'endTime': '15:20'},
      {'title': '7', 'startTime': '15:30', 'endTime': '16:20'},
      {'title': '8', 'startTime': '16:30', 'endTime': '17:20'},
      {'title': '9', 'startTime': '17:30', 'endTime': '18:20'},
      {'title': '10', 'startTime': '18:30', 'endTime': '19:20'},
      {'title': '11', 'startTime': '19:25', 'endTime': '20:15'},
      {'title': '12', 'startTime': '20:20', 'endTime': '21:10'},
      {'title': '13', 'startTime': '21:15', 'endTime': '22:05'}
    ];

    return {
      'courses': courses,
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
        reporter.recordError(e, s, reason: 'Parse grid failed');
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
      reporter.recordError(e, s, reason: 'Final merge error: $tmpCourseName');
    }

    return data;
  }

  static UserInfo userInfoParser(dynamic rawHtml) {
    final Document document = parse(rawHtml);

    String? name;
    String? educationSystem;
    String? department;
    String? className;
    String? id;

    for (final Element item in document.querySelectorAll('.info-item')) {
      final String label =
          item.querySelector('.info-label')?.text.trim() ?? '';
      final String value =
          item.querySelector('.info-value')?.text.trim() ?? '';

      switch (label) {
        case '姓名':
          name = value;
        case '學制':
          educationSystem = value;
        case '科系':
          department = value;
        case '班級':
          className = value;
        case '學號':
          id = value;
      }
    }

    final Element? img = document.querySelector('img.student-photo');
    final String? src = img?.attributes['src'];
    final String? pictureUrl =
        src == null ? null : 'https://stdsys.nkust.edu.tw$src';

    return UserInfo(
      name: name ?? '',
      department: department ?? '',
      id: id ?? '',
      educationSystem: educationSystem,
      className: className,
      pictureUrl: pictureUrl,
    );
  }

  Map<String, dynamic> semesterParser(String? rawJson) {
    final Map<String, dynamic> apiData =
        json.decode(rawJson!) as Map<String, dynamic>;
    final List<dynamic> result = (apiData['result'] as List<dynamic>?) ?? [];

    final List<Map<String, dynamic>> semesters = result.map((dynamic item) {
      final String text = item['text'].toString();
      final String value = item['value'].toString();
      final List<String> parts = value.split('-');
      final String year = parts[0];
      final String val = parts[1];

      return {
        'year': year,
        'value': val,
        'text': text,
      };
    }).toList();

    final Map<String, dynamic>? defaultSemester =
        semesters.isNotEmpty ? semesters.first : null;

    final Map<String, dynamic> semesterDataJson = {
      'data': semesters,
      'default': defaultSemester,
      'currentIndex': 0,
    };

    return semesterDataJson;
  }

  Map<String, dynamic> scoresParser(String rawstr) {
    final List<String> lines = rawstr
        .split('\n')
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList();

    final List<Map<String, dynamic>> scores = <Map<String, dynamic>>[];
    final Map<String, dynamic> detail = <String, dynamic>{
      'conduct': 0.0,
      'classRank': '',
      'departmentRank': '',
      'average': 0.0,
    };

    int beginLine = 14;

    for (int i = 0; i < lines.length - 1; i++) {
      final String line = lines[i];

      if (line.contains('課程名稱')) {
        beginLine = i + 4;
      } else if (line.contains('操行成績：')) {
        detail['conduct'] = double.tryParse(lines[i + 1]) ?? 0.0;
      } else if (line.contains('班 排 名：')) {
        final RegExpMatch? match =
            RegExp(r'班\s*排\s*名：\s*(\d+)\s*/\s*(\d+)').firstMatch(line);
        detail['classRank'] =
            match != null ? '${match.group(1)}/${match.group(2)}' : '';
      } else if (line.contains('學業成績：')) {
        detail['average'] = double.tryParse(lines[i + 1]) ?? 0.0;
      }
    }

    for (int i = beginLine; i + 3 < lines.length; i = i + 4) {
      final Map<String, dynamic> score = <String, dynamic>{
        'title': '',
        'units': '',
        'hours': '',
        'required': '',
        'at': '',
        'middleScore': '',
        'semesterScore': '',
        'remark': '',
      };

      if (lines[i].contains('-----')) {
        break;
      }

      score['title'] = lines[i];
      score['required'] = lines[i + 1];
      score['units'] = lines[i + 2];
      score['semesterScore'] = lines[i + 3];

      scores.add(score);
    }

    final Map<String, dynamic> data = <String, dynamic>{
      'scores': scores,
      'detail': detail,
    };

    return data;
  }
}
