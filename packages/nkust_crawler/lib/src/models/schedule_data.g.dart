// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleData _$ScheduleDataFromJson(Map<String, dynamic> json) => ScheduleData(
      week: json['week'] as String,
      events:
          (json['events'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ScheduleDataToJson(ScheduleData instance) =>
    <String, dynamic>{
      'week': instance.week,
      'events': instance.events,
    };
