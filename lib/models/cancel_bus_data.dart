import 'dart:convert';

class CancelBusData {
  bool success;
  int code;
  String message;
  int count;
  Data data;

  CancelBusData({
    this.success,
    this.code,
    this.message,
    this.count,
    this.data,
  });

  factory CancelBusData.fromRawJson(String str) =>
      CancelBusData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CancelBusData.fromJson(Map<String, dynamic> json) =>
      new CancelBusData(
        success: json["success"],
        code: json["code"],
        message: json["message"],
        count: json["count"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "code": code,
        "message": message,
        "count": count,
        "data": data.toJson(),
      };
}

class Data {
  String message;
  int busId;
  String runTime;
  String reserveMemberId;

  Data({
    this.message,
    this.busId,
    this.runTime,
    this.reserveMemberId,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => new Data(
        message: json["message"],
        busId: json["busId"],
        runTime: json["runTime"],
        reserveMemberId: json["reserveMemberId"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "busId": busId,
        "runTime": runTime,
        "reserveMemberId": reserveMemberId,
      };
}
