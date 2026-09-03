// To parse this JSON data, do
//
//     final leavesSubmitData = leavesSubmitDataFromJson(jsonString);

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'leave_submit_data.g.dart';

@JsonSerializable()
class LeaveSubmitData {
  List<LeaveDay> days;
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
class LeaveDay {
  String? day;
  @JsonKey(name: 'class')
  List<String>? dayClass;

  LeaveDay({
    this.day,
    this.dayClass,
  });

  factory LeaveDay.fromJson(Map<String, dynamic> json) =>
      _$LeaveDayFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveDayToJson(this);

  factory LeaveDay.fromRawJson(String str) => LeaveDay.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());

  @override
  String toString() {
    if (day == null && dayClass == null) {
      return 'empty';
    } else {
      final StringBuffer buffer = StringBuffer(day!);
      for (final String item in dayClass!) {
        buffer.write('$buffer ($item)');
      }
      return buffer.toString();
    }
  }
}
