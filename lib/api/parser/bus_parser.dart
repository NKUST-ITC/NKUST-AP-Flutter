import 'package:ap_common/utils/ap_localizations.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
//ignore_for_file: avoid_dynamic_calls

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
  final DateTime date = DateTime.fromMillisecondsSinceEpoch(
    ((time / 10000000 - 62135596800) * 1000).round(),
  );
  return date.toIso8601String();
}

bool intToBool(int a) => a != 0;

Map<String, dynamic> busTimeTableParser(
  Map<String, dynamic> data, {
  BusReservationsData? busReservations,
}) {
  final List<Map<String, dynamic>> tempList = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> list =
      data['data'] as List<Map<String, dynamic>>;
  for (int i = 0; i < list.length; i++) {
    final Map<String, dynamic> temp = <String, dynamic>{
      'endEnrollDateTime': busRealTime(data['data'][i]['EndEnrollDateTime']),
      'departureTime': busRealTime(data['data'][i]['runDateTime']),
      'startStation': data['data'][i]['startStation'],
      'endStation': data['data'][i]['endStation'],
      'busId': data['data'][i]['busId'],
      'reserveCount': int.parse(list[i]['reserveCount'] as String),
      'limitCount': int.parse(list[i]['limitCount'] as String),
      'isReserve': intToBool(int.parse(list[i]['isReserve'] as String) + 1),
      'specialTrain': data['data'][i]['SpecialTrain'],
      'description': data['data'][i]['SpecialTrainRemark'],
      'homeCharteredBus': false,
      'cancelKey': ''
    };
    if (temp['SpecialTrain'] == '1') {
      temp['homeCharteredBus'] = true;
    }
    if (busReservations != null) {
      final DateFormat format = DateFormat('yyyy/MM/dd HH:mm');
      for (final BusReservation element in busReservations.reservations) {
        if (format.parse(element.dateTime) ==
                format.parse(busRealTime(data['data'][i]['runDateTime'])) &&
            element.start == data['data'][i]['startStation']) {
          temp['cancelKey'] = element.cancelKey;
        }
      }
    }

    tempList.add(temp);
  }

  final Map<String, dynamic> returnData = <String, dynamic>{
    'data': tempList,
  };
  return returnData;
}

Map<String, dynamic> busReservationsParser(Map<String, dynamic> data) {
  final List<Map<String, dynamic>> tempList = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> list =
      data['data'] as List<Map<String, dynamic>>;
  for (int i = 0; i < list.length; i++) {
    final Map<String, dynamic> temp = <String, dynamic>{
      'dateTime': busRealTime(data['data'][i]['time']),
      'endTime': busRealTime(data['data'][i]['endTime']),
      'cancelKey': data['data'][i]['key'],
      'start': data['data'][i]['start'],
      'end': data['data'][i]['end'],
      'state': data['data'][i]['state'],
      'travelState': data['data'][i]['SpecialTrain'],
    };

    tempList.add(temp);
  }

  final Map<String, dynamic> returnData = <String, dynamic>{
    'data': tempList,
  };
  return returnData;
}

Map<String, dynamic> busViolationRecordsParser(Map<String, dynamic> data) {
  final List<Map<String, dynamic>> tempList = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> list =
      data['data'] as List<Map<String, dynamic>>;
  for (int i = 0; i < list.length; i++) {
    final Map<String, dynamic> temp = <String, dynamic>{
      'time': busRealTime(data['data'][i]['runBus']),
      'startStation': data['data'][i]['start'],
      'endStation': data['data'][i]['end'],
      'amountend': data['data'][i]['costMoney'],
      'isPayment': data['data'][i]['receipt'],
      'homeCharteredBus': false,
    };
    if (temp['SpecialTrain'] == '1') {
      temp['homeCharteredBus'] = true;
    }
    tempList.add(temp);
  }

  final Map<String, dynamic> returnData = <String, dynamic>{
    'reservation': tempList,
  };
  return returnData;
}
