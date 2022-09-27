// To parse this JSON data, do
//
//     final campus = campusFromJson(jsonString);

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'leave_campus_data.g.dart';

@JsonSerializable()
class LeavesCampusData {
  List<LeavesCampus>? data;

  LeavesCampusData({
    this.data,
  });

  factory LeavesCampusData.fromJson(Map<String, dynamic> json) =>
      _$LeavesCampusDataFromJson(json);

  Map<String, dynamic> toJson() => _$LeavesCampusDataToJson(this);

  factory LeavesCampusData.fromRawJson(String str) => LeavesCampusData.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}

@JsonSerializable()
class LeavesCampus {
  String? campusName;
  List<LeavesDepartment>? department;

  LeavesCampus({
    this.campusName,
    this.department,
  });

  factory LeavesCampus.fromJson(Map<String, dynamic> json) =>
      _$LeavesCampusFromJson(json);

  Map<String, dynamic> toJson() => _$LeavesCampusToJson(this);

  factory LeavesCampus.fromRawJson(String str) => LeavesCampus.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}

@JsonSerializable()
class LeavesDepartment {
  String? departmentName;
  List<LeavesTeacher>? teacherList;

  LeavesDepartment({
    this.departmentName,
    this.teacherList,
  });

  factory LeavesDepartment.fromJson(Map<String, dynamic> json) =>
      _$LeavesDepartmentFromJson(json);

  Map<String, dynamic> toJson() => _$LeavesDepartmentToJson(this);

  factory LeavesDepartment.fromRawJson(String str) => LeavesDepartment.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}

@JsonSerializable()
class LeavesTeacher {
  @JsonKey(name: 'teacherName')
  String? name;
  @JsonKey(name: 'teacherId')
  String? id;

  LeavesTeacher({
    this.name,
    this.id,
  });

  factory LeavesTeacher.fromRawJson(String str) =>
      LeavesTeacher.fromJson(json.decode(str));

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
