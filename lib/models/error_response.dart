// To parse this JSON data, do
//
//     final errorResponse = errorResponseFromJson(jsonString);

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'error_response.g.dart';

@JsonSerializable()
class ErrorResponse {
  int? errorCode;
  String? description;

  ErrorResponse({
    this.errorCode,
    this.description,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);

  factory ErrorResponse.fromRawJson(String str) => ErrorResponse.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}
