// To parse this JSON data, do
//
//     final campus = campusFromJson(jsonString);

import 'dart:convert';

class LeavesCampusData {
  List<LeavesCampus> data;

  LeavesCampusData({
    this.data,
  });

  factory LeavesCampusData.fromRawJson(String str) => LeavesCampusData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LeavesCampusData.fromJson(Map<String, dynamic> json) => LeavesCampusData(
    data: json["data"] == null ? null : List<LeavesCampus>.from(json["data"].map((x) => LeavesCampus.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? null : List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class LeavesCampus {
  String campusName;
  List<LeavesDepartment> department;

  LeavesCampus({
    this.campusName,
    this.department,
  });

  factory LeavesCampus.fromRawJson(String str) => LeavesCampus.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LeavesCampus.fromJson(Map<String, dynamic> json) => LeavesCampus(
    campusName: json["campusName"] == null ? null : json["campusName"],
    department: json["department"] == null ? null : List<LeavesDepartment>.from(json["department"].map((x) => LeavesDepartment.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "campusName": campusName == null ? null : campusName,
    "department": department == null ? null : List<dynamic>.from(department.map((x) => x.toJson())),
  };
}

class LeavesDepartment {
  String departmentName;
  List<LeavesTeacher> teacherList;

  LeavesDepartment({
    this.departmentName,
    this.teacherList,
  });

  factory LeavesDepartment.fromRawJson(String str) => LeavesDepartment.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LeavesDepartment.fromJson(Map<String, dynamic> json) => LeavesDepartment(
    departmentName: json["departmentName"] == null ? null : json["departmentName"],
    teacherList: json["teacherList"] == null ? null : List<LeavesTeacher>.from(json["teacherList"].map((x) => LeavesTeacher.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "departmentName": departmentName == null ? null : departmentName,
    "teacherList": teacherList == null ? null : List<dynamic>.from(teacherList.map((x) => x.toJson())),
  };
}

class LeavesTeacher {
  String name;
  String id;

  LeavesTeacher({
    this.name,
    this.id,
  });

  factory LeavesTeacher.fromRawJson(String str) => LeavesTeacher.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LeavesTeacher.fromJson(Map<String, dynamic> json) => LeavesTeacher(
    name: json["teacherName"] == null ? null : json["teacherName"],
    id: json["teacherId"] == null ? null : json["teacherId"],
  );

  Map<String, dynamic> toJson() => {
    "teacherName": name == null ? null : name,
    "teacherId": id == null ? null : id,
  };
}
