// To parse this JSON data, do
//
//     final midtermAlertData = midtermAlertDataFromJson(jsonString);

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'midterm_alerts_data.g.dart';

@JsonSerializable()
class MidtermAlertsData {
  final List<MidtermAlerts> courses;

  MidtermAlertsData({
    required this.courses,
  });

  factory MidtermAlertsData.fromJson(Map<String, dynamic> json) =>
      _$MidtermAlertsDataFromJson(json);

  Map<String, dynamic> toJson() => _$MidtermAlertsDataToJson(this);

  factory MidtermAlertsData.fromRawJson(String str) =>
      MidtermAlertsData.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}

@JsonSerializable()
class MidtermAlerts {
  String entry;
  String className;
  String title;
  String group;
  String instructors;
  String? reason;
  String? remark;

  MidtermAlerts({
    required this.entry,
    required this.className,
    required this.title,
    required this.group,
    required this.instructors,
    this.reason,
    this.remark,
  });

  factory MidtermAlerts.fromJson(Map<String, dynamic> json) =>
      _$MidtermAlertsFromJson(json);

  Map<String, dynamic> toJson() => _$MidtermAlertsToJson(this);

  factory MidtermAlerts.fromRawJson(String str) => MidtermAlerts.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}
