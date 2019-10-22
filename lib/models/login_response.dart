// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

class LoginResponse {
  String token;
  DateTime expireTime;
  bool isAdmin;

  LoginResponse({
    this.token,
    this.expireTime,
    this.isAdmin,
  });

  factory LoginResponse.fromRawJson(String str) =>
      LoginResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        token: json["token"] == null ? null : json["token"],
        expireTime: json["expireTime"] == null
            ? null
            : DateTime.parse(json["expireTime"]),
        isAdmin: json["isAdmin"] == null ? null : json["isAdmin"],
      );

  Map<String, dynamic> toJson() => {
        "token": token == null ? null : token,
        "expireTime": expireTime == null ? null : expireTime.toIso8601String(),
        "isAdmin": isAdmin == null ? null : isAdmin,
      };
}
