import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'event_info_response.g.dart';

@JsonSerializable()
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

  factory EventInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$EventInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EventInfoResponseToJson(this);

  factory EventInfoResponse.fromRawJson(String str) =>
      EventInfoResponse.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}

@JsonSerializable()
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

  factory EventSendResponse.fromJson(Map<String, dynamic> json) =>
      _$EventSendResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EventSendResponseToJson(this);

  factory EventSendResponse.fromRawJson(String str) =>
      EventSendResponse.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}

@JsonSerializable()
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

  factory EventInfo.fromJson(Map<String, dynamic> json) =>
      _$EventInfoFromJson(json);

  Map<String, dynamic> toJson() => _$EventInfoToJson(this);

  factory EventInfo.fromRawJson(String str) => EventInfo.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}
