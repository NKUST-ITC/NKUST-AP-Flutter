DateTime busRealTime(dynamic timestamp) {
  int time;
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
  return date;
}

bool intToBool(int a) => a == 0 ? false : true;

Map<String, dynamic> busTimeTableParser(Map<String, dynamic> data) {
  List<Map<String, dynamic>> temp = [];
  for (int i = 0; i < data["data"].length; i++) {
    Map<String, dynamic> _temp = {
      "endEnrollDateTime": busRealTime(data["data"][i]["EndEnrollDateTime"]),
      "departureTime": busRealTime(data["data"][i]["runDateTime"]),
      "startStation": data["data"][i]["startStation"],
      "busId": data["data"][i]["busId"],
      "reserveCount": int.parse(data["data"][i]["reserveCount"]),
      "limitCount": int.parse(data["data"][i]["limitCount"]),
      "isReserve": intToBool(int.parse(data["data"][i]["isReserve"]) + 1),
      "specialTrain": data["data"][i]["SpecialTrain"],
      "description": data["data"][i]["SpecialTrainRemark"],
      "homeCharteredBus": false,
    };
    if (_temp['SpecialTrain'] == "1") {
      _temp['homeCharteredBus'] = true;
    }
    temp.add(_temp);
  }

  Map<String, dynamic> returnData = {"data": temp};
  return returnData;
}

Map<String, dynamic> busReservationsParser(Map<String, dynamic> data) {
  List<Map<String, dynamic>> temp = [];
  for (int i = 0; i < data["data"].length; i++) {
    Map<String, dynamic> _temp = {
      "dateTime": busRealTime(data["data"][i]["time"]),
      "endTime": busRealTime(data["data"][i]["endTime"]),
      "cancelKey": data["data"][i]["key"],
      "start": data["data"][i]["start"],
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
  for (int i = 0; i < data["data"].length; i++) {
    Map<String, dynamic> _temp = {
      "time": busRealTime(data["data"][i]["runBus"]),
      "startStation": data["data"][i]["start"],
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
