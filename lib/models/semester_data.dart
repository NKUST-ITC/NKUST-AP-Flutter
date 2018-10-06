class SemesterData {
  int status;
  String messages;
  CourseTables courseTables;

  SemesterData({
    this.status,
    this.messages,
    this.courseTables,
  });

  static SemesterData fromJson(Map<String, dynamic> json) {
    return SemesterData(
      status: json['status'],
      messages: json['messages'],
      courseTables: CourseTables.fromJson(json['coursetables']),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'messages': messages,
        'coursetables': courseTables,
      };
}

class CourseTables {
  List<Course> tuesday;
  List<Course> friday;
  List<Course> saturday;
  List<Course> thursday;
  List<Course> monday;
  List<Course> wednesday;
  List<String> timeCode;

  CourseTables({
    this.tuesday,
    this.friday,
    this.saturday,
    this.thursday,
    this.monday,
    this.wednesday,
    this.timeCode,
  });

  static CourseTables fromJson(Map<String, dynamic> json) {
    return CourseTables(
      tuesday: Course.toList(json['Tuesday']),
      friday: Course.toList(json['Friday']),
      saturday: Course.toList(json['Saturday']),
      thursday: Course.toList(json['Thursday']),
      wednesday: Course.toList(json['Wednesday']),
      monday: Course.toList(json['Monday']),
      timeCode: List<String>.from(json['timecode'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'Tuesday': tuesday,
        'Friday': friday,
        'Saturday': saturday,
        'Thursday': thursday,
        'Monday': monday,
        'Wednesday': wednesday,
        'timecode': timeCode,
      };
}

class Course {
  String title;
  String startTime;
  String endTime;
  String weekday;
  String section;
  String building;
  String room;
  List<String> instructors;

  Course({
    this.title,
    this.startTime,
    this.endTime,
    this.weekday,
    this.section,
    this.building,
    this.room,
    this.instructors,
  });

  static List<Course> toList(List<dynamic> jsonArray) {
    List<Course> list = [];
    for (var item in (jsonArray ?? [])) list.add(Course.fromJson(item));
    return list;
  }

  static Course fromJson(Map<String, dynamic> json) {
    return Course(
      title: json['title'],
      startTime: json['date']["start_time"],
      endTime: json['date']["end_time"],
      weekday: json['date']["weekday"],
      section: json['date']["section"],
      building: json['location']["building"],
      room: json['location']["room"],
      instructors: List<String>.from(json['instructors']),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'instructors': instructors,
      };
}