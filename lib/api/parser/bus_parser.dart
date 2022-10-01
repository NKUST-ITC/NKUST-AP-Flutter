import 'package:ap_common/utils/ap_localizations.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';

String busRealTime(dynamic timestamp) {
  late int time;
  if (timestamp is String) {
    time = int.parse(timestamp);
  }
  if (timestamp is int) {
    time = timestamp;
  }
  if (timestamp is double) {
    time = timestamp.round();
  }
  var date = new DateTime.fromMillisecondsSinceEpoch(
      ((time / 10000000 - 62135596800) * 1000).round());
  return date.toIso8601String();
}

bool intToBool(int a) => a == 0 ? false : true;

Map<String, dynamic> busTimeTableParser(Map<String, dynamic> data,
    {BusReservationsData? busReservations}) {
  List<Map<String, dynamic>> temp = [];
  final list = data["data"] as List<Map<String, dynamic>>;
  for (int i = 0; i < list.length; i++) {
    Map<String, dynamic> _temp = {
      "endEnrollDateTime": busRealTime(data["data"][i]["EndEnrollDateTime"]),
      "departureTime": busRealTime(data["data"][i]["runDateTime"]),
      "startStation": data["data"][i]["startStation"],
      "endStation": data["data"][i]["endStation"],
      "busId": data["data"][i]["busId"],
      "reserveCount": int.parse(list[i]["reserveCount"] as String),
      "limitCount": int.parse(list[i]["limitCount"] as String),
      "isReserve": intToBool(int.parse(list[i]["isReserve"] as String) + 1),
      "specialTrain": data["data"][i]["SpecialTrain"],
      "description": data["data"][i]["SpecialTrainRemark"],
      "homeCharteredBus": false,
      "cancelKey": ""
    };
    if (_temp['SpecialTrain'] == "1") {
      _temp['homeCharteredBus'] = true;
    }
    if (busReservations != null) {
      final format = DateFormat('yyyy/MM/dd HH:mm');
      busReservations.reservations.forEach((element) {
        if (format.parse(element.dateTime) ==
                format.parse(busRealTime(data["data"][i]["runDateTime"])) &&
            element.start == data["data"][i]["startStation"]) {
          _temp["cancelKey"] = element.cancelKey;
        }
      });
    }

    temp.add(_temp);
  }

  Map<String, dynamic> returnData = {"data": temp};
  return returnData;
}

Map<String, dynamic> busReservationsParser(Map<String, dynamic> data) {
  List<Map<String, dynamic>> temp = [];
  final list = data["data"] as List<Map<String, dynamic>>;
  for (int i = 0; i < list.length; i++) {
    Map<String, dynamic> _temp = {
      "dateTime": busRealTime(data["data"][i]["time"]),
      "endTime": busRealTime(data["data"][i]["endTime"]),
      "cancelKey": data["data"][i]["key"],
      "start": data["data"][i]["start"],
      "end": data["data"][i]["end"],
      "state": data["data"][i]["state"],
      "travelState": data["data"][i]["SpecialTrain"],
    };

    temp.add(_temp);
  }

  Map<String, dynamic> returnData = {"data": temp};
  return returnData;
}

Map<String, dynamic> busViolationRecordsParser(Map<String, dynamic> data) {
  List<Map<String, dynamic>> temp = [];
  final list = data["data"] as List<Map<String, dynamic>>;
  for (int i = 0; i < list.length; i++) {
    Map<String, dynamic> _temp = {
      "time": busRealTime(data["data"][i]["runBus"]),
      "startStation": data["data"][i]["start"],
      "endStation": data["data"][i]["end"],
      "amountend": data["data"][i]["costMoney"],
      "isPayment": data["data"][i]["receipt"],
      "homeCharteredBus": false,
    };
    if (_temp['SpecialTrain'] == "1") {
      _temp['homeCharteredBus'] = true;
    }
    temp.add(_temp);
  }

  Map<String, dynamic> returnData = {"reservation": temp};
  return returnData;
}
