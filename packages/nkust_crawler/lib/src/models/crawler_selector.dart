import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:nkust_crawler/src/abstractions/key_value_store.dart';
import 'package:nkust_crawler/src/registry/scraper_registry.dart';

part 'crawler_selector.g.dart';

@JsonSerializable()
class CrawlerSelector {
  CrawlerSelector({
    required this.login,
    required this.userInfo,
    required this.course,
    required this.score,
    required this.semester,
    this.leave = ScraperSource.stdsys,
  });

  @JsonKey(fromJson: ScraperSource.fromString, toJson: _sourceToString)
  final ScraperSource login;
  @JsonKey(
    name: 'user_info',
    fromJson: ScraperSource.fromString,
    toJson: _sourceToString,
  )
  final ScraperSource userInfo;
  @JsonKey(fromJson: ScraperSource.fromString, toJson: _sourceToString)
  final ScraperSource course;
  @JsonKey(fromJson: ScraperSource.fromString, toJson: _sourceToString)
  final ScraperSource score;
  @JsonKey(fromJson: ScraperSource.fromString, toJson: _sourceToString)
  final ScraperSource semester;
  @JsonKey(fromJson: _leaveFromJson, toJson: _sourceToString)
  final ScraperSource leave;

  static String _sourceToString(ScraperSource source) => source.toJsonString();

  static ScraperSource _leaveFromJson(Object? value) =>
      value is String ? ScraperSource.fromString(value) : ScraperSource.stdsys;

  CrawlerSelector copyWith({
    ScraperSource? login,
    ScraperSource? userInfo,
    ScraperSource? course,
    ScraperSource? score,
    ScraperSource? semester,
    ScraperSource? leave,
  }) =>
      CrawlerSelector(
        login: login ?? this.login,
        userInfo: userInfo ?? this.userInfo,
        course: course ?? this.course,
        score: score ?? this.score,
        semester: semester ?? this.semester,
        leave: leave ?? this.leave,
      );

  factory CrawlerSelector.fromJson(Map<String, dynamic> json) =>
      _$CrawlerSelectorFromJson(json);

  Map<String, dynamic> toJson() => _$CrawlerSelectorToJson(this);

  factory CrawlerSelector.fromRawJson(String str) => CrawlerSelector.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());

  static const String _prefKey = 'crawler_selector';

  void save() {
    crawlerStorage.setString(_prefKey, toRawJson());
  }

  static CrawlerSelector? load() {
    final String rawString = crawlerStorage.getString(_prefKey, '');
    if (rawString == '') {
      return null;
    } else {
      return CrawlerSelector.fromRawJson(rawString);
    }
  }
}
