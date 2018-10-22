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
  String endEnrollDateTime;
  String runDateTime;
  String time;
  String endStation;
  String busId;
  String reserveCount;
  String limitCount;
  int isReserve;
  String specialTrain;
  String specialTrainRemark;
  int cancelKey;

  BusTime({
    this.endEnrollDateTime,
    this.runDateTime,
    this.time,
    this.endStation,
    this.busId,
    this.reserveCount,
    this.limitCount,
    this.isReserve,
    this.specialTrain,
    this.specialTrainRemark,
    this.cancelKey,
  });

  String getSpecialTrainTitle() {
    switch (specialTrain) {
      case "1":
        return "特殊班次";
      case "2":
        return "試辦車次";
      default:
        return "";
    }
  }

  String getSpecialTrainRemark() {
    print(specialTrainRemark);
    if (specialTrainRemark.length == 0)
      return "";
    else
      return "${specialTrainRemark.replaceAll("<br />", "\n")}\n";
  }

  static List<BusTime> toList(List<dynamic> jsonArray) {
    List<BusTime> list = [];
    for (var item in (jsonArray ?? [])) list.add(BusTime.fromJson(item));
    return list;
  }

  static BusTime fromJson(Map<String, dynamic> json) {
    return BusTime(
      endEnrollDateTime: json['EndEnrollDateTime'],
      runDateTime: json['runDateTime'],
      time: json['Time'],
      endStation: json['endStation'],
      busId: json['busId'],
      reserveCount: json['reserveCount'],
      limitCount: json['limitCount'],
      isReserve: json['isReserve'],
      specialTrain: json['SpecialTrain'],
      specialTrainRemark: json['SpecialTrainRemark'],
      cancelKey: json['cancelKey'],
    );
  }

  Map<String, dynamic> toJson() => {
        'EndEnrollDateTime': endEnrollDateTime,
        'runDateTime': runDateTime,
        'Time': time,
        'endStation': endStation,
        'busId': busId,
        'reserveCount': reserveCount,
        'limitCount': limitCount,
        'isReserve': isReserve,
        'SpecialTrain': specialTrain,
        'SpecialTrainRemark': specialTrainRemark,
        'cancelKey': cancelKey,
      };

  bool hasReserve() {
    var now = new DateTime.now();
    initializeDateFormatting();
    var formatter = new DateFormat('yyyy-MM-dd HH:mm');
    var endEnrollDateTime = formatter.parse(this.endEnrollDateTime);
    //print(endEnrollDateTime);
    return now.millisecondsSinceEpoch <=
        endEnrollDateTime.millisecondsSinceEpoch;
  }

  Color getColorState() {
    return isReserve == 1
        ? Resource.Colors.blue
        : hasReserve() ? Resource.Colors.grey : Colors.grey;
  }

  String getReserveState() {
    return isReserve == 1 ? "已預約" : hasReserve() ? "預約" : "無法預約";
  }

  String getDate() {
    initializeDateFormatting();
    var formatter = new DateFormat('yyyy-MM-dd HH:mm');
    var formatterTime = new DateFormat('yyyy-MM-dd');
    var time = formatter.parse(this.runDateTime);
    return formatterTime.format(time);
  }

  String getStart() {
    switch (endStation) {
      case "建工":
        return "燕巢";
      case "燕巢":
        return "建工";
      default:
        return "未知";
    }
  }
}
