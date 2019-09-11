// To parse this JSON data, do
//
//     final errorResponse = errorResponseFromJson(jsonString);

import 'dart:convert';

class ErrorResponse {
  int errorCode;
  String description;

  ErrorResponse({
    this.errorCode,
    this.description,
  });

  factory ErrorResponse.fromRawJson(String str) => ErrorResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => ErrorResponse(
    errorCode: json["errorCode"] == null ? null : json["errorCode"],
    description: json["description"] == null ? null : json["description"],
  );

  Map<String, dynamic> toJson() => {
    "errorCode": errorCode == null ? null : errorCode,
    "description": description == null ? null : description,
  };
}
