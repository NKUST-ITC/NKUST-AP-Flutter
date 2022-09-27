import 'dart:convert';

import 'package:ap_common/utils/preferences.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nkust_ap/config/constants.dart';

part 'mobile_cookies_data.g.dart';

@JsonSerializable()
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

  factory MobileCookiesData.fromJson(Map<String, dynamic> json) =>
      _$MobileCookiesDataFromJson(json);

  Map<String, dynamic> toJson() => _$MobileCookiesDataToJson(this);

  factory MobileCookiesData.fromRawJson(String str) =>
      MobileCookiesData.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());

  Future<void> save() async {
    await Preferences.setStringSecurity(
        Constants.MOBILE_COOKIES_DATA, toRawJson());
  }

  Future<void> clear() async {
    await Preferences.remove(Constants.MOBILE_COOKIES_DATA);
  }

  static MobileCookiesData? load() {
    final str =
        Preferences.getStringSecurity(Constants.MOBILE_COOKIES_DATA, '');
    return str.isEmpty ? null : MobileCookiesData.fromRawJson(str);
  }
}

@JsonSerializable()
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

  factory MobileCookies.fromJson(Map<String, dynamic> json) =>
      _$MobileCookiesFromJson(json);

  Map<String, dynamic> toJson() => _$MobileCookiesToJson(this);

  factory MobileCookies.fromRawJson(String str) => MobileCookies.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}
