// To parse this JSON data, do
//
//     final midtermAlertData = midtermAlertDataFromJson(jsonString);

import 'dart:convert';

class MidtermAlertsData {
  List<MidtermAlerts> courses;

  MidtermAlertsData({
    this.courses,
  });

  factory MidtermAlertsData.fromRawJson(String str) =>
      MidtermAlertsData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MidtermAlertsData.fromJson(Map<String, dynamic> json) =>
      new MidtermAlertsData(
        courses: new List<MidtermAlerts>.from(
            json["courses"].map((x) => MidtermAlerts.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "courses": new List<dynamic>.from(courses.map((x) => x.toJson())),
      };
}

class MidtermAlerts {
  String entry;
  String className;
  String title;
  String group;
  String instructors;
  String reason;
  String remark;

  MidtermAlerts({
    this.entry,
    this.className,
    this.title,
    this.group,
    this.instructors,
    this.reason,
    this.remark,
  });

  factory MidtermAlerts.fromRawJson(String str) =>
      MidtermAlerts.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MidtermAlerts.fromJson(Map<String, dynamic> json) =>
      new MidtermAlerts(
        entry: json["entry"],
        className: json["className"],
        title: json["title"],
        group: json["group"],
        instructors: json["instructors"],
        reason: json["reason"],
        remark: json["remark"],
      );

  Map<String, dynamic> toJson() => {
        "entry": entry,
        "className": className,
        "title": title,
        "group": group,
        "instructors": instructors,
        "reason": reason,
        "remark": remark,
      };
}
