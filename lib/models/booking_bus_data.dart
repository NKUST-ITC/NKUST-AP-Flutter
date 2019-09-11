import 'dart:convert';

class BookingBusData {
  bool success;

  BookingBusData({
    this.success,
  });

  factory BookingBusData.fromRawJson(String str) => BookingBusData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BookingBusData.fromJson(Map<String, dynamic> json) => BookingBusData(
    success: json["success"] == null ? null : json["success"],
  );

  Map<String, dynamic> toJson() => {
    "success": success == null ? null : success,
  };
}
