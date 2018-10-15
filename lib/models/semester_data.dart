class SemesterData {
  List<Semester> semesters;
  Semester defaultSemester;

  SemesterData({
    this.semesters,
    this.defaultSemester,
  });

  static SemesterData fromJson(Map<String, dynamic> json) {
    return SemesterData(
      semesters: Semester.toList(json['semester']),
      defaultSemester:Semester.fromJson(json['default']) ,
    );
  }

  Map<String, dynamic> toJson() => {
        'semester': semesters,
        'default': defaultSemester,
      };
}

class Semester {
  String value;
  int selected;
  String text;

  Semester({
    this.value,
    this.selected,
    this.text,
  });

  static List<Semester> toList(List<dynamic> jsonArray) {
    List<Semester> list = [];
    for (var item in (jsonArray ?? [])) list.add(Semester.fromJson(item));
    return list;
  }

  static Semester fromJson(Map<String, dynamic> json) {
    return Semester(
      value: json['value'],
      selected: json['selected'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'selected': selected,
        'text': text,
      };
}
