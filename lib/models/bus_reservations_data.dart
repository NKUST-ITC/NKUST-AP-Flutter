import 'dart:convert';

import 'package:ap_common/resources/ap_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nkust_ap/utils/app_localizations.dart';

class BusReservationsData {
  List<BusReservation> reservations;

  BusReservationsData({
    this.reservations,
  });

  factory BusReservationsData.fromRawJson(String str) =>
      BusReservationsData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusReservationsData.fromJson(Map<String, dynamic> json) =>
      new BusReservationsData(
        reservations: new List<BusReservation>.from(
            json["data"].map((x) => BusReservation.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": new List<dynamic>.from(reservations.map((x) => x.toJson())),
      };

  static BusReservationsData sample() {
    return BusReservationsData.fromRawJson(
        '{ "data": [ { "dateTime": "2019-03-17T16:51:57Z", "endTime": "2019-03-14T08:20:00Z", "cancelKey": "2004434", "start": "建工", "state": "0", "travelState": "0" }, { "dateTime": "2019-03-18T00:20:00Z", "endTime": "2019-03-17T09:20:00Z", "cancelKey": "2006005", "start": "建工", "state": "0", "travelState": "0" }, { "dateTime": "2019-03-18T08:40:00Z", "endTime": "2019-03-18T03:40:00Z", "cancelKey": "2006006", "start": "燕巢", "state": "0", "travelState": "0" } ] }');
  }
}

class BusReservation {
  String dateTime;
  String endTime;
  String cancelKey;
  String start;
  String state;
  String travelState;

  BusReservation({
    this.dateTime,
    this.endTime,
    this.cancelKey,
    this.start,
    this.state,
    this.travelState,
  });

  factory BusReservation.fromRawJson(String str) =>
      BusReservation.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusReservation.fromJson(Map<String, dynamic> json) =>
      new BusReservation(
        dateTime: json["dateTime"],
        endTime: json["endTime"],
        cancelKey: json["cancelKey"],
        start: json["start"],
        state: json["state"],
        travelState: json["travelState"],
      );

  Map<String, dynamic> toJson() => {
        "dateTime": dateTime,
        "endTime": endTime,
        "cancelKey": cancelKey,
        "start": start,
        "state": state,
        "travelState": travelState,
      };

  static List<BusReservation> toList(List<dynamic> jsonArray) {
    List<BusReservation> list = [];
    for (var item in (jsonArray ?? [])) list.add(BusReservation.fromJson(item));
    return list;
  }

  Color getColorState(BuildContext context) {
    return ApTheme.of(context).grey;
  }

  String getDate() {
    initializeDateFormatting();
    var formatter = new DateFormat('yyyy-MM-ddTHH:mm:ssZ');
    var formatterTime = new DateFormat('yyyy-MM-dd');
    var time = formatter.parse(this.dateTime);
    return formatterTime.format(time.add(Duration(hours: 8)));
  }

  String getTime() {
    initializeDateFormatting();
    var formatter = new DateFormat('yyyy-MM-ddTHH:mm:ssZ');
    var formatterTime = new DateFormat('HH:mm');
    var time = formatter.parse(this.dateTime);
    return formatterTime.format(time.add(Duration(hours: 8)));
  }

  DateTime getDateTime() {
    initializeDateFormatting();
    var formatter = new DateFormat('yyyy-MM-ddTHH:mm:ssZ');
    return formatter.parse(this.dateTime).add(Duration(hours: 8));
  }

  String getDateTimeStr() {
    initializeDateFormatting();
    var formatter = new DateFormat('yyyy-MM-ddTHH:mm:ssZ');
    var formatterTime = new DateFormat('yyyy-MM-dd HH:mm');
    return formatterTime
        .format(formatter.parse(this.dateTime).add(Duration(hours: 8)));
  }

  String getStart(AppLocalizations local) {
    switch (start) {
      case "燕巢":
        return local.yanchao;
      case "建工":
        return local.jiangong;
      default:
        return local.unknown;
    }
  }

  String getEnd(AppLocalizations local) {
    switch (start) {
      case "燕巢":
        return local.jiangong;
      case "建工":
        return local.yanchao;
      default:
        return local.unknown;
    }
  }

//  bool canCancel() {
//    var now = new DateTime.now();
//    initializeDateFormatting();
//    var formatter = new DateFormat('yyyy-MM-ddTHH:mm:ssZ');
//    var endEnrollDateTime = formatter.parse(this.endTime);
//    return now.millisecondsSinceEpoch <
//        endEnrollDateTime.millisecondsSinceEpoch;
//  }
}
