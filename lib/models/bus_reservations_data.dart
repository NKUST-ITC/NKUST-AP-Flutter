import 'dart:convert';

import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/utils.dart';

part 'bus_reservations_data.g.dart';

@JsonSerializable()
class BusReservationsData {
  @JsonKey(name: 'data')
  List<BusReservation> reservations;

  BusReservationsData({
    required this.reservations,
  });

  factory BusReservationsData.fromJson(Map<String, dynamic> json) =>
      _$BusReservationsDataFromJson(json);

  Map<String, dynamic> toJson() => _$BusReservationsDataToJson(this);

  factory BusReservationsData.fromRawJson(String str) =>
      BusReservationsData.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());

  factory BusReservationsData.sample() {
    return BusReservationsData.fromRawJson(
      '{ "data": [ { "dateTime": "2019/03/17T16:51:57Z", "endTime": "2019/03/14T08:20:00Z", "cancelKey": "2004434", "start": "建工", "state": "0", "travelState": "0" }, { "dateTime": "2019/03/18T00:20:00Z", "endTime": "2019/03/17T09:20:00Z", "cancelKey": "2006005", "start": "建工", "state": "0", "travelState": "0" }, { "dateTime": "2019/03/18T08:40:00Z", "endTime": "2019/03/18T03:40:00Z", "cancelKey": "2006006", "start": "燕巢", "state": "0", "travelState": "0" } ] }',
    );
  }

  // Waiting setString support Map.
  void save(String? tag) {
    PreferenceUtil.instance.setString(
      '${Constants.prefBusReservationsData}_$tag',
      toRawJson(),
    );
  }

  static BusReservationsData? load(String? tag) {
    final String rawString = PreferenceUtil.instance.getString(
      '${Constants.prefBusReservationsData}_$tag',
      '',
    );
    if (rawString == '') {
      return null;
    } else {
      return BusReservationsData.fromRawJson(rawString);
    }
  }
}

@JsonSerializable()
class BusReservation {
  String dateTime;
  String cancelKey;
  String start;
  String end;
  String state;
  String travelState;

  BusReservation({
    required this.dateTime,
    required this.cancelKey,
    required this.start,
    required this.end,
    required this.state,
    required this.travelState,
  });

  factory BusReservation.fromJson(Map<String, dynamic> json) =>
      _$BusReservationFromJson(json);

  Map<String, dynamic> toJson() => _$BusReservationToJson(this);

  factory BusReservation.fromRawJson(String str) => BusReservation.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());

  static List<BusReservation> toList(List<Map<String, dynamic>> jsonArray) {
    final List<BusReservation> list = <BusReservation>[];
    for (final Map<String, dynamic> item in jsonArray) {
      list.add(BusReservation.fromJson(item));
    }
    return list;
  }

  Color getColorState(BuildContext context) {
    return ApTheme.of(context).grey;
  }

  String getDate() {
    initializeDateFormatting();
    final DateFormat formatterDateTime = DateFormat('yyyy/MM/dd HH:mm');
    final DateFormat formatterTime = DateFormat('yyyy/MM/dd');
    return formatterTime.format(formatterDateTime.parse(dateTime));
  }

  String getTime() {
    final DateFormat formatterDateTime = DateFormat('yyyy/MM/dd HH:mm');
    final DateFormat formatterTime = DateFormat('HH:mm');
    return formatterTime.format(formatterDateTime.parse(dateTime));
  }

  DateTime getDateTime() {
    final DateFormat formatterDateTime = DateFormat('yyyy/MM/dd HH:mm');
    return formatterDateTime.parse(dateTime);
  }

  String getDateTimeStr() {
    final DateFormat formatterDateTime = DateFormat('yyyy/MM/dd HH:mm');
    final DateFormat formatterTime = DateFormat('yyyy/MM/dd HH:mm');
    final DateTime s = formatterDateTime.parse(dateTime);
    return formatterTime.format(s);
  }

  String getStart(AppLocalizations? local) {
    return Utils.parserCampus(local, start);
  }

  String getEnd(AppLocalizations? local) {
    return Utils.parserCampus(local, end);
  }

//  bool canCancel() {
//    var now = new DateTime.now();
//    initializeDateFormatting();
//    var formatter = new DateFormat('yyyy/MM/ddTHH:mm:ssZ');
//    var endEnrollDateTime = formatter.parse(this.endTime);
//    return now.millisecondsSinceEpoch <
//        endEnrollDateTime.millisecondsSinceEpoch;
//  }
}
