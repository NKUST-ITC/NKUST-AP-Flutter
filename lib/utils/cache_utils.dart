import 'dart:async';
import 'dart:convert';

import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/course_data.dart';
import 'package:nkust_ap/models/semester_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheUtils {
  static void saveSemesterData(SemesterData semesterData) async {
    if (semesterData == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        Constants.PREF_SEMESTER_DATA, jsonEncode(semesterData));
  }

  static Future<SemesterData> loadSemesterData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString(Constants.PREF_SEMESTER_DATA) ?? "";
    if (json == "") return null;
    SemesterData semesterData = SemesterData.fromJson(jsonDecode(json));
    return semesterData;
  }

  static void saveCourseData(String value, CourseData courseData) async {
    if (courseData == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        '${Constants.PREF_COURSE_DATA}_$value', jsonEncode(courseData));
  }

  static Future<CourseData> loadCourseData(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString('${Constants.PREF_COURSE_DATA}_$value') ?? "";
    if (json == "") return null;
    return CourseData.fromJson(jsonDecode(json));
  }
}
