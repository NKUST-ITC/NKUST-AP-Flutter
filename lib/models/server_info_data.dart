// To parse this JSON data, do
//
//     final serverInfoData = serverInfoDataFromJson(jsonString);

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'server_info_data.g.dart';

@JsonSerializable()
class ServerInfoData {
  String date;
  List<ServerInfo> data;

  ServerInfoData({
    required this.date,
    required this.data,
  });

  factory ServerInfoData.fromJson(Map<String, dynamic> json) =>
      _$ServerInfoDataFromJson(json);

  Map<String, dynamic> toJson() => _$ServerInfoDataToJson(this);

  factory ServerInfoData.fromRawJson(String str) => ServerInfoData.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}

@JsonSerializable()
class ServerInfo {
  String service;
  bool isAlive;
  String description;

  ServerInfo({
    required this.service,
    required this.isAlive,
    required this.description,
  });

  factory ServerInfo.fromJson(Map<String, dynamic> json) =>
      _$ServerInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ServerInfoToJson(this);

  factory ServerInfo.fromRawJson(String str) => ServerInfo.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}
