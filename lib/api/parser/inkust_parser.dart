import 'dart:convert';

import 'package:ap_common/models/semester_data.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/models/leave_submit_data.dart';
//ignore_for_file: avoid_dynamic_calls, always_specify_types, lines_longer_than_80_chars

Map<String, dynamic> inkustCourseTableParser(Map<String, dynamic> data) {
  final Map<String, dynamic> result = {
    'courses': [],
    'timeCodes': [],
  };
  //timeCodes parse
  data['data']['time'].forEach((element) {
    result['timeCodes'].add({
      'title': "第${element["periodName"]}節",
      'startTime':
          "${element["begTime"].substring(0, 2)}:${element["begTime"].substring(2, 4)}",
      'endTime':
          "${element["endTime"].substring(0, 2)}:${element["endTime"].substring(2, 4)}",
    });
  });

  //courses parse
  data['data']['course'].forEach((element) {
    final List<Map<String, dynamic>> times = [];
    element['courseTimeData'].forEach((courseTime) {
      times.add({
        'weekday': int.parse(courseTime['courseWeek'] as String),
        'index': int.parse(courseTime['coursePeriod'] as String),
      });
    });
    result['courses'].add({
      'code': '',
      'title': element['courseName'],
      'className': element['className'],
      'group': element['courseGroup'],
      'units': element['courseCredit'],
      'hours': element['courseHour'],
      'required': element['courseOption'],
      'at': element['courseAnnual'],
      'sectionTimes': times,
      'location': {'room': element['courseRoom']},
      'instructors': [element['courseTeacher']]
    });
  });
  return result;
}

Future<Map<String, dynamic>> inkustBusUserRecordsParser(
  List<Future<Response>> responseList,
) async {
  final Map<String, dynamic> returnData = {'data': []};

  final List<dynamic> dataList = [];

  await Future.forEach(responseList, (Future<Response> e) async {
    final Response temp = await e;
    Map<String, dynamic>? data;
    if (temp.data is String &&
        (temp.headers['Content-Type']! as String)[0].contains('text/html')) {
      data = jsonDecode(temp.data as String) as Map<String, dynamic>;
    } else if (temp.data is Map<String, dynamic>) {
      data = temp.data as Map<String, dynamic>;
    }
    if (data!['success'] as bool) {
      dataList.addAll(data['data'] as List<dynamic>);
    }
  });
  final DateFormat format = DateFormat('yyyy/MM/dd HH:mm');

  for (final element in dataList) {
    returnData['data'].add({
      'dateTime': format.parse(element['driveTime'] as String),
      'endTime': format.parse(element['resEndTime'] as String),
      'cancelKey': element['resId'].toString(),
      'start': element['startStation'],
      'end': element['endStation'],
      'state': element['stateCode'].toString(),
      'travelState': element['specialBus'].toString()
    });
  }
  return returnData;
}

Map<String, dynamic> inkustBusTimeTableParser(
  String queryDate,
  List<dynamic> data,
  BusReservationsData userRecords,
) {
  final List<Map<String, dynamic>> mapList = [];

  final DateFormat format = DateFormat('yyyy/MM/dd HH:mm');

  for (int i = 0; i < data.length; i++) {
    final Map<String, dynamic> temp = {
      'endEnrollDateTime': DateTime.now().toIso8601String(),
      'departureTime':
          format.parse("$queryDate ${data[i]['driveTime']}").toIso8601String(),
      'startStation': data[i]['startStation'],
      'endStation': data[i]['endStation'],
      'busId': data[i]['busId'].toString(),
      'reserveCount': int.parse(data[i]['resCount'].toString()),
      'limitCount': int.parse(data[i]['limitCount'].toString()),
      'isReserve': false,
      'specialTrain': data[i]['specialBus'].toString(),
      'description': data[i]['specialMsg'],
      'homeCharteredBus': false,
      'cancelKey': '',
      'canBook': data[i]['resEnable']
    };
    if (data[i]['resName'] == '已預約') {
      temp['isReserve'] = true;
    }

    if (data[i]['resEnable'] == false) {
      temp['endEnrollDateTime'] = DateTime(1970);
    }

    if (temp['SpecialTrain'] == '1') {
      temp['homeCharteredBus'] = true;
    }
    if (userRecords.reservations.isNotEmpty) {
      for (final BusReservation element in userRecords.reservations) {
        if (element.dateTime == temp['departureTime'] &&
            element.start == temp['startStation']) {
          temp['cancelKey'] = element.cancelKey;
        }
      }
    }

    mapList.add(temp);
  }
  final Map<String, dynamic> returnData = {'data': mapList};
  return returnData;
}

Map<String, dynamic> inkustBusViolationRecordsParser(
  Map<String, dynamic> data,
) {
  final List<Map<String, dynamic>> mapList = [];
  final DateFormat format = DateFormat('yyyy/MM/dd HH:mm');

  data['data'].forEach((e) {
    final Map<String, dynamic> temp = {
      'time': format.parse(e['driveTime'] as String),
      'startStation': e['startStation'],
      'endStation': e['endStation'],
      'amountend': e['money'],
      'isPayment': e['stateCode'],
      'homeCharteredBus': false,
    };
    if (e['specialBus'] == '1') {
      e['homeCharteredBus'] = true;
    }
    mapList.add(temp);
  });
  return {'reservation': mapList};
}

Map<String, dynamic> inkustgetAbsentRecordsParser(
  Map<String, dynamic> data, {
  List? timeCodes,
}) {
  final List<Map<String, dynamic>> result = [];
  if (data['success'] == false || (data['count'] as int) < 1) {
    // return null;
    return {'data': [], 'timeCodes': []};
  }
  final List<Map<String, dynamic>> list =
      data['data'] as List<Map<String, dynamic>>;
  final List<dynamic> timeCodeData = [
    if (timeCodes != null) ...timeCodes,
  ];
  if (timeCodes == null) {
    if (((list[0])['Detail'] ?? false) != false &&
        (list[0]['Detail'] as Map<String, dynamic>).isNotEmpty) {
      list[0]['Detail'][0].forEach((key, value) {
        if (key != 'TranCode' && key != 'leaveday') {
          timeCodeData.add(key);
        }
      });
    } else {
      //lost timeCode
      // return null;
      return {'data': [], 'timeCodes': []};
    }
  }

  for (int i = 0; i < list.length; i++) {
    for (int dayLeaves = 0;
        dayLeaves < (list[i]['Detail'] as Map<String, dynamic>).length;
        dayLeaves++) {
      final Map<String, dynamic> temp = {
        'leaveSheetId': list[i]['LeaveCode'] ?? '',
        'date': '',
        'instructorsComment': list[i]['LeaveTeaSuggest'] ?? '',
        'sections': []
      };

      int index = 0;
      list[i]['Detail'][dayLeaves].forEach((key, String value) {
        if (key == 'leaveday') {
          temp['date'] = value;
        }
        if (key != 'TranCode' && key != 'leaveday') {
          value = value.replaceAll('　', '').replaceAll(' ', '');
          if (value.isNotEmpty) {
            temp['sections'].add({
              'section': timeCodeData[index],
              'reason': value,
            });
          }
          index++;
        }
      });

      result.add(temp);
    }
  }
  return {'data': result, 'timeCodes': timeCodeData};
}

Map<String, dynamic> inkustGetLeaveSubmitInfoParser(
  Map<String, dynamic>? leaveTypeOptionData,
  Map<String, dynamic> totorRecordsData,
  List<dynamic> timeCodes,
) {
  final Map<String, dynamic> result = {
    'tutor': null,
    'type': [],
    'timeCodes': [],
  };

  if (!(totorRecordsData['success'] as bool) ||
      !(leaveTypeOptionData!['success'] as bool)) {
    return result;
  }
  if (totorRecordsData['data']['choose'] != '' &&
      totorRecordsData['data']['enable'] == false) {
    result['tutor'] = {'name': '', 'id': ''};
    result['tutor']['id'] = totorRecordsData['data']['choose'].toString();
    for (int i = 0;
        i < (totorRecordsData['data']['teacher'] as List<dynamic>).length;
        i++) {
      if (totorRecordsData['data']['teacher'][i]['emp_id'] ==
          result['tutor']['id']) {
        result['tutor']['name'] =
            totorRecordsData['data']['teacher'][i]['emp_name'];
        break;
      }
    }
  }

  leaveTypeOptionData['data']['leaveTypeOption'].forEach((value) {
    result['type'].add({
      'title': value['leave_name'],
      'id': value['leave_id'],
    });
  });

  result['timeCodes'] = timeCodes;
  return result;
}

List<Map<String, dynamic>> inkustLeaveDataParser({
  required LeaveSubmitData submitDatas,
  required SemesterData? semester,
  required String? stdId,
  required bool proofImageExists,
  required List timeCode,
}) {
  final DateFormat dateFormat = DateFormat('yyyy/M/dd');
  // continuous days check
  final List<LeaveSubmitData> submitDataList = <LeaveSubmitData>[];
  int tempIndex = 0;
  for (int i = 0; i < submitDatas.days.length - 1; i++) {
    final Duration dayDiff = dateFormat
        .parse(submitDatas.days[i].day!)
        .difference(dateFormat.parse(submitDatas.days[i + 1].day!));
    if (dayDiff < const Duration(hours: -25)) {
      // Need split leave submit
      final Map<String, dynamic> splitSubmitData = submitDatas.toJson();
      splitSubmitData['days'] =
          splitSubmitData['days'].getRange(tempIndex, i + 1);
      submitDataList.add(LeaveSubmitData.fromJson(splitSubmitData));

      tempIndex = i + 1;
    }
  }
  if (tempIndex != 0) {
    //add last submit data
    final Map<String, dynamic> splitSubmitData = submitDatas.toJson();
    splitSubmitData['days'] =
        splitSubmitData['days'].getRange(tempIndex, submitDatas.days.length);
    submitDataList.add(LeaveSubmitData.fromJson(splitSubmitData));
  }
  //check split days
  // submitDataList.forEach((element) {
  //   print(element.days);
  // });

  if (submitDataList.isEmpty) {
    //without split days.
    submitDataList.add(submitDatas);
  }
  final List<Map<String, dynamic>> resultDataList = [];

  for (final LeaveSubmitData submitData in submitDataList) {
    final DateTime startDayParse = dateFormat.parse(submitData.days[0].day!);
    final DateTime endDayParse =
        dateFormat.parse(submitData.days[submitData.days.length - 1].day!);
    final String startDays =
        "${startDayParse.year - 1911}${startDayParse.month.toString().padLeft(2, '0')}${startDayParse.day.toString().padLeft(2, '0')}";
    final String endDays =
        "${endDayParse.year - 1911}${endDayParse.month.toString().padLeft(2, '0')}${endDayParse.day.toString().padLeft(2, '0')}";

    final Map<String, dynamic> result = {
      'year': int.parse(semester!.defaultSemester.year),
      'sms': int.parse(semester.defaultSemester.value),
      'stdid': stdId,
      'begdate': startDays,
      'enddate': endDays,
      'leave_id': submitData.leaveTypeId,
      'reason': submitData.reasonText,
      'teaid': submitData.teacherId,
      'delayreson': submitData.delayReasonText ?? '',
      'notifydate': '',
      'notifyperson': '',
      'notifyparentphone': '',
      'day': submitData.days.length,
      'detail': [],
      'filesubname': '',
      'file': ''
    };
    if (proofImageExists) {
      result['filesubname'] = 'jpg';
      result['file'] = 'proof.jpg';
    }
    // for key-value convernt
    final Map<String, String> tempMap = {};
    for (int i = 0; i < timeCode.length; i++) {
      tempMap[timeCode[i] as String] = 'd$i';
    }

    for (final Day element in submitData.days) {
      final Map<String?, dynamic> temp = {};
      tempMap.forEach((String key, String value) {
        temp[value] = '0';
      });
      for (final String element in element.dayClass!) {
        temp[tempMap[element]] = submitData.leaveTypeId;
      }
      final DateTime leaveDays = dateFormat.parse(element.day!);
      temp['leaveday'] =
          "${leaveDays.year - 1911}${leaveDays.month.toString().padLeft(2, '0')}${leaveDays.day.toString().padLeft(2, '0')}";
      result['detail'].add(temp);
    }

    resultDataList.add(result);
  }
  return resultDataList;
}
