import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'schedule_data.g.dart';

@JsonSerializable()
class ScheduleData {
  String week;
  List<String> events;

  ScheduleData({
    required this.week,
    required this.events,
  });

  factory ScheduleData.fromJson(Map<String, dynamic> json) =>
      _$ScheduleDataFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleDataToJson(this);

  factory ScheduleData.fromRawJson(String str) => ScheduleData.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());

  static List<ScheduleData> toList(List<Map<String, dynamic>>? jsonArray) {
    List<ScheduleData> list = [];
    for (Map<String, dynamic> item in (jsonArray ?? []))
      list.add(ScheduleData.fromJson(item));
    return list;
  }
}
