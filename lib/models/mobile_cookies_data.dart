import 'dart:convert';

import 'package:ap_common/ap_common.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nkust_ap/config/constants.dart';

part 'mobile_cookies_data.g.dart';

@JsonSerializable()
class MobileCookiesData {
  MobileCookiesData({
    required this.cookies,
  });

  final List<MobileCookies> cookies;

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
    await PreferenceUtil.instance.setStringSecurity(
      Constants.mobileCookiesData,
      toRawJson(),
    );
  }

  Future<void> clear() async {
    await PreferenceUtil.instance.remove(Constants.mobileCookiesData);
  }

  static MobileCookiesData? load() {
    final String str = PreferenceUtil.instance
        .getStringSecurity(Constants.mobileCookiesData, '');
    return str.isEmpty ? null : MobileCookiesData.fromRawJson(str);
  }
}

@JsonSerializable()
class MobileCookies {
  MobileCookies({
    required this.path,
    required this.name,
    required this.value,
    required this.domain,
  });

  String path;
  String name;
  String value;
  String domain;

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
