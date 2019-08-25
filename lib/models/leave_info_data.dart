// To parse this JSON data, do
//
//     final leavesInfoData = leavesInfoDataFromJson(jsonString);

import 'dart:convert';

class LeavesSubmitInfoData {
  Tutors tutors;
  List<LeaveType> type;
  List<Teacher> teacherList;
  List<String> timeCodes;

  LeavesSubmitInfoData({
    this.tutors,
    this.type,
    this.teacherList,
    this.timeCodes,
  });

  factory LeavesSubmitInfoData.fromRawJson(String str) =>
      LeavesSubmitInfoData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LeavesSubmitInfoData.fromJson(Map<String, dynamic> json) =>
      new LeavesSubmitInfoData(
        tutors: Tutors.fromJson(json["tutors"]),
        type: new List<LeaveType>.from(
            json["type"].map((x) => LeaveType.fromJson(x))),
        teacherList: new List<Teacher>.from(
            json["teacherList"].map((x) => Teacher.fromJson(x))),
        timeCodes: new List<String>.from(json["timeCodes"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "tutors": tutors.toJson(),
        "type": new List<dynamic>.from(type.map((x) => x.toJson())),
        "teacherList":
            new List<dynamic>.from(teacherList.map((x) => x.toJson())),
        "timeCodes": new List<dynamic>.from(timeCodes.map((x) => x)),
      };
}

class Teacher {
  String teacherName;
  String teacherId;

  Teacher({
    this.teacherName,
    this.teacherId,
  });

  factory Teacher.fromRawJson(String str) => Teacher.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Teacher.fromJson(Map<String, dynamic> json) => new Teacher(
        teacherName: json["teacherName"],
        teacherId: json["teacherId"],
      );

  Map<String, dynamic> toJson() => {
        "teacherName": teacherName,
        "teacherId": teacherId,
      };
}

class Tutors {
  String name;

  Tutors({
    this.name,
  });

  factory Tutors.fromRawJson(String str) => Tutors.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Tutors.fromJson(Map<String, dynamic> json) => new Tutors(
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
      };
}

class LeaveType {
  String id;
  String title;

  LeaveType({
    this.id,
    this.title,
  });

  factory LeaveType.fromRawJson(String str) =>
      LeaveType.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LeaveType.fromJson(Map<String, dynamic> json) => new LeaveType(
        id: json["id"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
      };
}
