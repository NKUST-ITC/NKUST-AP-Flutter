import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'booking_bus_data.g.dart';

@JsonSerializable()
class BookingBusData {
  final bool success;

  BookingBusData({
    required this.success,
  });

  factory BookingBusData.fromJson(Map<String, dynamic> json) =>
      _$BookingBusDataFromJson(json);

  Map<String, dynamic> toJson() => _$BookingBusDataToJson(this);

  factory BookingBusData.fromRawJson(String str) => BookingBusData.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}
