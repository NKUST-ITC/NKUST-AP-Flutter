// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventInfoResponse _$EventInfoResponseFromJson(Map<String, dynamic> json) =>
    EventInfoResponse(
      code: (json['code'] as num).toInt(),
      description: json['description'] as String,
      title: json['title'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => EventInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EventInfoResponseToJson(EventInfoResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'description': instance.description,
      'title': instance.title,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

EventSendResponse _$EventSendResponseFromJson(Map<String, dynamic> json) =>
    EventSendResponse(
      code: (json['code'] as num).toInt(),
      description: json['description'] as String,
      title: json['title'] as String,
      data: EventInfo.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EventSendResponseToJson(EventSendResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'description': instance.description,
      'title': instance.title,
      'data': instance.data.toJson(),
    };

EventInfo _$EventInfoFromJson(Map<String, dynamic> json) => EventInfo(
      id: json['id'] as String,
      start: json['start'] as String,
      end: json['end'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$EventInfoToJson(EventInfo instance) => <String, dynamic>{
      'id': instance.id,
      'start': instance.start,
      'end': instance.end,
      'name': instance.name,
    };
