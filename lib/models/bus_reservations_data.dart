import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/app_localizations.dart';

class BusReservationsData {
  List<BusReservation> reservations;

  BusReservationsData({
    this.reservations,
  });

  static BusReservationsData fromJson(Map<String, dynamic> json) {
    return BusReservationsData(
      reservations: BusReservation.toList(json['reservation']),
    );
  }

  Map<String, dynamic> toJson() => {
        'reservation': reservations,
      };
}

class BusReservation {
  String time;
  String endTime;
  String cancelKey;
  String end;

  BusReservation({
    this.time,
    this.endTime,
    this.cancelKey,
    this.end,
  });

  static BusReservation fromJson(Map<String, dynamic> json) {
    return BusReservation(
      time: json['time'],
      endTime: json['endTime'],
      cancelKey: json['cancelKey'],
      end: json['end'],
    );
  }

  Map<String, dynamic> toJson() => {
        'time': time,
        'endTime': endTime,
        'cancelKey': cancelKey,
        'end': end,
      };

  static List<BusReservation> toList(List<dynamic> jsonArray) {
    List<BusReservation> list = [];
    for (var item in (jsonArray ?? [])) list.add(BusReservation.fromJson(item));
    return list;
  }

  Color getColorState() {
    return Resource.Colors.grey;
  }

  String getDate() {
    initializeDateFormatting();
    var formatter = new DateFormat('yyyy-MM-dd HH:mm', 'uk');
    var formatterTime = new DateFormat('yyyy-MM-dd');
    var time = formatter.parse(this.time).add(Duration(hours: 8));
    return formatterTime.format(time);
  }

  String getTime() {
    initializeDateFormatting();
    var formatter = new DateFormat('yyyy-MM-dd HH:mm', 'uk');
    var formatterTime = new DateFormat('HH:mm', 'uk');
    var time = formatter.parse(this.time).add(Duration(hours: 8));
    return formatterTime.format(time);
  }

  DateTime getDateTime() {
    initializeDateFormatting();
    var formatter = new DateFormat('yyyy-MM-dd HH:mm', 'uk');
    return formatter.parse(this.time).add(Duration(hours: 8));
  }

  String getDateTimeStr() {
    initializeDateFormatting();
    var formatter = new DateFormat('yyyy-MM-dd HH:mm', 'uk');
    return formatter.format(formatter.parse(this.time).add(Duration(hours: 8)));
  }

  String getStart(AppLocalizations local) {
    switch (end) {
      case "建工":
        return local.yanchao;
      case "燕巢":
        return local.jiangong;
      default:
        return local.unknown;
    }
  }

  String getEnd(AppLocalizations local) {
    switch (end) {
      case "建工":
        return local.jiangong;
      case "燕巢":
        return local.yanchao;
      default:
        return local.unknown;
    }
  }

  bool canCancel() {
    var now = new DateTime.now();
    initializeDateFormatting();
    var formatter = new DateFormat('yyyy-MM-dd HH:mm', 'uk');
    var endEnrollDateTime =
        formatter.parse(this.endTime).add(Duration(hours: 8));
    return now.millisecondsSinceEpoch <
        endEnrollDateTime.millisecondsSinceEpoch;
  }
}
