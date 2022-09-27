import 'dart:convert';

import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/utils.dart';

part 'bus_reservations_data.g.dart';

@JsonSerializable()
class BusReservationsData {
  @JsonKey(name: 'data')
  List<BusReservation>? reservations;

  BusReservationsData({
    this.reservations,
  });

  factory BusReservationsData.fromJson(Map<String, dynamic> json) =>
      _$BusReservationsDataFromJson(json);

  Map<String, dynamic> toJson() => _$BusReservationsDataToJson(this);

  factory BusReservationsData.fromRawJson(String str) =>
      BusReservationsData.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());

  static BusReservationsData sample() {
    return BusReservationsData.fromRawJson(
        '{ "data": [ { "dateTime": "2019/03/17T16:51:57Z", "endTime": "2019/03/14T08:20:00Z", "cancelKey": "2004434", "start": "建工", "state": "0", "travelState": "0" }, { "dateTime": "2019/03/18T00:20:00Z", "endTime": "2019/03/17T09:20:00Z", "cancelKey": "2006005", "start": "建工", "state": "0", "travelState": "0" }, { "dateTime": "2019/03/18T08:40:00Z", "endTime": "2019/03/18T03:40:00Z", "cancelKey": "2006006", "start": "燕巢", "state": "0", "travelState": "0" } ] }');
  }

  // Waiting setString support Map.
  void save(String? tag) {
    Preferences.setString(
      '${Constants.PREF_BUS_RESERVATIONS_DATA}_$tag',
      this.toRawJson(),
    );
  }

  static BusReservationsData? load(String? tag) {
    String rawString = Preferences.getString(
      '${Constants.PREF_BUS_RESERVATIONS_DATA}_$tag',
      '',
    );
    if (rawString == '')
      return null;
    else
      return BusReservationsData.fromRawJson(rawString);
  }
}

@JsonSerializable()
class BusReservation {
  String? dateTime;
  @deprecated
  String? endTime;
  String? cancelKey;
  String? start;
  String? end;
  String? state;
  String? travelState;

  BusReservation({
    this.dateTime,
    this.endTime,
    this.cancelKey,
    this.start,
    this.end,
    this.state,
    this.travelState,
  });

  factory BusReservation.fromJson(Map<String, dynamic> json) =>
      _$BusReservationFromJson(json);

  Map<String, dynamic> toJson() => _$BusReservationToJson(this);

  factory BusReservation.fromRawJson(String str) => BusReservation.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());

  static List<BusReservation> toList(List<dynamic> jsonArray) {
    List<BusReservation> list = [];
    for (var item in (jsonArray)) list.add(BusReservation.fromJson(item));
    return list;
  }

  Color getColorState(BuildContext context) {
    return ApTheme.of(context).grey;
  }

  String getDate() {
    initializeDateFormatting();
    final formatterDateTime = DateFormat('yyyy/MM/dd HH:mm');
    var formatterTime = DateFormat('yyyy/MM/dd');
    return formatterTime.format(formatterDateTime.parse(this.dateTime!));
  }

  String getTime() {
    final formatterDateTime = DateFormat('yyyy/MM/dd HH:mm');
    var formatterTime = new DateFormat('HH:mm');
    return formatterTime.format(formatterDateTime.parse(this.dateTime!));
  }

  DateTime getDateTime() {
    final formatterDateTime = DateFormat('yyyy/MM/dd HH:mm');
    return formatterDateTime.parse(this.dateTime!);
  }

  String getDateTimeStr() {
    final formatterDateTime = DateFormat('yyyy/MM/dd HH:mm');
    var formatterTime = new DateFormat('yyyy/MM/dd HH:mm');
    final s = formatterDateTime.parse(this.dateTime!);
    return formatterTime.format(s);
  }

  String? getStart(AppLocalizations? local) {
    return Utils.parserCampus(local, start);
  }

  String? getEnd(AppLocalizations? local) {
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
