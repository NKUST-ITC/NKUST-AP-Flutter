// To parse this JSON data, do
//
//     final leavesSubmitData = leavesSubmitDataFromJson(jsonString);

import 'dart:convert';

class LeaveSubmitData {
  List<Day> days;
  String leaveTypeId;
  String teacherId;
  String reasonText;
  String delayReasonText;

  LeaveSubmitData({
    this.days,
    this.leaveTypeId,
    this.teacherId,
    this.reasonText,
    this.delayReasonText,
  });

  factory LeaveSubmitData.fromRawJson(String str) =>
      LeaveSubmitData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LeaveSubmitData.fromJson(Map<String, dynamic> json) =>
      new LeaveSubmitData(
        days: new List<Day>.from(json["days"].map((x) => Day.fromJson(x))),
        leaveTypeId: json["leaveType"],
        teacherId: json["teacherId"],
        reasonText: json["reasonText"],
        delayReasonText: json["delayReasonText"],
      );

  Map<String, dynamic> toJson() => {
        "days": new List<dynamic>.from(days.map((x) => x.toJson())),
        "leaveType": leaveTypeId,
        "teacherId": teacherId,
        "reasonText": reasonText,
        "delayReasonText": delayReasonText,
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

  @override
  String toString() {
    if (day == null && dayClass == null)
      return 'empty';
    else {
      String text = day;
      dayClass.forEach((item) {
        text = '$text ($item)';
      });
      return text;
    }
  }
}
