class ScoreData {
  int status;
  String messages;
  Content content;

  ScoreData({
    this.status,
    this.messages,
    this.content,
  });

  static ScoreData fromJson(Map<String, dynamic> json) {
    return ScoreData(
      status: json['status'],
      messages: json['messages'],
      content: json['scores'] != null ? Content.fromJson(json['scores']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'messages': messages,
        'scores': content,
      };
}

class Content {
  List<Score> scores;
  Detail detail;

  Content({
    this.scores,
    this.detail,
  });

  static Content fromJson(Map<String, dynamic> json) {
    return Content(
      scores: Score.toList(json['scores']),
      detail: json['detail'] == null ? null : Detail.fromJson(json['detail']),
    );
  }

  Map<String, dynamic> toJson() => {
        'scores': scores,
        'detail': detail,
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

  static List<Score> toList(List<dynamic> jsonArray) {
    List<Score> list = [];
    for (var item in (jsonArray ?? [])) list.add(Score.fromJson(item));
    return list;
  }

  static Score fromJson(Map<String, dynamic> json) {
    return Score(
      title: json['title'],
      units: json['units'],
      hours: json['hours'],
      required: json['required'],
      at: json['at'],
      middleScore: json['middle_score'],
      finalScore: json['final_score'],
      remark: json['remark'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'units': units,
        'hours': hours,
        'required': required,
        'at': at,
        'middle_score': middleScore,
        'final_score': finalScore,
        'remark': remark,
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

  static Detail fromJson(Map<String, dynamic> json) {
    return Detail(
      conduct: json['conduct'],
      average: json['average'],
      classRank: json['class_rank'],
      classPercentage: json['class_percentage'],
    );
  }

  Map<String, dynamic> toJson() => {
        'conduct': conduct,
        'average': average,
        'class_rank': classRank,
        'class_percentage': classPercentage,
      };
}
