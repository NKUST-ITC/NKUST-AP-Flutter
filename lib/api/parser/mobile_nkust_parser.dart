import 'dart:convert';

import 'package:ap_common/models/course_data.dart';
import 'package:ap_common/models/score_data.dart';
import 'package:ap_common/models/user_info.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:nkust_ap/models/midterm_alerts_data.dart';

class MobileNkustParser {
  static List<Map<String, dynamic>> busViolationRecords(
    String rawHtml, {
    required bool paidStatus,
  }) {
    final Document document = html.parse(rawHtml);
    final List<Map<String, dynamic>> result = <Map<String, dynamic>>[];
    final DateFormat format = DateFormat('yyyy/MM/dd HH:mm');

    for (final Element trElement in document.getElementsByTagName('tr')) {
      final Map<String, dynamic> temp = <String, dynamic>{};

      final List<Element> tdElements = trElement.getElementsByTagName('td');
      final Element timeElement = tdElements[1].getElementsByTagName('div')[0];
      temp['isPayment'] = paidStatus;
      final List<String> startAndGoal = tdElements[3].text.split(' 到 ');
      temp['startStation'] = startAndGoal[0];
      temp['endStation'] = startAndGoal[1];
      temp['amountend'] = int.parse(tdElements[4].text);
      temp['homeCharteredBus'] = false;

      temp['time'] = format.parse(
        '${timeElement.text.substring(0, 10)} '
        '${timeElement.text.substring(14)}',
      );
      result.add(temp);
    }
    return result;
  }

  static List<Map<String, dynamic>> busUserRecords(
    String rawHtml, {
    required String startStation,
    required String endStation,
  }) {
    final Document document = html.parse(rawHtml);
    final List<Map<String, dynamic>> result = <Map<String, dynamic>>[];

    for (final Element trElement in document.getElementsByTagName('tr')) {
      final Map<String, dynamic> temp = <String, dynamic>{};
      temp['cancelKey'] =
          trElement.getElementsByTagName('input')[0].attributes['value'];
      final List<Element> tdElements = trElement.getElementsByTagName('td');

      temp['dateTime'] = '${tdElements[1].text.substring(0, 10)} '
          '${tdElements[1].text.substring(14)}';
      temp['state'] = '';
      temp['travelState'] = '';
      temp['start'] = startStation;
      temp['end'] = endStation;
      result.add(temp);
    }

    return result;
  }

  static CourseData courseTable(dynamic rawHtml) {
    final Document document = html.parse(rawHtml);

    final Map<String, dynamic> result = <String, dynamic>{
      'courses': <Map<String, dynamic>>[],
      'timeCodes': <Map<String, dynamic>>[],
    };
    final List<Element> inputElements = document.getElementsByTagName('input');
    final List<Map<String, dynamic>> coursesJson =
        jsonDecode(inputElements[0].attributes['value']!)
            as List<Map<String, dynamic>>;
    final List<Map<String, dynamic>> periodTimeJson =
        jsonDecode(inputElements[1].attributes['value']!)
            as List<Map<String, dynamic>>;

    for (final Map<String, dynamic> periodTime in periodTimeJson) {
      (result['timeCodes'] as List<Map<String, dynamic>>).add(
        <String, dynamic>{
          'title': "第${periodTime["PeriodName"]}節",
          'startTime':
              //ignore: avoid_dynamic_calls
              "${periodTime["BegTime"].substring(0, 2)}:${periodTime["BegTime"].substring(2, 4)}",
          'endTime':
              //ignore: avoid_dynamic_calls
              "${periodTime["EndTime"].substring(0, 2)}:${periodTime["EndTime"].substring(2, 4)}",
        },
      );
    }

    for (final Map<String, dynamic> course in coursesJson) {
      final Map<String, dynamic> temp = <String, dynamic>{
        'code': course['SelectCode'].toString(),
        'title': course['CourseName'].toString(),
        'className': course['ClassNameAbr'].toString(),
        'group': course['CourseGroup'].toString(),
        'units': course['Credit'].toString(),
        'hours': course['Hour'].toString(),
        'required': course['OptionName'].toString(),
        'at': course['Annual'],
        'sectionTimes': <Map<String, dynamic>>[],
        'instructors': (course['TeacherName'] as String).split(','),
        'location': <String, dynamic>{
          'building': '',
          'room': course['CourseRoom'] ?? '',
        }
      };
      final bool hasMorning = periodTimeJson[0]['PeriodName'] == 'M';
      for (final dynamic time in course['CourseWeekPeriod']) {
        //ignore: avoid_dynamic_calls
        final int weekday = int.tryParse(time['CourseWeek'] as String) ?? 0;
        //ignore: avoid_dynamic_calls
        final int? sectionIndex = int.tryParse(time['CoursePeriod'] as String);
        if (weekday <= 0 || weekday > 7 || sectionIndex == null) continue;
        (temp['sectionTimes'] as List<Map<String, dynamic>>).add(
          <String, dynamic>{
            'weekday': weekday,
            'index': sectionIndex - (hasMorning ? 0 : 1),
          },
        );
      }
      (result['courses'] as List<Map<String, dynamic>>).add(temp);
    }

    return CourseData.fromJson(result);
  }

  static MidtermAlertsData midtermAlerts(dynamic rawHtml) {
    //TODO Implement Midterm Alerts Parser for mobile nkust
    final MidtermAlertsData midtermAlertsData = MidtermAlertsData(
      courses: <MidtermAlerts>[],
    );
    return midtermAlertsData;
  }

  static Map<String, dynamic> busInfo(
    String? rawHtml,
  ) {
    final Document document = html.parse(rawHtml);
    final String canNotReserveText =
        document.getElementById('BusMemberStop')!.attributes['value']!;
    final bool canReserve = !bool.fromEnvironment(
      canNotReserveText,
    );
    final List<Element> elements =
        document.getElementsByClassName('alert alert-danger alert-dismissible');
    String description = '';
    if (elements.isNotEmpty) {
      description = elements.first.text;
    }
    return <String, dynamic>{
      'canReserve': canReserve,
      'description': description.trim().replaceAll(' ', ''),
    };
  }

  static List<Map<String, dynamic>> busTimeTable(
    dynamic rawHtml, {
    String? time,
    String? startStation,
    String? endStation,
  }) {
    final Document document = html.parse(rawHtml);

    final List<Map<String, dynamic>> result = <Map<String, dynamic>>[];

    for (final Element trElement
        in document.getElementsByTagName('tr').sublist(1)) {
      final Map<String, dynamic> temp = <String, dynamic>{};

      // Element can't get ById. so build new parser object.
      final Document inputDocument = html.parse(trElement.outerHtml);
      temp['canBook'] = true;

      if (inputDocument.getElementById('ReserveEnable')!.attributes['value'] ==
          null) {
        //can't book.
        temp['canBook'] = false;
      }
      temp['busId'] =
          inputDocument.getElementById('BusId')!.attributes['value'];
      temp['cancelKey'] =
          inputDocument.getElementById('ReserveId')!.attributes['value'];
      temp['isReserve'] = inputDocument
                  .getElementById('ReserveStateCode')!
                  .attributes['value'] ==
              '0' &&
          inputDocument.getElementById('ReserveId')!.attributes['value'] != '0';

      final List<Element> tdElements =
          trElement.getElementsByTagName('td').sublist(1);

      final DateFormat format = DateFormat('yyyy/MM/dd HH:mm');

      temp['departureTime'] =
          format.parse('$time ${tdElements[0].text}').toIso8601String();
      temp['reserveCount'] = int.parse(tdElements[1].text);
      temp['homeCharteredBus'] = false;
      temp['specialTrain'] = '';
      temp['description'] = '';
      temp['startStation'] = startStation;
      temp['endStation'] = endStation;
      temp['limitCount'] = 999;

      if (tdElements[2].text != '') {
        if (tdElements[2].getElementsByTagName('button').isNotEmpty) {
          final String typeString = tdElements[2]
              .getElementsByTagName('button')[0]
              .text
              .replaceAll(' ', '')
              .replaceAll('\n', '');
          if (typeString == '返鄉專車') {
            temp['homeCharteredBus'] = true;
          }
          if (typeString == '試辦專車') {
            temp['specialTrain'] = '2';
          }
          temp['description'] = tdElements[2]
              .getElementsByTagName('button')[0]
              .attributes['data-content'];
        }
      }
      result.add(temp);
    }
    return result;
  }

  static ScoreData scores(dynamic rawHtml) {
    final Document document = html.parse(rawHtml);
    // generate scores list
    if (document.getElementById('datatable') == null) {
      return ScoreData.empty();
    }
    final List<Map<String, dynamic>> scoresList = <Map<String, dynamic>>[];
    //skip table header
    final List<Element> trElements =
        document.getElementById('datatable')!.getElementsByTagName('tr');
    if (trElements.length <= 1) {
      return ScoreData.empty();
    }

    for (final Element trElement in trElements.sublist(1)) {
      // select td element
      final List<Element> tdElements = trElement.getElementsByTagName('td');

      if (tdElements.length < 8) {
        // continue;
        return ScoreData.empty();
      }
      scoresList.add(<String, String>{
        'title': tdElements.elementAt(0).text,
        'units': tdElements.elementAt(1).text,
        'hours': tdElements.elementAt(2).text,
        'required': tdElements.elementAt(3).text,
        'at': tdElements.elementAt(4).text,
        'middleScore': tdElements.elementAt(5).text,
        'semesterScore': tdElements.elementAt(6).text,
        'remark': tdElements.elementAt(7).text,
      });
    }

    //detail data
    final Map<String, dynamic> detailData = <String, dynamic>{};
    final List<Element> detailDiv =
        document.getElementsByClassName('text-bold text-info');

    if (detailDiv.length < 4) {
      return ScoreData.empty();
    }
    detailData['average'] = detailDiv
        .elementAt(0)
        .parent!
        .text
        .replaceAll(detailDiv.elementAt(0).text, '')
        .replaceAll('\n', '')
        .replaceAll(' ', '');
    detailData['average'] = double.parse(detailData['average'] as String);
    detailData['conduct'] = detailDiv
        .elementAt(1)
        .parent!
        .text
        .replaceAll(detailDiv.elementAt(1).text, '')
        .replaceAll('\n', '')
        .replaceAll(' ', '');
    detailData['conduct'] = double.parse(detailData['conduct'] as String);
    detailData['classRank'] = detailDiv
        .elementAt(2)
        .parent!
        .text
        .replaceAll(detailDiv.elementAt(2).text, '')
        .replaceAll('\n', '')
        .replaceAll(' ', '');

    detailData['departmentRank'] = detailDiv
        .elementAt(3)
        .parent!
        .text
        .replaceAll(detailDiv.elementAt(3).text, '')
        .replaceAll('\n', '')
        .replaceAll(' ', '');

    return ScoreData.fromJson(
      <String, dynamic>{
        'scores': scoresList,
        'detail': detailData,
      },
    );
  }

  static UserInfo userInfo(dynamic rawHtml) {
    final Document document = html.parse(rawHtml);
    final List<Element> list = document.getElementsByClassName('user-header');
    if (list.isNotEmpty) {
      final List<Element> p = list[0].getElementsByTagName('p');
      if (p.length >= 2) {
        return UserInfo(
          id: p[0].text.split(' ').first,
          department: p[0].text.split(' ').last,
          name: p[1].text,
        );
      }
    }
    return UserInfo.empty();
  }

  static String getCSRF(dynamic rawHtml) {
    final Document document = html.parse(rawHtml);
    for (final Element inputElement in document.getElementsByTagName('input')) {
      if (((inputElement.attributes)['name'] ?? '') ==
          '__RequestVerificationToken') {
        return inputElement.attributes['value']!;
      }
    }
    return '';
  }
}
