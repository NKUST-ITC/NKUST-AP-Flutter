// To parse this JSON data, do
//
//     final roomData = roomDataFromJson(jsonString);

import 'dart:convert';

class RoomData {
  List<Room> data;

  RoomData({
    this.data,
  });

  factory RoomData.fromRawJson(String str) =>
      RoomData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RoomData.fromJson(Map<String, dynamic> json) => new RoomData(
        data: new List<Room>.from(json["data"].map((x) => Room.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": new List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Room {
  String roomName;
  String roomId;

  Room({
    this.roomName,
    this.roomId,
  });

  factory Room.fromRawJson(String str) => Room.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Room.fromJson(Map<String, dynamic> json) => new Room(
        roomName: json["roomName"],
        roomId: json["roomId"],
      );

  Map<String, dynamic> toJson() => {
        "roomName": roomName,
        "roomId": roomId,
      };
}
