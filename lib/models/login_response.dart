import 'dart:convert';

class LoginResponse {
  DateTime expireTime;
  String token;
  bool isAdmin;

  LoginResponse({
    this.expireTime,
    this.token,
    this.isAdmin,
  });

  factory LoginResponse.fromRawJson(String str) =>
      LoginResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        expireTime: json["expireTime"] == null
            ? null
            : DateTime.parse(json["expireTime"]),
        token: json["token"] == null ? null : json["token"],
        isAdmin: json["isAdmin"] == null ? null : json["isAdmin"],
      );

  Map<String, dynamic> toJson() => {
        "expireTime": expireTime == null ? null : expireTime.toIso8601String(),
        "token": token == null ? null : token,
        "isAdmin": isAdmin == null ? null : isAdmin,
      };
}
