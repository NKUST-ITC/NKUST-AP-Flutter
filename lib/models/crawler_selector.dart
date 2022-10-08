import 'dart:convert';

import 'package:ap_common/utils/preferences.dart';
import 'package:json_annotation/json_annotation.dart';
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

  final String login;
  @JsonKey(name: 'user_info')
  final String userInfo;
  final String course;
  final String score;
  final String semester;

  CrawlerSelector copyWith({
    String? login,
    String? userInfo,
    String? course,
    String? score,
    String? semester,
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
    Preferences.setString(
      Constants.crawlerSelector,
      toRawJson(),
    );
  }

  static CrawlerSelector? load() {
    final String rawString = Preferences.getString(
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
