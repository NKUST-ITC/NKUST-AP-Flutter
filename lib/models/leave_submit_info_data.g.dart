// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_submit_info_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveSubmitInfoData _$LeaveSubmitInfoDataFromJson(Map<String, dynamic> json) =>
    LeaveSubmitInfoData(
      tutor: json['tutor'] == null
          ? null
          : Tutor.fromJson(json['tutor'] as Map<String, dynamic>),
      type: (json['type'] as List<dynamic>)
          .map((e) => Type.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeCodes:
          (json['timeCodes'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$LeaveSubmitInfoDataToJson(
        LeaveSubmitInfoData instance) =>
    <String, dynamic>{
      'tutor': instance.tutor?.toJson(),
      'type': instance.type.map((e) => e.toJson()).toList(),
      'timeCodes': instance.timeCodes,
    };

Tutor _$TutorFromJson(Map<String, dynamic> json) => Tutor(
      name: json['name'] as String,
      id: json['id'] as String,
    );

Map<String, dynamic> _$TutorToJson(Tutor instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
    };

Type _$TypeFromJson(Map<String, dynamic> json) => Type(
      title: json['title'] as String,
      id: json['id'] as String,
    );

Map<String, dynamic> _$TypeToJson(Type instance) => <String, dynamic>{
      'title': instance.title,
      'id': instance.id,
    };
