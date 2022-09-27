// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveData _$LeaveDataFromJson(Map<String, dynamic> json) => LeaveData(
      leaves: (json['data'] as List<dynamic>?)
          ?.map((e) => Leave.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeCodes: (json['timeCodes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$LeaveDataToJson(LeaveData instance) => <String, dynamic>{
      'data': instance.leaves?.map((e) => e.toJson()).toList(),
      'timeCodes': instance.timeCodes,
    };

Leave _$LeaveFromJson(Map<String, dynamic> json) => Leave(
      leaveSheetId: json['leaveSheetId'] as String?,
      date: json['date'] as String?,
      instructorsComment: json['instructorsComment'] as String?,
      leaveSections: (json['sections'] as List<dynamic>?)
          ?.map((e) => LeaveSections.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LeaveToJson(Leave instance) => <String, dynamic>{
      'leaveSheetId': instance.leaveSheetId,
      'date': instance.date,
      'instructorsComment': instance.instructorsComment,
      'sections': instance.leaveSections?.map((e) => e.toJson()).toList(),
    };

LeaveSections _$LeaveSectionsFromJson(Map<String, dynamic> json) =>
    LeaveSections(
      section: json['section'] as String?,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$LeaveSectionsToJson(LeaveSections instance) =>
    <String, dynamic>{
      'section': instance.section,
      'reason': instance.reason,
    };
