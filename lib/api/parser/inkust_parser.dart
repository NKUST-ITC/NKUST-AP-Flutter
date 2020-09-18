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
  DateFormat format = new DateFormat("yyyy/MM/dd hh:mm");

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

  DateFormat format = new DateFormat("yyyy/MM/dd hh:mm");

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
      "cancelKey": ""
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
