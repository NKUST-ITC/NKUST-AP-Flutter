import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'cancel_bus_data.g.dart';

@JsonSerializable()
class CancelBusData {
  bool? success;

  CancelBusData({
    this.success,
  });

  factory CancelBusData.fromJson(Map<String, dynamic> json) =>
      _$CancelBusDataFromJson(json);

  Map<String, dynamic> toJson() => _$CancelBusDataToJson(this);

  factory CancelBusData.fromRawJson(String str) => CancelBusData.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}
