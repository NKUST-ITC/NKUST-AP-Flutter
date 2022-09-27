// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomData _$RoomDataFromJson(Map<String, dynamic> json) => RoomData(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Room.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RoomDataToJson(RoomData instance) => <String, dynamic>{
      'data': instance.data?.map((e) => e.toJson()).toList(),
    };

Room _$RoomFromJson(Map<String, dynamic> json) => Room(
      name: json['roomName'] as String?,
      id: json['roomId'] as String?,
    );

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
      'roomName': instance.name,
      'roomId': instance.id,
    };
