// To parse this JSON data, do
//
//     final scoreData = scoreDataFromJson(jsonString);

import 'dart:convert';

class ScoreData {
  List<Score> scores;
  Detail detail;

  ScoreData({
    this.scores,
    this.detail,
  });

  factory ScoreData.fromRawJson(String str) =>
      ScoreData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ScoreData.fromJson(Map<String, dynamic> json) => new ScoreData(
        scores:
            new List<Score>.from(json["scores"].map((x) => Score.fromJson(x))),
        detail: Detail.fromJson(json["detail"]),
      );

  Map<String, dynamic> toJson() => {
        "scores": new List<dynamic>.from(scores.map((x) => x.toJson())),
        "detail": detail.toJson(),
      };
}

class Detail {
  double conduct;
  double average;
  String classRank;
  double classPercentage;

  Detail({
    this.conduct,
    this.average,
    this.classRank,
    this.classPercentage,
  });

  factory Detail.fromRawJson(String str) => Detail.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Detail.fromJson(Map<String, dynamic> json) => new Detail(
        conduct: json["conduct"],
        average: json["average"],
        classRank: json["classRank"],
        classPercentage: json["classPercentage"],
      );

  Map<String, dynamic> toJson() => {
        "conduct": conduct,
        "average": average,
        "classRank": classRank,
        "classPercentage": classPercentage,
      };
}

class Score {
  String title;
  String units;
  String hours;
  String required;
  String at;
  String middleScore;
  String finalScore;
  String remark;

  Score({
    this.title,
    this.units,
    this.hours,
    this.required,
    this.at,
    this.middleScore,
    this.finalScore,
    this.remark,
  });

  factory Score.fromRawJson(String str) => Score.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Score.fromJson(Map<String, dynamic> json) => new Score(
        title: json["title"],
        units: json["units"],
        hours: json["hours"],
        required: json["required"],
        at: json["at"],
        middleScore: json["middleScore"],
        finalScore: json["finalScore"],
        remark: json["remark"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "units": units,
        "hours": hours,
        "required": required,
        "at": at,
        "middleScore": middleScore,
        "finalScore": finalScore,
        "remark": remark,
      };
}
