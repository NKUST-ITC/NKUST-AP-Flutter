import 'dart:convert';

class UserInfo {
  String educationSystem;
  String department;
  String className;
  String id;
  String name;
  String pictureUrl;

  UserInfo({
    this.educationSystem,
    this.department,
    this.className,
    this.id,
    this.name,
    this.pictureUrl,
  });

  factory UserInfo.fromRawJson(String str) =>
      UserInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserInfo.fromJson(Map<String, dynamic> json) => new UserInfo(
        educationSystem: json["educationSystem"],
        department: json["department"],
        className: json["className"],
        id: json["id"],
        name: json["name"],
        pictureUrl: json["pictureUrl"],
      );

  Map<String, dynamic> toJson() => {
        "educationSystem": educationSystem,
        "department": department,
        "className": className,
        "id": id,
        "name": name,
        "pictureUrl": pictureUrl,
      };
}
