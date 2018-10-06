import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class BusData {
  String date;
  List<BusTime> timetable;

  BusData({
    this.date,
    this.timetable,
  });

  static BusData fromJson(Map<String, dynamic> json) {
    return BusData(
      date: json['date'],
      timetable: BusTime.toList(json["timetable"]),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'timetable': timetable,
      };
}

class BusTime {
  String EndEnrollDateTime;
  String runDateTime;
  String Time;
  String endStation;
  String busId;
  String reserveCount;
  String limitCount;
  int isReserve;
  String SpecialTrain;
  String SpecialTrainRemark;
  int cancelKey;

  BusTime({
    this.EndEnrollDateTime,
    this.runDateTime,
    this.Time,
    this.endStation,
    this.busId,
    this.reserveCount,
    this.limitCount,
    this.isReserve,
    this.SpecialTrain,
    this.SpecialTrainRemark,
    this.cancelKey,
  });

  static List<BusTime> toList(List<dynamic> jsonArray) {
    List<BusTime> list = [];
    for (var item in (jsonArray ?? [])) list.add(BusTime.fromJson(item));
    return list;
  }

  static BusTime fromJson(Map<String, dynamic> json) {
    return BusTime(
      EndEnrollDateTime: json['EndEnrollDateTime'],
      runDateTime: json['runDateTime'],
      Time: json['Time'],
      endStation: json['endStation'],
      busId: json['busId'],
      reserveCount: json['reserveCount'],
      limitCount: json['limitCount'],
      isReserve: json['isReserve'],
      SpecialTrain: json['SpecialTrain'],
      SpecialTrainRemark: json['SpecialTrainRemark'],
      cancelKey: json['cancelKey'],
    );
  }

  Map<String, dynamic> toJson() => {
        'EndEnrollDateTime': EndEnrollDateTime,
        'runDateTime': runDateTime,
        'Time': Time,
        'endStation': endStation,
        'busId': busId,
        'reserveCount': reserveCount,
        'limitCount': limitCount,
        'isReserve': isReserve,
        'SpecialTrain': SpecialTrain,
        'SpecialTrainRemark': SpecialTrainRemark,
        'cancelKey': cancelKey,
      };

  bool hasReserve() {
    var now = new DateTime.now();
    initializeDateFormatting();
    var formatter = new DateFormat('yyyy-MM-dd hh:mm',"zh");
    var endEnrollDateTime = formatter.parse(this.EndEnrollDateTime);
    /*print(now);
    print(endEnrollDateTime);
    print(now.millisecondsSinceEpoch);
    print(endEnrollDateTime.millisecondsSinceEpoch);*/
    return now.millisecondsSinceEpoch <=
        endEnrollDateTime.add(Duration(hours: 8)).millisecondsSinceEpoch;
  }

  Color getColorState() {
    return isReserve == 1
        ? Resource.Theme.blue
        : hasReserve() ? Resource.Theme.grey : Colors.grey;
  }

  String getReserveState() {
    return isReserve == 1 ? "已預約" : hasReserve() ? "預約" : "無法預約";
  }
}
