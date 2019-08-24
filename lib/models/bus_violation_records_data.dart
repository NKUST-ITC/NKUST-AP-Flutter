import 'dart:convert';

class BusViolationRecordsData {
  List<Reservation> reservation;

  BusViolationRecordsData({
    this.reservation,
  });

  factory BusViolationRecordsData.fromRawJson(String str) =>
      BusViolationRecordsData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusViolationRecordsData.fromJson(Map<String, dynamic> json) =>
      new BusViolationRecordsData(
        reservation: new List<Reservation>.from(
            json["reservation"].map((x) => Reservation.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "reservation":
            new List<dynamic>.from(reservation.map((x) => x.toJson())),
      };
}

class Reservation {
  DateTime time;
  String startStation;
  bool homeCharteredBus;
  int amountend;
  String isPayment;

  Reservation({
    this.time,
    this.startStation,
    this.homeCharteredBus,
    this.amountend,
    this.isPayment,
  });

  factory Reservation.fromRawJson(String str) =>
      Reservation.fromJson(json.decode(str));

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
