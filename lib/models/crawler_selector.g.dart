// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crawler_selector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrawlerSelector _$CrawlerSelectorFromJson(Map<String, dynamic> json) =>
    CrawlerSelector(
      login: json['login'] as String?,
      userInfo: json['user_info'] as String?,
      course: json['course'] as String?,
      score: json['score'] as String?,
      semester: json['semester'] as String?,
    );

Map<String, dynamic> _$CrawlerSelectorToJson(CrawlerSelector instance) =>
    <String, dynamic>{
      'login': instance.login,
      'user_info': instance.userInfo,
      'course': instance.course,
      'score': instance.score,
      'semester': instance.semester,
    };
