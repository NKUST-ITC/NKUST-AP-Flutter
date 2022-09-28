// To parse this JSON data, do
//
//     final leavesSubmitData = leavesSubmitDataFromJson(jsonString);

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'leave_submit_data.g.dart';

@JsonSerializable()
class LeaveSubmitData {
  List<Day> days;
  String leaveTypeId;
  String teacherId;
  String reasonText;
  String? delayReasonText;

  LeaveSubmitData({
    required this.days,
    required this.leaveTypeId,
    required this.teacherId,
    required this.reasonText,
    this.delayReasonText,
  });

  factory LeaveSubmitData.fromJson(Map<String, dynamic> json) =>
      _$LeaveSubmitDataFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveSubmitDataToJson(this);

  factory LeaveSubmitData.fromRawJson(String str) => LeaveSubmitData.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}

@JsonSerializable()
class Day {
  String? day;
  @JsonKey(name: 'class')
  List<String>? dayClass;

  Day({
    this.day,
    this.dayClass,
  });

  factory Day.fromJson(Map<String, dynamic> json) => _$DayFromJson(json);

  Map<String, dynamic> toJson() => _$DayToJson(this);

  factory Day.fromRawJson(String str) => Day.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());

  @override
  String toString() {
    if (day == null && dayClass == null)
      return 'empty';
    else {
      String? text = day;
      dayClass!.forEach((item) {
        text = '$text ($item)';
      });
      return text!;
    }
  }
}
