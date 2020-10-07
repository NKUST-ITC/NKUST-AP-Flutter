import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';

Map<String, dynamic> inkustCourseTableParser(Map<String, dynamic> data) {
  Map<String, dynamic> result = {
    "courses": [],
    "coursetable": {
      "Monday": [],
      "Tuesday": [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
      'Saturday': [],
      'Sunday': [],
      'timeCodes': [],
    },
  };
  //reverse data type for more easy to use.
  Map<String, dynamic> _tempDateTimeChange = {};

  //timeCodes parse
  data["data"]["time"].forEach((element) {
    result["coursetable"]["timeCodes"].add("第${element["periodName"]}節");
    _tempDateTimeChange.addAll({element["period"]: element});
  });

  //courses parse
  data["data"]["course"].forEach((element) {
    result["courses"].add({
      "code": "",
      "title": element['courseName'],
      "className": element['className'],
      "group": element["courseGroup"],
      "units": element["courseCredit"],
      "hours": element["courseHour"],
      "required": element["courseOption"],
      "at": element["courseAnnual"],
      "times": element["courseTime"],
      "location": {"room": element['courseRoom']},
      "instructors": [element['courseTeacher']]
    });
  });

  Map<String, String> courseWeek = {
    "1": 'Monday',
    "2": 'Tuesday',
    "3": 'Wednesday',
    "4": 'Thursday',
    "5": 'Friday',
    "6": 'Saturday',
    "0": 'Sunday',
  };
  //coursetable parse
  data["data"]["course"].forEach((courseElement) {
    courseElement['courseTimeData'].forEach((singleCourseObject) {
      result['coursetable'][courseWeek[singleCourseObject['courseWeek']]].add({
        "title": courseElement['courseName'],
        "date": {
          "startTime":
              "${_tempDateTimeChange[singleCourseObject["coursePeriod"]]["begTime"].substring(0, 2)}:${_tempDateTimeChange[singleCourseObject["coursePeriod"]]["begTime"].substring(2, 4)}",
          "endTime":
              "${_tempDateTimeChange[singleCourseObject["coursePeriod"]]["endTime"].substring(0, 2)}:${_tempDateTimeChange[singleCourseObject["coursePeriod"]]["endTime"].substring(2, 4)}",
          "section":
              "第${_tempDateTimeChange[singleCourseObject["coursePeriod"]]["periodName"]}節"
        },
        "location": {"room": courseElement['courseRoom']},
        "instructors": [courseElement['courseTeacher']]
      });
    });
  });
  return result;
}

Future<Map<String, dynamic>> inkustBusUserRecordsParser(
    List<Future<Response>> responseList) async {
  Map<String, dynamic> returnData = {"data": []};

  List<dynamic> dataList = [];

  await Future.forEach(responseList, (e) async {
    var _temp = await e;
    Map<String, dynamic> data;
    if (_temp.data is String &&
        _temp.headers['Content-Type'][0].indexOf("text/html") > -1) {
      data = jsonDecode(_temp.data);
    } else if (_temp.data is Map<String, dynamic>) {
      data = _temp.data;
    }
    if (data['success']) {
      dataList.addAll(data['data']);
    }
  });
  DateFormat format = new DateFormat("yyyy/MM/dd HH:mm");

  dataList.forEach((element) {
    returnData['data'].add({
      "dateTime": format.parse(element['driveTime']),
      "endTime": format.parse(element['resEndTime']),
      "cancelKey": element["resId"].toString(),
      "start": element['startStation'],
      "end": element['endStation'],
      "state": element['stateCode'].toString(),
      "travelState": element['specialBus'].toString()
    });
  });
  return returnData;
}

Map<String, dynamic> inkustBusTimeTableParser(
  String queryDate,
  List<dynamic> data,
  BusReservationsData userRecords,
) {
  List<Map<String, dynamic>> temp = [];

  DateFormat format = new DateFormat("yyyy/MM/dd HH:mm");

  for (int i = 0; i < data.length; i++) {
    Map<String, dynamic> _temp = {
      "endEnrollDateTime": DateTime.now(),
      "departureTime": format.parse("$queryDate ${data[i]['driveTime']}"),
      "startStation": data[i]['startStation'],
      "endStation": data[i]['endStation'],
      "busId": data[i]['busId'].toString(),
      "reserveCount": int.parse(data[i]['resCount'].toString()),
      "limitCount": int.parse(data[i]['limitCount'].toString()),
      "isReserve": false,
      "specialTrain": data[i]['specialBus'].toString(),
      "description": data[i]['specialMsg'],
      "homeCharteredBus": false,
      "cancelKey": "",
      "canBook": data[i]['resEnable']
    };
    if (data[i]['resName'] == "已預約") {
      _temp['isReserve'] = true;
    }

    if (data[i]['resEnable'] == false) {
      _temp['endEnrollDateTime'] = new DateTime(1970, 1, 1, 0, 0);
    }

    if (_temp['SpecialTrain'] == "1") {
      _temp['homeCharteredBus'] = true;
    }
    if (userRecords.reservations.length > 0) {
      userRecords.reservations.forEach((element) {
        if (element.dateTime == _temp['departureTime'] &&
            element.start == _temp['startStation']) {
          _temp["cancelKey"] = element.cancelKey.toString();
        }
      });
    }

    temp.add(_temp);
  }
  Map<String, dynamic> returnData = {"data": temp};
  return returnData;
}

Map<String, dynamic> inkustBusViolationRecordsParser(
    Map<String, dynamic> data) {
  List<Map<String, dynamic>> temp = [];
  DateFormat format = new DateFormat("yyyy/MM/dd HH:mm");

  data['data'].forEach((e) {
    Map<String, dynamic> _temp = {
      "time": format.parse(e['driveTime']),
      "startStation": e['startStation'],
      "endStation": e['endStation'],
      "amountend": e['money'],
      "isPayment": e['stateCode'],
      "homeCharteredBus": false,
    };
    if (e['specialBus'] == "1") {
      e['homeCharteredBus'] = true;
    }
    temp.add(_temp);
  });
  return {"reservation": temp};
}

Map<String, dynamic> inkustgetAbsentRecordsParser(Map<String, dynamic> data,
    {List timeCodes}) {
  List<Map<String, dynamic>> result = [];
  if (data["success"] == false || data['count'] < 1) {
    // return null;
    return {"data": [], "timeCodes": []};
  }

  if (timeCodes == null) {
    timeCodes = [];
    if (((data['data'][0] ?? const {})['Detail'] ?? false) != false &&
        data['data'][0]['Detail'].length > 0) {
      data['data'][0]['Detail'][0].forEach((key, value) {
        if (key != 'TranCode' && key != 'leaveday') {
          timeCodes.add(key);
        }
      });
    } else {
      //lost timeCode
      // return null;
      return {"data": [], "timeCodes": []};
    }
  }

  for (int i = 0; i < data['data'].length; i++) {
    for (int dayLeaves = 0;
        dayLeaves < data['data'][i]['Detail'].length;
        dayLeaves++) {
      Map<String, dynamic> _temp = {
        "leaveSheetId": data['data'][i]['LeaveCode'] ?? "",
        "date": "",
        "instructorsComment": data['data'][i]["LeaveTeaSuggest"] ?? "",
        "sections": []
      };

      int _index = 0;
      data['data'][i]['Detail'][dayLeaves].forEach((key, value) {
        if (key == "leaveday") {
          _temp["date"] = value;
        }
        if (key != 'TranCode' && key != 'leaveday') {
          value = value.replaceAll("　", "").replaceAll(" ", "");
          if (value.length > 0) {
            _temp['sections'].add({
              "section": timeCodes[_index],
              "reason": value,
            });
          }
          _index++;
        }
      });

      result.add(_temp);
    }
  }
  return {'data': result, 'timeCodes': timeCodes};
}

Map<String, dynamic> inkustGetLeaveSubmitInfoParser(
    Map<String, dynamic> leaveTypeOptionData,
    Map<String, dynamic> totorRecordsData,
    List<dynamic> timeCodes) {
  Map<String, dynamic> result = {
    "tutor": {"name": null, "id": null},
    "type": [],
    "timeCodes": []
  };
  if (!totorRecordsData['success'] || !leaveTypeOptionData['success']) {
    return result;
  }
  if (totorRecordsData['data']['choose'] != "" &&
      totorRecordsData['data']['enable'] == false) {
    result['tutor'] = {"name": "", "id": ""};
    result['tutor']['id'] = totorRecordsData['data']['choose'].toString();
    for (int i = 0; i < totorRecordsData['data']['teacher'].length; i++) {
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
      "title": value['leave_name'],
      "id": value['leave_id'],
    });
  });

  result['timeCodes'] = timeCodes;
  return result;
}
