// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crawler_selector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrawlerSelector _$CrawlerSelectorFromJson(Map<String, dynamic> json) =>
    CrawlerSelector(
      login: ScraperSource.fromString(json['login'] as String),
      userInfo: ScraperSource.fromString(json['user_info'] as String),
      course: ScraperSource.fromString(json['course'] as String),
      score: ScraperSource.fromString(json['score'] as String),
      semester: ScraperSource.fromString(json['semester'] as String),
    );

Map<String, dynamic> _$CrawlerSelectorToJson(CrawlerSelector instance) =>
    <String, dynamic>{
      'login': CrawlerSelector._sourceToString(instance.login),
      'user_info': CrawlerSelector._sourceToString(instance.userInfo),
      'course': CrawlerSelector._sourceToString(instance.course),
      'score': CrawlerSelector._sourceToString(instance.score),
      'semester': CrawlerSelector._sourceToString(instance.semester),
    };
