// To parse this JSON data, do
//
//     final leavesSubmitInfoData = leavesSubmitInfoDataFromJson(jsonString);

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'leave_submit_info_data.g.dart';

@JsonSerializable()
class LeaveSubmitInfoData {
  Tutor? tutor;
  List<Type>? type;
  List<String>? timeCodes;

  LeaveSubmitInfoData({
    this.tutor,
    this.type,
    this.timeCodes,
  });

  factory LeaveSubmitInfoData.fromJson(Map<String, dynamic> json) =>
      _$LeaveSubmitInfoDataFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveSubmitInfoDataToJson(this);

  factory LeaveSubmitInfoData.fromRawJson(String str) =>
      LeaveSubmitInfoData.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}

@JsonSerializable()
class Tutor {
  String? name;
  String? id;

  Tutor({
    this.name,
    this.id,
  });

  factory Tutor.fromJson(Map<String, dynamic> json) => _$TutorFromJson(json);

  Map<String, dynamic> toJson() => _$TutorToJson(this);

  factory Tutor.fromRawJson(String str) => Tutor.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}

@JsonSerializable()
class Type {
  String? title;
  String? id;

  Type({
    this.title,
    this.id,
  });

  factory Type.fromJson(Map<String, dynamic> json) => _$TypeFromJson(json);

  Map<String, dynamic> toJson() => _$TypeToJson(this);

  factory Type.fromRawJson(String str) => Type.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}
