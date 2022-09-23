import 'dart:convert';

class EventInfoResponse {
  int? code;
  String? description;
  String? title;
  List<EventInfo>? data;

  EventInfoResponse({
    this.code,
    this.description,
    this.title,
    this.data,
  });

  factory EventInfoResponse.fromRawJson(String str) =>
      EventInfoResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory EventInfoResponse.fromJson(Map<String, dynamic> json) =>
      EventInfoResponse(
        code: json["code"] == null ? null : json["code"],
        description: json["description"] == null ? null : json["description"],
        title: json["title"] == null ? null : json["title"],
        data: json["data"] == null
            ? null
            : List<EventInfo>.from(
                json["data"].map((x) => EventInfo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "code": code == null ? null : code,
        "description": description == null ? null : description,
        "title": title == null ? null : title,
        "data": data == null
            ? null
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class EventSendResponse {
  int? code;
  String? description;
  String? title;
  EventInfo? data;

  EventSendResponse({
    this.code,
    this.description,
    this.title,
    this.data,
  });

  factory EventSendResponse.fromRawJson(String str) =>
      EventSendResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory EventSendResponse.fromJson(Map<String, dynamic> json) =>
      EventSendResponse(
        code: json["code"] == null ? null : json["code"],
        description: json["description"] == null ? null : json["description"],
        title: json["title"] == null ? null : json["title"],
        data: json["data"] == null ? null : EventInfo.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "code": code == null ? null : code,
        "description": description == null ? null : description,
        "title": title == null ? null : title,
        "data": data == null ? null : data!.toJson(),
      };
}

class EventInfo {
  String? id;
  String? start;
  String? end;
  String? name;

  EventInfo({
    this.id,
    this.start,
    this.end,
    this.name,
  });

  factory EventInfo.fromRawJson(String str) =>
      EventInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory EventInfo.fromJson(Map<String, dynamic> json) => EventInfo(
        id: json["id"] == null ? null : json["id"],
        start: json["start"] == null ? null : json["start"],
        end: json["end"] == null ? null : json["end"],
        name: json["name"] == null ? null : json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "start": start == null ? null : start,
        "end": end == null ? null : end,
        "name": name == null ? null : name,
      };
}
