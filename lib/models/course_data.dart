import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class CourseData {
  int status;
  String messages;
  CourseTables courseTables;

  CourseData({
    this.status,
    this.messages,
    this.courseTables,
  });

  static CourseData fromJson(Map<String, dynamic> json) {
    return CourseData(
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
  List<Course> sunday;
  List<Course> tuesday;
  List<Course> friday;
  List<Course> saturday;
  List<Course> thursday;
  List<Course> monday;
  List<Course> wednesday;
  List<String> timeCode;

  CourseTables({
    this.sunday,
    this.tuesday,
    this.friday,
    this.saturday,
    this.thursday,
    this.monday,
    this.wednesday,
    this.timeCode,
  });

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
        for (var data in getCourseList(weeks[i])) {
          for (int j = 0; j < timeCode.length; j++) {
            if (timeCode[j] == data.section) {
              if ((j + 1) > maxTimeCodes) maxTimeCodes = (j + 1);
            }
          }
        }
    }
    return maxTimeCodes;
  }

  static CourseTables fromJson(Map<String, dynamic> json) {
    return CourseTables(
      sunday: Course.toList(json['Sunday']),
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
        'Sunday': sunday,
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
        instructors: List<String>.from(json['instructors']));
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
    DateTime dateTime = formatter.parse(startTime).add(Duration(minutes: -10));
    return Time(dateTime.hour, dateTime.minute);
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'instructors': instructors,
      };
}
