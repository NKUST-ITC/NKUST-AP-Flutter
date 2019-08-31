import 'dart:convert';

class LoginResponse {
  DateTime expireTime;
  String token;

  LoginResponse({
    this.expireTime,
    this.token,
  });

  factory LoginResponse.fromRawJson(String str) =>
      LoginResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      new LoginResponse(
        expireTime: DateTime.parse(json["expireTime"]),
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "expireTime": expireTime.toIso8601String(),
        "token": token,
      };
}
