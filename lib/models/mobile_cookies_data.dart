import 'dart:convert';

import 'package:ap_common/utils/preferences.dart';
import 'package:nkust_ap/config/constants.dart';

class MobileCookiesData {
  MobileCookiesData({
    this.cookies,
  });

  List<MobileCookies>? cookies;

  MobileCookiesData copyWith({
    List<MobileCookies>? cookies,
  }) =>
      MobileCookiesData(
        cookies: cookies ?? this.cookies,
      );

  factory MobileCookiesData.fromRawJson(String str) =>
      MobileCookiesData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MobileCookiesData.fromJson(Map<String, dynamic> json) =>
      MobileCookiesData(
        cookies: json["cookies"] == null
            ? null
            : List<MobileCookies>.from(
                json["cookies"].map((x) => MobileCookies.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "cookies": cookies == null
            ? null
            : List<dynamic>.from(cookies!.map((x) => x.toJson())),
      };

  Future<void> save() async {
    await Preferences.setStringSecurity(
        Constants.MOBILE_COOKIES_DATA, toRawJson());
  }

  Future<void> clear() async {
    await Preferences.setString(Constants.MOBILE_COOKIES_DATA, null);
  }

  factory MobileCookiesData.load() {
    final str =
        Preferences.getStringSecurity(Constants.MOBILE_COOKIES_DATA, null);
    return str == null ? null : MobileCookiesData.fromRawJson(str);
  }
}

class MobileCookies {
  MobileCookies({
    this.path,
    this.name,
    this.value,
    this.domain,
  });

  String? path;
  String? name;
  String? value;
  String? domain;

  MobileCookies copyWith({
    String? path,
    String? name,
    String? value,
    String? domain,
  }) =>
      MobileCookies(
        path: path ?? this.path,
        name: name ?? this.name,
        value: value ?? this.value,
        domain: domain ?? this.domain,
      );

  factory MobileCookies.fromRawJson(String str) =>
      MobileCookies.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MobileCookies.fromJson(Map<String, dynamic> json) => MobileCookies(
        path: json["path"] == null ? null : json["path"],
        name: json["name"] == null ? null : json["name"],
        value: json["value"] == null ? null : json["value"],
        domain: json["domain"] == null ? null : json["domain"],
      );

  Map<String, dynamic> toJson() => {
        "path": path == null ? null : path,
        "name": name == null ? null : name,
        "value": value == null ? null : value,
        "domain": domain == null ? null : domain,
      };
}
