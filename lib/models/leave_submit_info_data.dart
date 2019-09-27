// To parse this JSON data, do
//
//     final leavesSubmitInfoData = leavesSubmitInfoDataFromJson(jsonString);

import 'dart:convert';

class LeavesSubmitInfoData {
  Tutor tutor;
  List<Type> type;
  List<String> timeCodes;

  LeavesSubmitInfoData({
    this.tutor,
    this.type,
    this.timeCodes,
  });

  factory LeavesSubmitInfoData.fromRawJson(String str) => LeavesSubmitInfoData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LeavesSubmitInfoData.fromJson(Map<String, dynamic> json) => LeavesSubmitInfoData(
    tutor: json["tutor"] == null ? null : Tutor.fromJson(json["tutor"]),
    type: json["type"] == null ? null : List<Type>.from(json["type"].map((x) => Type.fromJson(x))),
    timeCodes: json["timeCodes"] == null ? null : List<String>.from(json["timeCodes"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "tutor": tutor == null ? null : tutor.toJson(),
    "type": type == null ? null : List<dynamic>.from(type.map((x) => x.toJson())),
    "timeCodes": timeCodes == null ? null : List<dynamic>.from(timeCodes.map((x) => x)),
  };
}

class Tutor {
  String name;
  String id;

  Tutor({
    this.name,
    this.id,
  });

  factory Tutor.fromRawJson(String str) => Tutor.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Tutor.fromJson(Map<String, dynamic> json) => Tutor(
    name: json["name"] == null ? null : json["name"],
    id: json["id"] == null ? null : json["id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name == null ? null : name,
    "id": id == null ? null : id,
  };
}

class Type {
  String title;
  String id;

  Type({
    this.title,
    this.id,
  });

  factory Type.fromRawJson(String str) => Type.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Type.fromJson(Map<String, dynamic> json) => Type(
    title: json["title"] == null ? null : json["title"],
    id: json["id"] == null ? null : json["id"],
  );

  Map<String, dynamic> toJson() => {
    "title": title == null ? null : title,
    "id": id == null ? null : id,
  };
}
