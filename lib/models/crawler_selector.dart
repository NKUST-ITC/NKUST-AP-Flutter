import 'dart:convert';

import 'package:ap_common/utils/preferences.dart';
import 'package:nkust_ap/config/constants.dart';

class CrawlerSelector {
  CrawlerSelector({
    this.course,
    this.score,
    this.semester,
  });

  String course;
  String score;
  String semester;

  CrawlerSelector copyWith({
    String course,
    String score,
    String semester,
  }) =>
      CrawlerSelector(
        course: course ?? this.course,
        score: score ?? this.score,
        semester: semester ?? this.semester,
      );

  factory CrawlerSelector.fromRawJson(String str) =>
      CrawlerSelector.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CrawlerSelector.fromJson(Map<String, dynamic> json) =>
      CrawlerSelector(
        course: json["course"] == null ? null : json["course"],
        score: json["score"] == null ? null : json["score"],
        semester: json["semester"] == null ? null : json["semester"],
      );

  Map<String, dynamic> toJson() => {
        "course": course == null ? null : course,
        "score": score == null ? null : score,
        "semester": semester == null ? null : semester,
      };

  void save() {
    Preferences.setString(
      Constants.CRAWLER_SELECTOR,
      this.toRawJson(),
    );
  }

  factory CrawlerSelector.load() {
    String rawString = Preferences.getString(
      Constants.CRAWLER_SELECTOR,
      '',
    );
    if (rawString == '')
      return null;
    else
      return CrawlerSelector.fromRawJson(rawString);
  }
}
