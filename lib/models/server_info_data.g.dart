// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_info_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerInfoData _$ServerInfoDataFromJson(Map<String, dynamic> json) =>
    ServerInfoData(
      date: json['date'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ServerInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ServerInfoDataToJson(ServerInfoData instance) =>
    <String, dynamic>{
      'date': instance.date,
      'data': instance.data?.map((e) => e.toJson()).toList(),
    };

ServerInfo _$ServerInfoFromJson(Map<String, dynamic> json) => ServerInfo(
      service: json['service'] as String?,
      isAlive: json['isAlive'] as bool?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ServerInfoToJson(ServerInfo instance) =>
    <String, dynamic>{
      'service': instance.service,
      'isAlive': instance.isAlive,
      'description': instance.description,
    };
