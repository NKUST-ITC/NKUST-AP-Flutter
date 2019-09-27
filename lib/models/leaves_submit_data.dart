// To parse this JSON data, do
//
//     final leavesSubmitData = leavesSubmitDataFromJson(jsonString);

import 'dart:convert';

class LeavesSubmitData {
  List<Day> days;
  String leaveTypeId;
  String teacherId;
  String reasonText;
  String delayReasonText;

  LeavesSubmitData({
    this.days,
    this.leaveTypeId,
    this.teacherId,
    this.reasonText,
    this.delayReasonText,
  });

  factory LeavesSubmitData.fromRawJson(String str) =>
      LeavesSubmitData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LeavesSubmitData.fromJson(Map<String, dynamic> json) =>
      new LeavesSubmitData(
        days: new List<Day>.from(json["days"].map((x) => Day.fromJson(x))),
        leaveTypeId: json["leaveType"],
        teacherId: json["teacherId"],
        reasonText: json["reasonText"],
        delayReasonText: json["delayReason"],
      );

  Map<String, dynamic> toJson() => {
        "days": new List<dynamic>.from(days.map((x) => x.toJson())),
        "leaveType": leaveTypeId,
        "teacherId": teacherId,
        "reasonText": reasonText,
        "delayReason": delayReasonText,
      };
}

class Day {
  String day;
  List<String> dayClass;

  Day({
    this.day,
    this.dayClass,
  });

  factory Day.fromRawJson(String str) => Day.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Day.fromJson(Map<String, dynamic> json) => new Day(
        day: json["day"],
        dayClass: new List<String>.from(json["class"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "day": day,
        "class": new List<dynamic>.from(dayClass.map((x) => x)),
      };
}
