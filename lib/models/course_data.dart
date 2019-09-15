import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class CourseData {
  List<CourseDetail> courses;
  CourseTables courseTables;

  CourseData({this.courses, this.courseTables});

  factory CourseData.fromRawJson(String str) =>
      CourseData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CourseData.fromJson(Map<String, dynamic> json) => CourseData(
        courses: json["courses"] == null
            ? null
            : List<CourseDetail>.from(
                json["courses"].map((x) => CourseDetail.fromJson(x))),
        courseTables: json["coursetable"] == null
            ? null
            : CourseTables.fromJson(json["coursetable"]),
      );

  Map<String, dynamic> toJson() => {
        "courses": courses == null
            ? null
            : List<dynamic>.from(courses.map((x) => x.toJson())),
        "coursetable": courseTables == null ? null : courseTables.toJson(),
      };

  bool get hasHoliday {
    return ((courseTables.saturday?.isEmpty) ?? false) &&
        ((courseTables.sunday?.isEmpty) ?? false);
  }
}

class CourseDetail {
  String code;
  String title;
  String className;
  String group;
  String units;
  String hours;
  String required;
  String at;
  String times;
  Location location;
  List<String> instructors;

  CourseDetail({
    this.code,
    this.title,
    this.className,
    this.group,
    this.units,
    this.hours,
    this.required,
    this.at,
    this.times,
    this.location,
    this.instructors,
  });

  factory CourseDetail.fromRawJson(String str) =>
      CourseDetail.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CourseDetail.fromJson(Map<String, dynamic> json) => CourseDetail(
        code: json["code"] == null ? null : json["code"],
        title: json["title"] == null ? null : json["title"],
        className: json["className"] == null ? null : json["className"],
        group: json["group"] == null ? null : json["group"],
        units: json["units"] == null ? null : json["units"],
        hours: json["hours"] == null ? null : json["hours"],
        required: json["required"] == null ? null : json["required"],
        at: json["at"] == null ? null : json["at"],
        times: json["times"] == null ? null : json["times"],
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        instructors: json["instructors"] == null
            ? null
            : List<String>.from(json["instructors"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "code": code == null ? null : code,
        "title": title == null ? null : title,
        "className": className == null ? null : className,
        "group": group == null ? null : group,
        "units": units == null ? null : units,
        "hours": hours == null ? null : hours,
        "required": required == null ? null : required,
        "at": at == null ? null : at,
        "times": times == null ? null : times,
        "location": location == null ? null : location.toJson(),
        "instructors": instructors == null
            ? null
            : List<dynamic>.from(instructors.map((x) => x)),
      };

  String getInstructors() {
    String text = "";
    if (instructors.length > 0) {
      text += instructors[0];
      for (var i = 1; i < instructors.length; i++) text += ",${instructors[i]}";
    }
    return text;
  }
}

class CourseTables {
  List<Course> monday;
  List<Course> tuesday;
  List<Course> wednesday;
  List<Course> thursday;
  List<Course> friday;
  List<Course> saturday;
  List<Course> sunday;
  List<String> timeCode;

  CourseTables(
      {this.monday,
      this.tuesday,
      this.wednesday,
      this.thursday,
      this.friday,
      this.saturday,
      this.sunday,
      this.timeCode});

  CourseTables.fromJson(Map<String, dynamic> json) {
    if (json['Monday'] != null) {
      monday = List<Course>();
      json['Monday'].forEach((v) {
        monday.add(Course.fromJson(v));
      });
    }
    if (json['Tuesday'] != null) {
      tuesday = List<Course>();
      json['Tuesday'].forEach((v) {
        tuesday.add(Course.fromJson(v));
      });
    }
    if (json['Wednesday'] != null) {
      wednesday = List<Course>();
      json['Wednesday'].forEach((v) {
        wednesday.add(Course.fromJson(v));
      });
    }
    if (json['Thursday'] != null) {
      thursday = List<Course>();
      json['Thursday'].forEach((v) {
        thursday.add(Course.fromJson(v));
      });
    }
    if (json['Friday'] != null) {
      friday = List<Course>();
      json['Friday'].forEach((v) {
        friday.add(Course.fromJson(v));
      });
    }
    if (json['Saturday'] != null) {
      saturday = List<Course>();
      json['Saturday'].forEach((v) {
        saturday.add(Course.fromJson(v));
      });
    }
    if (json['Sunday'] != null) {
      sunday = List<Course>();
      json['Sunday'].forEach((v) {
        sunday.add(Course.fromJson(v));
      });
    }
    timeCode = new List<String>.from(json["timeCodes"].map((x) => x));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.monday != null) {
      data['Monday'] = this.monday.map((v) => v.toJson()).toList();
    }
    if (this.tuesday != null) {
      data['Tuesday'] = this.tuesday.map((v) => v.toJson()).toList();
    }
    if (this.wednesday != null) {
      data['Wednesday'] = this.wednesday.map((v) => v.toJson()).toList();
    }
    if (this.thursday != null) {
      data['Thursday'] = this.thursday.map((v) => v.toJson()).toList();
    }
    if (this.friday != null) {
      data['Friday'] = this.friday.map((v) => v.toJson()).toList();
    }
    if (this.saturday != null) {
      data['Saturday'] = this.saturday.map((v) => v.toJson()).toList();
    }
    if (this.sunday != null) {
      data['Sunday'] = this.sunday.map((v) => v.toJson()).toList();
    }
    data['timeCodes'] = this.timeCode;
    return data;
  }

  List<Course> getCourseList(String weeks) {
    switch (weeks) {
      case "Sunday":
        return sunday;
      case "Monday":
        return monday;
      case "Tuesday":
        return tuesday;
      case "Wednesday":
        return wednesday;
      case "Thursday":
        return thursday;
      case "Friday":
        return friday;
      case "Saturday":
        return saturday;
      case "Sunday":
        return sunday;
      default:
        return [];
    }
  }

  List<Course> getCourseListByDayObject(Day weeks) {
    switch (weeks) {
      case Day.Sunday:
        return sunday;
      case Day.Monday:
        return monday;
      case Day.Tuesday:
        return tuesday;
      case Day.Wednesday:
        return wednesday;
      case Day.Thursday:
        return thursday;
      case Day.Friday:
        return friday;
      case Day.Saturday:
        return saturday;
      case Day.Sunday:
        return sunday;
      default:
        return [];
    }
  }

  int getMaxTimeCode(List<String> weeks) {
    int maxTimeCodes = 10;
    for (int i = 0; i < weeks.length; i++) {
      if (getCourseList(weeks[i]) != null)
        for (Course data in getCourseList(weeks[i])) {
          for (int j = 0; j < timeCode.length; j++) {
            if (timeCode[j] == data.date.section) {
              if ((j + 1) > maxTimeCodes) maxTimeCodes = (j + 1);
            }
          }
        }
    }
    return maxTimeCodes;
  }
}

class Course {
  String title;
  Date date;
  Location location;
  List<String> instructors;

  Course({this.title, this.date, this.location, this.instructors});

  Course.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'] != null ? Date.fromJson(json['date']) : null;
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
    instructors = json['instructors'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = this.title;
    if (this.date != null) {
      data['date'] = this.date.toJson();
    }
    if (this.location != null) {
      data['location'] = this.location.toJson();
    }
    data['instructors'] = this.instructors;
    return data;
  }

  String getInstructors() {
    String text = "";
    if (instructors.length > 0) {
      text += instructors[0];
      for (var i = 1; i < instructors.length; i++) text += ",${instructors[i]}";
    }
    return text;
  }

  Time getCourseNotifyTimeObject() {
    var formatter = new DateFormat('HH:mm', 'zh');
    DateTime dateTime =
        formatter.parse(date.startTime).add(Duration(minutes: -10));
    return Time(dateTime.hour, dateTime.minute);
  }
}

class Date {
  String startTime;
  String endTime;
  String weekday;
  String section;

  Date({this.startTime, this.endTime, this.weekday, this.section});

  Date.fromJson(Map<String, dynamic> json) {
    startTime = json['startTime'] ?? '';
    endTime = json['endTime'] ?? '';
    weekday = json['weekday'] ?? '';
    section = json['section'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['startTime'] = this.startTime;
    data['endTime'] = this.endTime;
    data['weekday'] = this.weekday;
    data['section'] = this.section;
    return data;
  }
}

class Location {
  String building;
  String room;

  Location({this.building, this.room});

  Location.fromJson(Map<String, dynamic> json) {
    building = json['building'] ?? '';
    room = json['room'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['building'] = this.building;
    data['room'] = this.room;
    return data;
  }
}
