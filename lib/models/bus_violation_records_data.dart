import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/utils.dart';

part 'bus_violation_records_data.g.dart';

@JsonSerializable()
class BusViolationRecordsData {
  @JsonKey(name: 'reservation')
  List<Reservation> reservations;
  @JsonKey(ignore: true)
  List<Reservation> notPaymentReservations = <Reservation>[];

  int get notPaymentAmountend {
    int sum = 0;
    for (final Reservation element in notPaymentReservations) {
      sum += element.amountend;
    }
    return sum;
  }

  bool get hasBusViolationRecords {
    for (final Reservation item in reservations) {
      if (!item.isPayment) return true;
    }
    return false;
  }

  BusViolationRecordsData({
    required this.reservations,
  }) {
    updateNotPaymentReservations();
  }

  factory BusViolationRecordsData.fromJson(Map<String, dynamic> json) =>
      _$BusViolationRecordsDataFromJson(json);

  Map<String, dynamic> toJson() => _$BusViolationRecordsDataToJson(this);

  factory BusViolationRecordsData.fromRawJson(String str) =>
      BusViolationRecordsData.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());

  void updateNotPaymentReservations() {
    notPaymentReservations.clear();
    for (final Reservation element in reservations) {
      if (!element.isPayment) notPaymentReservations.add(element);
    }
  }
}

@JsonSerializable()
class Reservation {
  @DateTimeConverter()
  DateTime time;
  String startStation;
  String endStation;
  bool homeCharteredBus;
  int amountend;
  bool isPayment;

  Reservation({
    required this.time,
    required this.startStation,
    required this.endStation,
    required this.homeCharteredBus,
    required this.amountend,
    required this.isPayment,
  });

  String get amountendText => (amountend == 0) ? '' : '\$$amountend';

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

//TODO String to DateTime
class DateTimeConverter implements JsonConverter<DateTime, DateTime> {
  const DateTimeConverter();

  @override
  DateTime fromJson(DateTime json) => json;

  @override
  DateTime toJson(DateTime object) => object;
}
