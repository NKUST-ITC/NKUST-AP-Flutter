import 'dart:async';
import 'dart:convert';

import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/course_data.dart';
import 'package:nkust_ap/models/schedule_data.dart';
import 'package:nkust_ap/models/score_data.dart';
import 'package:nkust_ap/models/semester_data.dart';
import 'package:nkust_ap/models/user_info.dart';
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
    String username = prefs.getString(Constants.PREF_USERNAME) ?? '';
    await prefs.setString('${Constants.PREF_COURSE_DATA}_${username}_$value',
        jsonEncode(courseData));
  }

  static Future<CourseData> loadCourseData(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString(Constants.PREF_USERNAME) ?? '';
    String json =
        prefs.getString('${Constants.PREF_COURSE_DATA}_${username}_$value') ??
            '';
    if (json == '') return null;
    return CourseData.fromJson(jsonDecode(json));
  }

  static void saveScoreData(String value, ScoreData scoreData) async {
    if (scoreData == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString(Constants.PREF_USERNAME) ?? '';
    await prefs.setString('${Constants.PREF_SCORE_DATA}_${username}_$value',
        jsonEncode(scoreData));
  }

  static Future<ScoreData> loadScoreData(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString(Constants.PREF_USERNAME) ?? '';
    String json =
        prefs.getString('${Constants.PREF_SCORE_DATA}_${username}_$value') ??
            '';
    if (json == '') return null;
    return ScoreData.fromJson(jsonDecode(json));
  }

  static void saveScheduleDataList(List<ScheduleData> scheduleDataList) async {
    if (scheduleDataList == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        Constants.PREF_SCHEDULE_DATA, jsonEncode(scheduleDataList));
  }

  static Future<List<ScheduleData>> loadScheduleDataList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString(Constants.PREF_SCHEDULE_DATA) ?? '';
    if (json == '') return null;
    return ScheduleData.toList(jsonDecode(json));
  }

  static void saveUserInfo(UserInfo userInfo) async {
    if (userInfo == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString(Constants.PREF_USERNAME) ?? '';
    await prefs.setString(
        '${Constants.PREF_USER_INFO}_$username', jsonEncode(userInfo));
  }

  static Future<UserInfo> loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString(Constants.PREF_USERNAME) ?? '';
    String json =
        prefs.getString('${Constants.PREF_USER_INFO}_$username') ?? '';
    if (json == '') return null;
    return UserInfo.fromJson(jsonDecode(json));
  }
}
