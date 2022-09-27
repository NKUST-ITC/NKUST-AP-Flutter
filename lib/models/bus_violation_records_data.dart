import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/utils.dart';

part 'bus_violation_records_data.g.dart';

@JsonSerializable()
class BusViolationRecordsData {
  @JsonKey(name: 'reservation')
  List<Reservation>? reservations;
  @JsonKey(ignore: true)
  List<Reservation> notPaymentReservations = [];

  int get notPaymentAmountend {
    int sum = 0;
    notPaymentReservations.forEach((element) => sum += element.amountend!);
    return sum;
  }

  bool get hasBusViolationRecords {
    for (var item in reservations!) {
      if (item != null && item.isPayment != null && !item.isPayment!)
        return true;
    }
    return false;
  }

  BusViolationRecordsData({
    this.reservations,
  }) {
    updateNotPaymentReservations();
  }

  factory BusViolationRecordsData.fromRawJson(String str) =>
      BusViolationRecordsData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusViolationRecordsData.fromJson(Map<String, dynamic> json) =>
      new BusViolationRecordsData(
        reservations: new List<Reservation>.from(
            json["reservation"].map((x) => Reservation.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "reservation":
            new List<dynamic>.from(reservations!.map((x) => x.toJson())),
      };

  void updateNotPaymentReservations() {
    notPaymentReservations.clear();
    reservations?.forEach((element) {
      if (element.isPayment != null && !element.isPayment!)
        notPaymentReservations.add(element);
    });
  }
}

@JsonSerializable()
class Reservation {
  DateTime? time;
  String? startStation;
  String? endStation;
  bool? homeCharteredBus;
  int? amountend;
  bool? isPayment;

  Reservation({
    this.time,
    this.startStation,
    this.endStation,
    this.homeCharteredBus,
    this.amountend,
    this.isPayment,
  });

  String get amountendText =>
      (amountend == null || amountend == 0) ? '' : '\$$amountend';

  String? startStationText(BuildContext context) {
    return Utils.parserCampus(AppLocalizations.of(context), startStation);
  }

  String? endStationText(AppLocalizations local) {
    return Utils.parserCampus(local, endStation);
  }

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);

  Map<String, dynamic> toJson() => _$ReservationToJson(this);

  factory Reservation.fromRawJson(String str) => Reservation.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}
