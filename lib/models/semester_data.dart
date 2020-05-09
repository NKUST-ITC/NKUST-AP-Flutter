// To parse this JSON data, do
//
//     final semesterData = semesterDataFromJson(jsonString);

import 'dart:convert';

import 'package:nkust_ap/api/helper.dart';

class SemesterData {
  List<Semester> data;
  Semester defaultSemester;
  int defaultIndex;

  SemesterData({
    this.data,
    this.defaultSemester,
  }) {
    defaultIndex = getDefaultIndex();
  }

  getDefaultIndex() {
    for (var i = 0; i < data.length; i++)
      if (defaultSemester.text == data[i].text) return i;
    return 0;
  }

  factory SemesterData.fromRawJson(String str) =>
      SemesterData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SemesterData.fromJson(Map<String, dynamic> json) => new SemesterData(
        data: new List<Semester>.from(
            json["data"].map((x) => Semester.fromJson(x))),
        defaultSemester: Semester.fromJson(json["default"]),
      );

  Map<String, dynamic> toJson() => {
        "data": new List<dynamic>.from(data.map((x) => x.toJson())),
        "default": defaultSemester.toJson(),
      };
}

class Semester {
  String year;
  String value;
  String text;

  String get code => '$year$value';

  String get cacheSaveTag => '${Helper.username}_$code';

  Semester({
    this.year,
    this.value,
    this.text,
  });

  factory Semester.fromRawJson(String str) =>
      Semester.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Semester.fromJson(Map<String, dynamic> json) => new Semester(
        year: json["year"],
        value: json["value"],
        text: json["text"],
      );

  Map<String, dynamic> toJson() => {
        "year": year,
        "value": value,
        "text": text,
      };
}
