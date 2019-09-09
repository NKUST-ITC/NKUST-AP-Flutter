import 'dart:convert';

class BookingBusData {
  bool success;
  int code;
  String message;
  int count;
  Data data;

  BookingBusData({
    this.success,
    this.code,
    this.message,
    this.count,
    this.data,
  });

  factory BookingBusData.fromRawJson(String str) =>
      BookingBusData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BookingBusData.fromJson(Map<String, dynamic> json) =>
      new BookingBusData(
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
  String startTime;
  int budId;

  Data({
    this.startTime,
    this.budId,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => new Data(
        startTime: json["startTime"],
        budId: json["budId"],
      );

  Map<String, dynamic> toJson() => {
        "startTime": startTime,
        "budId": budId,
      };
}
