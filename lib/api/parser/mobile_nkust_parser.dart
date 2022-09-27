import 'dart:convert';

import 'package:ap_common/models/course_data.dart';
import 'package:ap_common/models/score_data.dart';
import 'package:ap_common/models/user_info.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:html/parser.dart' as html;
import 'package:nkust_ap/models/midterm_alerts_data.dart';

class MobileNkustParser {
  static List<Map<String, dynamic>> busViolationRecords(
    String rawHtml, {
    required bool paidStatus,
  }) {
    final document = html.parse(rawHtml);
    List<Map<String, dynamic>> result = [];
    var format = DateFormat('yyyy/MM/dd HH:mm');

    for (var trElement in document.getElementsByTagName('tr')) {
      Map<String, dynamic> _temp = {};

      var tdElements = trElement.getElementsByTagName('td');
      var timeElement = tdElements[1].getElementsByTagName('div')[0];
      _temp['isPayment'] = paidStatus;
      var startAndGoal = tdElements[3].text.split(" 到 ");
      _temp['startStation'] = startAndGoal[0];
      _temp['endStation'] = startAndGoal[1];
      _temp['amountend'] = int.parse(tdElements[4].text);
      _temp['homeCharteredBus'] = false;

      _temp['time'] = format.parse(
          '${timeElement.text.substring(0, 10)} ${timeElement.text.substring(14)}');
      result.add(_temp);
    }
    return result;
  }

  static List<Map<String, dynamic>> busUserRecords(
    String rawHtml, {
    required String startStation,
    required String endStation,
  }) {
    final document = html.parse(rawHtml);
    List<Map<String, dynamic>> result = [];

    for (var trElement in document.getElementsByTagName('tr')) {
      Map<String, dynamic> _temp = {};
      _temp['cancelKey'] =
          trElement.getElementsByTagName("input")[0].attributes['value'];
      var tdElements = trElement.getElementsByTagName('td');

      _temp['dateTime'] =
          '${tdElements[1].text.substring(0, 10)} ${tdElements[1].text.substring(14)}';
      _temp['state'] = "";
      _temp['travelState'] = "";
      _temp['start'] = startStation;
      _temp['end'] = endStation;
      result.add(_temp);
    }

    return result;
  }

  static CourseData courseTable(rawHtml) {
    final document = html.parse(rawHtml);

    Map<String, dynamic> result = {
      "courses": [],
      'timeCodes': [],
    };
    var inputElements = document.getElementsByTagName("input");
    var coursesJson = jsonDecode(inputElements[0].attributes['value']!);
    var periodTimeJson = jsonDecode(inputElements[1].attributes['value']!);

    periodTimeJson.forEach((periodTime) {
      result["timeCodes"].add({
        "title": "第${periodTime["PeriodName"]}節",
        "startTime":
            "${periodTime["BegTime"].substring(0, 2)}:${periodTime["BegTime"].substring(2, 4)}",
        "endTime":
            "${periodTime["EndTime"].substring(0, 2)}:${periodTime["EndTime"].substring(2, 4)}",
      });
    });

    coursesJson.forEach((course) {
      var _temp = {
        "code": course['SelectCode'].toString(),
        "title": course['CourseName'].toString(),
        "className": course['ClassNameAbr'].toString(),
        "group": course['CourseGroup'].toString(),
        "units": course['Credit'].toString(),
        "hours": course['Hour'].toString(),
        "required": course['OptionName'].toString(),
        "at": course['Annual'],
        "sectionTimes": [],
        "instructors": course['TeacherName'].split(","),
        "location": {
          "building": "",
          "room": course['CourseRoom'] ?? "",
        }
      };
      final hasMorning = periodTimeJson[0]["PeriodName"] == "M";
      for (var time in course['CourseWeekPeriod']) {
        final weekday = int.tryParse(time['CourseWeek']) ?? 0;
        final sectionIndex = int.tryParse(time['CoursePeriod']);
        if (weekday <= 0 || weekday > 7 || sectionIndex == null) continue;
        _temp['sectionTimes'].add(
          {
            "weekday": weekday,
            "index": sectionIndex - (hasMorning ? 0 : 1),
          },
        );
      }
      result["courses"].add(_temp);
    });

    return CourseData.fromJson(result);
  }

  static MidtermAlertsData midtermAlerts(rawHtml) {
    //TODO Implement Midterm Alerts Parser for mobile nkust
    final midtermAlertsData = MidtermAlertsData(courses: []);
    return midtermAlertsData;
  }

  static Map<String, dynamic> busInfo(
    String? rawHtml,
  ) {
    var document = html.parse(rawHtml);
    String canNotReserveText =
        document.getElementById('BusMemberStop')!.attributes['value']!;
    bool canReserve = !bool.fromEnvironment(
      canNotReserveText,
      defaultValue: false,
    );
    var elements =
        document.getElementsByClassName('alert alert-danger alert-dismissible');
    String description = '';
    if (elements.length > 0) {
      description = elements.first.text;
    }
    return {
      'canReserve': canReserve,
      'description': description.trim().replaceAll(' ', ''),
    };
  }

  static List<Map<String, dynamic>> busTimeTable(
    rawHtml, {
    String? time,
    String? startStation,
    String? endStation,
  }) {
    var document = html.parse(rawHtml);

    List<Map<String, dynamic>> result = [];

    for (var trElement in document.getElementsByTagName('tr').sublist(1)) {
      Map<String, dynamic> _temp = {};

      // Element can't get ById. so build new parser object.
      var _inputDocument = html.parse(trElement.outerHtml);
      _temp['canBook'] = true;

      if (_inputDocument.getElementById('ReserveEnable')!.attributes['value'] ==
          null) {
        //can't book.
        _temp['canBook'] = false;
      }
      _temp['busId'] =
          _inputDocument.getElementById('BusId')!.attributes['value'];
      _temp['cancelKey'] =
          _inputDocument.getElementById('ReserveId')!.attributes['value'];
      _temp['isReserve'] = (_inputDocument
                  .getElementById('ReserveStateCode')!
                  .attributes['value'] ==
              '0' &&
          _inputDocument.getElementById('ReserveId')!.attributes['value'] !=
              '0');

      var tdElements = trElement.getElementsByTagName('td').sublist(1);

      var format = DateFormat('yyyy/MM/dd HH:mm');

      _temp['departureTime'] =
          format.parse('$time ${tdElements[0].text}').toIso8601String();
      _temp['reserveCount'] = int.parse(tdElements[1].text);
      _temp['homeCharteredBus'] = false;
      _temp['specialTrain'] = '';
      _temp['description'] = '';
      _temp['startStation'] = startStation;
      _temp['endStation'] = endStation;
      _temp['limitCount'] = 999;

      if (tdElements[2].text != '') {
        if (tdElements[2].getElementsByTagName('button').isNotEmpty) {
          var _typeString = tdElements[2]
              .getElementsByTagName('button')[0]
              .text
              .replaceAll(' ', '')
              .replaceAll('\n', '');
          if (_typeString == '返鄉專車') {
            _temp['homeCharteredBus'] = true;
          }
          if (_typeString == '試辦專車') {
            _temp['specialTrain'] = '2';
          }
          _temp['description'] = tdElements[2]
              .getElementsByTagName('button')[0]
              .attributes['data-content'];
        }
      }
      result.add(_temp);
    }
    return result;
  }

  static ScoreData scores(rawHtml) {
    final document = html.parse(rawHtml);
    // generate scores list
    if (document.getElementById("datatable") == null) {
      return ScoreData.empty();
    }
    List<Map<String, dynamic>> scoresList = [];
    //skip table header
    var _trElements =
        document.getElementById("datatable")!.getElementsByTagName('tr');
    if (_trElements.length <= 1) {
      return ScoreData.empty();
    }

    for (var trElement in _trElements.sublist(1)) {
      // select td element
      var tdElements = trElement.getElementsByTagName("td");

      if (tdElements.length < 8) {
        // continue;
        return ScoreData.empty();
      }
      scoresList.add({
        "title": tdElements.elementAt(0).text,
        "units": tdElements.elementAt(1).text,
        "hours": tdElements.elementAt(2).text,
        "required": tdElements.elementAt(3).text,
        "at": tdElements.elementAt(4).text,
        "middleScore": tdElements.elementAt(5).text,
        "semesterScore": tdElements.elementAt(6).text,
        "remark": tdElements.elementAt(7).text,
      });
    }

    //detail data
    Map<String, dynamic> detailData = {};
    var detailDiv = document.getElementsByClassName("text-bold text-info");
    if (detailDiv == null) {
      return ScoreData.empty();
    }
    if (detailDiv.length < 4) {
      return ScoreData.empty();
    }
    detailData["average"] = detailDiv
        .elementAt(0)
        .parent!
        .text
        .replaceAll(detailDiv.elementAt(0).text, "")
        .replaceAll("\n", "")
        .replaceAll(" ", "");
    detailData["average"] = double.parse(detailData["average"]);
    detailData["conduct"] = detailDiv
        .elementAt(1)
        .parent!
        .text
        .replaceAll(detailDiv.elementAt(1).text, "")
        .replaceAll("\n", "")
        .replaceAll(" ", "");
    detailData["conduct"] = double.parse(detailData["conduct"]);
    detailData["classRank"] = detailDiv
        .elementAt(2)
        .parent!
        .text
        .replaceAll(detailDiv.elementAt(2).text, "")
        .replaceAll("\n", "")
        .replaceAll(" ", "");

    detailData["departmentRank"] = detailDiv
        .elementAt(3)
        .parent!
        .text
        .replaceAll(detailDiv.elementAt(3).text, "")
        .replaceAll("\n", "")
        .replaceAll(" ", "");

    return ScoreData.fromJson({
      "scores": scoresList,
      "detail": detailData,
    });
  }

  static UserInfo userInfo(rawHtml) {
    final document = html.parse(rawHtml);
    final list = document.getElementsByClassName('user-header');
    if (list.length > 0) {
      final p = list[0].getElementsByTagName('p');
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

  static String? getCSRF(rawHtml) {
    final document = html.parse(rawHtml);
    for (var inputElement in document.getElementsByTagName("input")) {
      if (((inputElement.attributes)['name'] ?? "") ==
          "__RequestVerificationToken") {
        return inputElement.attributes['value'];
      }
    }
    return "";
  }
}
