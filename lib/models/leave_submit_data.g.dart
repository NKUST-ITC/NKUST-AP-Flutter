// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_submit_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveSubmitData _$LeaveSubmitDataFromJson(Map<String, dynamic> json) =>
    LeaveSubmitData(
      days: (json['days'] as List<dynamic>)
          .map((e) => LeaveDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      leaveTypeId: json['leaveTypeId'] as String,
      teacherId: json['teacherId'] as String,
      reasonText: json['reasonText'] as String,
      delayReasonText: json['delayReasonText'] as String?,
    );

Map<String, dynamic> _$LeaveSubmitDataToJson(LeaveSubmitData instance) =>
    <String, dynamic>{
      'days': instance.days.map((e) => e.toJson()).toList(),
      'leaveTypeId': instance.leaveTypeId,
      'teacherId': instance.teacherId,
      'reasonText': instance.reasonText,
      'delayReasonText': instance.delayReasonText,
    };

LeaveDay _$LeaveDayFromJson(Map<String, dynamic> json) => LeaveDay(
      day: json['day'] as String?,
      dayClass:
          (json['class'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$LeaveDayToJson(LeaveDay instance) => <String, dynamic>{
      'day': instance.day,
      'class': instance.dayClass,
    };
