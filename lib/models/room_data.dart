// To parse this JSON data, do
//
//     final roomData = roomDataFromJson(jsonString);

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'room_data.g.dart';

@JsonSerializable()
class RoomData {
  List<Room>? data;

  RoomData({
    this.data,
  });

  factory RoomData.fromJson(Map<String, dynamic> json) =>
      _$RoomDataFromJson(json);

  Map<String, dynamic> toJson() => _$RoomDataToJson(this);

  factory RoomData.fromRawJson(String str) => RoomData.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}

@JsonSerializable()
class Room {
  @JsonKey(name: 'roomName')
  String? name;
  @JsonKey(name: 'roomId')
  String? id;

  Room({
    this.name,
    this.id,
  });

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  Map<String, dynamic> toJson() => _$RoomToJson(this);

  factory Room.fromRawJson(String str) => Room.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}
