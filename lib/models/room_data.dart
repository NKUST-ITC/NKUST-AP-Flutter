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
  String name;
  String id;

  Room({
    this.name,
    this.id,
  });

  factory Room.fromRawJson(String str) => Room.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Room.fromJson(Map<String, dynamic> json) => new Room(
        name: json["roomName"],
        id: json["roomId"],
      );

  Map<String, dynamic> toJson() => {
        "roomName": name,
        "roomId": id,
      };
}
