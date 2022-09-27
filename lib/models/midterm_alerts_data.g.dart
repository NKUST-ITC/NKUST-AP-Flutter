// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'midterm_alerts_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MidtermAlertsData _$MidtermAlertsDataFromJson(Map<String, dynamic> json) =>
    MidtermAlertsData(
      courses: (json['courses'] as List<dynamic>)
          .map((e) => MidtermAlerts.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MidtermAlertsDataToJson(MidtermAlertsData instance) =>
    <String, dynamic>{
      'courses': instance.courses.map((e) => e.toJson()).toList(),
    };

MidtermAlerts _$MidtermAlertsFromJson(Map<String, dynamic> json) =>
    MidtermAlerts(
      entry: json['entry'] as String,
      className: json['className'] as String,
      title: json['title'] as String,
      group: json['group'] as String,
      instructors: json['instructors'] as String,
      reason: json['reason'] as String?,
      remark: json['remark'] as String?,
    );

Map<String, dynamic> _$MidtermAlertsToJson(MidtermAlerts instance) =>
    <String, dynamic>{
      'entry': instance.entry,
      'className': instance.className,
      'title': instance.title,
      'group': instance.group,
      'instructors': instance.instructors,
      'reason': instance.reason,
      'remark': instance.remark,
    };
