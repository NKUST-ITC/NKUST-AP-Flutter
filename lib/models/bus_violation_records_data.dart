import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:nkust_ap/utils/app_localizations.dart';

class BusViolationRecordsData {
  List<Reservation> reservations;
  List<Reservation> notPaymentReservations = [];

  int get notPaymentAmountend {
    int sum = 0;
    notPaymentReservations?.forEach((element) => sum += element.amountend);
    return sum;
  }

  bool get hasBusViolationRecords {
    for (var item in reservations) {
      if (item != null && item.isPayment != null && !item.isPayment)
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
            new List<dynamic>.from(reservations.map((x) => x.toJson())),
      };

  void updateNotPaymentReservations() {
    notPaymentReservations.clear();
    reservations?.forEach((element) {
      if (element.isPayment != null && !element.isPayment)
        notPaymentReservations.add(element);
    });
  }
}

class Reservation {
  DateTime time;
  String startStation;
  bool homeCharteredBus;
  int amountend;
  bool isPayment;

  Reservation({
    this.time,
    this.startStation,
    this.homeCharteredBus,
    this.amountend,
    this.isPayment,
  });

  factory Reservation.fromRawJson(String str) =>
      Reservation.fromJson(json.decode(str));

  String get amountendText =>
      (amountend == null || amountend == 0) ? '' : '\$$amountend';

  String startStationText(BuildContext context) {
    switch (startStation) {
      case '建工':
        return AppLocalizations.of(context).jiangong;
      case '燕巢':
        return AppLocalizations.of(context).jiangong;
      case '第一':
        return AppLocalizations.of(context).first;
      case '楠梓':
        return AppLocalizations.of(context).nanzi;
      case '旗津':
        return AppLocalizations.of(context).qijin;
      default:
        return startStation;
    }
  }

  String toRawJson() => json.encode(toJson());

  factory Reservation.fromJson(Map<String, dynamic> json) => new Reservation(
        time: DateTime.parse(json["time"]),
        startStation: json["startStation"],
        homeCharteredBus: json["homeCharteredBus"],
        amountend: json["amountend"],
        isPayment: json["isPayment"],
      );

  Map<String, dynamic> toJson() => {
        "time": time.toIso8601String(),
        "startStation": startStation,
        "homeCharteredBus": homeCharteredBus,
        "amountend": amountend,
        "isPayment": isPayment,
      };
}
