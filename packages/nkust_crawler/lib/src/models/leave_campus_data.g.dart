// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_campus_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeavesCampusData _$LeavesCampusDataFromJson(Map<String, dynamic> json) =>
    LeavesCampusData(
      data: (json['data'] as List<dynamic>)
          .map((e) => LeavesCampus.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LeavesCampusDataToJson(LeavesCampusData instance) =>
    <String, dynamic>{
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

LeavesCampus _$LeavesCampusFromJson(Map<String, dynamic> json) => LeavesCampus(
      campusName: json['campusName'] as String,
      department: (json['department'] as List<dynamic>)
          .map((e) => LeavesDepartment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LeavesCampusToJson(LeavesCampus instance) =>
    <String, dynamic>{
      'campusName': instance.campusName,
      'department': instance.department.map((e) => e.toJson()).toList(),
    };

LeavesDepartment _$LeavesDepartmentFromJson(Map<String, dynamic> json) =>
    LeavesDepartment(
      departmentName: json['departmentName'] as String,
      teacherList: (json['teacherList'] as List<dynamic>)
          .map((e) => LeavesTeacher.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LeavesDepartmentToJson(LeavesDepartment instance) =>
    <String, dynamic>{
      'departmentName': instance.departmentName,
      'teacherList': instance.teacherList.map((e) => e.toJson()).toList(),
    };

LeavesTeacher _$LeavesTeacherFromJson(Map<String, dynamic> json) =>
    LeavesTeacher(
      name: json['teacherName'] as String,
      id: json['teacherId'] as String,
    );

Map<String, dynamic> _$LeavesTeacherToJson(LeavesTeacher instance) =>
    <String, dynamic>{
      'teacherName': instance.name,
      'teacherId': instance.id,
    };
