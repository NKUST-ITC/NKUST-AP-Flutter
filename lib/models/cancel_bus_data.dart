import 'dart:convert';

class CancelBusData {
  bool success;

  CancelBusData({
    this.success,
  });

  factory CancelBusData.fromRawJson(String str) =>
      CancelBusData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CancelBusData.fromJson(Map<String, dynamic> json) => CancelBusData(
        success: json["success"] == null ? null : json["success"],
      );

  Map<String, dynamic> toJson() => {
        "success": success == null ? null : success,
      };
}
