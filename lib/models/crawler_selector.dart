import 'dart:convert';

import 'package:ap_common/ap_common.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nkust_ap/api/scraper_registry.dart';
import 'package:nkust_ap/config/constants.dart';

part 'crawler_selector.g.dart';

@JsonSerializable()
class CrawlerSelector {
  CrawlerSelector({
    required this.login,
    required this.userInfo,
    required this.course,
    required this.score,
    required this.semester,
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

  static String _sourceToString(ScraperSource source) => source.toJsonString();

  CrawlerSelector copyWith({
    ScraperSource? login,
    ScraperSource? userInfo,
    ScraperSource? course,
    ScraperSource? score,
    ScraperSource? semester,
  }) =>
      CrawlerSelector(
        login: login ?? this.login,
        userInfo: userInfo ?? this.userInfo,
        course: course ?? this.course,
        score: score ?? this.score,
        semester: semester ?? this.semester,
      );

  factory CrawlerSelector.fromJson(Map<String, dynamic> json) =>
      _$CrawlerSelectorFromJson(json);

  Map<String, dynamic> toJson() => _$CrawlerSelectorToJson(this);

  factory CrawlerSelector.fromRawJson(String str) => CrawlerSelector.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());

  void save() {
    PreferenceUtil.instance.setString(
      Constants.crawlerSelector,
      toRawJson(),
    );
  }

  static CrawlerSelector? load() {
    final String rawString = PreferenceUtil.instance.getString(
      Constants.crawlerSelector,
      '',
    );
    if (rawString == '') {
      return null;
    } else {
      return CrawlerSelector.fromRawJson(rawString);
    }
  }
}
