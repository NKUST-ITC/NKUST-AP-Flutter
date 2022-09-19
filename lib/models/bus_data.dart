import 'dart:convert';

import 'package:ap_common/resources/ap_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/utils.dart';

class BusData {
  bool? canReserve;
  String? description;
  List<BusTime>? timetable;

  BusData({
    this.canReserve,
    this.description,
    this.timetable,
  });

  factory BusData.fromRawJson(String str) => BusData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusData.fromJson(Map<String, dynamic> json) => BusData(
        timetable: List<BusTime>.from(
          json["data"].map(
            (x) => BusTime.fromJson(x),
          ),
        ),
        canReserve: json["canReserve"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(timetable!.map((x) => x.toJson())),
        "canReserve": canReserve,
        "description": description,
      };

  static BusData sample() {
    return BusData.fromRawJson(
        '{ "date": "2019-03-17T16:51:57Z", "data": [ { "endEnrollDateTime": "2019-03-17T16:51:57Z", "departureTime": "2019-03-17T16:51:57Z", "startStation": "建工", "busId": "42705", "reserveCount": 2, "limitCount": 999, "isReserve": true, "specialTrain": "0", "discription": "", "cancelKey": "0", "homeCharteredBus": false }, { "endEnrollDateTime": "2020-03-17T16:51:57Z", "departureTime": "2020-03-17T16:51:57Z", "startStation": "建工", "busId": "42711", "reserveCount": 11, "limitCount": 999, "isReserve": false, "SpecialTrain": "0", "discription": "", "cancelKey": "0", "homeCharteredBus": false } ] }');
  }
}

class BusTime {
  @deprecated
  DateTime? endEnrollDateTime;
  DateTime? departureTime;
  String? startStation;
  String? endStation;
  String? busId;
  int? reserveCount;
  int? limitCount;
  bool? isReserve;
  String? specialTrain;
  String? description;
  String? cancelKey;
  bool? homeCharteredBus;
  bool? canBook;

  BusTime({
    this.endEnrollDateTime,
    this.departureTime,
    this.startStation,
    this.endStation,
    this.busId,
    this.reserveCount,
    this.limitCount,
    this.isReserve,
    this.specialTrain,
    this.description,
    this.cancelKey,
    this.homeCharteredBus,
    this.canBook,
  });

  String getSpecialTrainTitle(AppLocalizations? local) {
    switch (specialTrain) {
      case "1":
        return local!.specialBus;
      case "2":
        return local!.trialBus;
      default:
        return "";
    }
  }

//  String getSpecialTrainRemark() {
//    print(specialTrainRemark);
//    if (specialTrainRemark.length == 0)
//      return "";
//    else
//      return "${specialTrainRemark.replaceAll("\n", "").replaceAll("<br />", "\n")}\n";
//  }

  static List<BusTime> toList(List<dynamic> jsonArray) {
    List<BusTime> list = [];
    for (var item in (jsonArray)) list.add(BusTime.fromJson(item));
    return list;
  }

  factory BusTime.fromRawJson(String str) => BusTime.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusTime.fromJson(Map<String, dynamic> json) => BusTime(
        endEnrollDateTime: json["endEnrollDateTime"],
        departureTime: json["departureTime"],
        startStation: json["startStation"],
        endStation: json["endStation"],
        busId: json["busId"],
        reserveCount: json["reserveCount"],
        limitCount: json["limitCount"],
        isReserve: json["isReserve"],
        specialTrain: json["specialTrain"],
        description: json["description"],
        cancelKey: json["cancelKey"],
        homeCharteredBus: json["homeCharteredBus"],
        canBook: json['canBook'],
      );

  Map<String, dynamic> toJson() => {
        "departureTime": departureTime,
        "startStation": startStation,
        "endStation": endStation,
        "busId": busId,
        "reserveCount": reserveCount,
        "limitCount": limitCount,
        "isReserve": isReserve,
        "specialTrain": specialTrain,
        "description": description,
        "cancelKey": cancelKey,
        "homeCharteredBus": homeCharteredBus,
        "canBook": canBook,
      };

  bool canReserve() {
    return canBook ?? true;
  }

  @deprecated
  String getEndEnrollDateTime() {
    initializeDateFormatting();
    var dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss ');
    return dateFormat.format(this.endEnrollDateTime!);
  }

  Color getColorState(BuildContext context) {
    return isReserve!
        ? ApTheme.of(context).blueAccent
        : canReserve()
            ? ApTheme.of(context).grey
            : ApTheme.of(context).disabled;
  }

  String getReserveState(AppLocalizations? local) {
    return isReserve!
        ? local!.reserved
        : canReserve()
            ? local!.reserve
            : local!.canNotReserve;
  }

  String getDate() {
    initializeDateFormatting();
    var formatterTime = new DateFormat('yyyy-MM-dd');
    return formatterTime.format(this.departureTime!);
  }

  String getTime() {
    initializeDateFormatting();
    var formatterTime = new DateFormat('HH:mm', 'zh');
    return formatterTime.format(this.departureTime!);
  }

  String? getStart(AppLocalizations? local) {
    return Utils.parserCampus(local, startStation);
  }

  String? getEnd(AppLocalizations? local) {
    return Utils.parserCampus(local, endStation);
  }
}
