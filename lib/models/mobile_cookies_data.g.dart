// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobile_cookies_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MobileCookiesData _$MobileCookiesDataFromJson(Map<String, dynamic> json) =>
    MobileCookiesData(
      cookies: (json['cookies'] as List<dynamic>?)
          ?.map((e) => MobileCookies.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MobileCookiesDataToJson(MobileCookiesData instance) =>
    <String, dynamic>{
      'cookies': instance.cookies?.map((e) => e.toJson()).toList(),
    };

MobileCookies _$MobileCookiesFromJson(Map<String, dynamic> json) =>
    MobileCookies(
      path: json['path'] as String?,
      name: json['name'] as String?,
      value: json['value'] as String?,
      domain: json['domain'] as String?,
    );

Map<String, dynamic> _$MobileCookiesToJson(MobileCookies instance) =>
    <String, dynamic>{
      'path': instance.path,
      'name': instance.name,
      'value': instance.value,
      'domain': instance.domain,
    };
