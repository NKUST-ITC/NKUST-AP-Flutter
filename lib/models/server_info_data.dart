// To parse this JSON data, do
//
//     final serverInfoData = serverInfoDataFromJson(jsonString);

import 'dart:convert';

class ServerInfoData {
  String? date;
  List<ServerInfo>? data;

  ServerInfoData({
    this.date,
    this.data,
  });

  factory ServerInfoData.fromRawJson(String str) =>
      ServerInfoData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ServerInfoData.fromJson(Map<String, dynamic> json) =>
      new ServerInfoData(
        date: json["date"],
        data: new List<ServerInfo>.from(
            json["data"].map((x) => ServerInfo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "data": new List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class ServerInfo {
  String? service;
  bool? isAlive;
  String? description;

  ServerInfo({
    this.service,
    this.isAlive,
    this.description,
  });

  factory ServerInfo.fromRawJson(String str) =>
      ServerInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ServerInfo.fromJson(Map<String, dynamic> json) => new ServerInfo(
        service: json["service"],
        isAlive: json["isAlive"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "service": service,
        "isAlive": isAlive,
        "description": description,
      };
}
