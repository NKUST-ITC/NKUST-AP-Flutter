import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/models/course_data.dart';
import 'package:nkust_ap/models/leaves_data.dart';
import 'package:nkust_ap/models/schedule_data.dart';
import 'package:nkust_ap/models/score_data.dart';
import 'package:nkust_ap/models/semester_data.dart';
import 'package:nkust_ap/models/user_info.dart';
import 'package:nkust_ap/utils/preferences.dart';

class CacheUtils {
  static void saveSemesterData(SemesterData semesterData) async {
    if (semesterData == null) return;
    Preferences.setString(
        Constants.PREF_SEMESTER_DATA, jsonEncode(semesterData));
  }

  static Future<SemesterData> loadSemesterData() async {
    String json = Preferences.getString(Constants.PREF_SEMESTER_DATA, '');
    if (json == '') return null;
    SemesterData semesterData = SemesterData.fromJson(jsonDecode(json));
    return semesterData;
  }

  static void saveCourseData(String value, CourseData courseData) async {
    if (courseData == null) return;
    String username = Preferences.getString(Constants.PREF_USERNAME, '');
    await Preferences.setString(
        '${Constants.PREF_COURSE_DATA}_${username}_$value',
        jsonEncode(courseData));
  }

  static Future<CourseData> loadCourseData(String value) async {
    String username = Preferences.getString(Constants.PREF_USERNAME, '');
    String json = Preferences.getString(
        '${Constants.PREF_COURSE_DATA}_${username}_$value', '');
    if (json == '') return null;
    return CourseData.fromJson(jsonDecode(json));
  }

  static void saveScoreData(String value, ScoreData scoreData) async {
    if (scoreData == null) return;
    String username = Preferences.getString(Constants.PREF_USERNAME, '');
    await Preferences.setString(
        '${Constants.PREF_SCORE_DATA}_${username}_$value',
        jsonEncode(scoreData));
  }

  static Future<ScoreData> loadScoreData(String value) async {
    String username = Preferences.getString(Constants.PREF_USERNAME, '');
    String json = Preferences.getString(
        '${Constants.PREF_SCORE_DATA}_${username}_$value', '');
    if (json == '') return null;
    return ScoreData.fromJson(jsonDecode(json));
  }

  static void saveScheduleDataList(List<ScheduleData> scheduleDataList) async {
    if (scheduleDataList == null) return;
    await Preferences.setString(
        Constants.PREF_SCHEDULE_DATA, jsonEncode(scheduleDataList));
  }

  static Future<List<ScheduleData>> loadScheduleDataList() async {
    String json = Preferences.getString(Constants.PREF_SCHEDULE_DATA, '');
    if (json == '') return null;
    return ScheduleData.toList(jsonDecode(json));
  }

  static void saveUserInfo(UserInfo userInfo) async {
    if (userInfo == null) return;

    String username = Preferences.getString(Constants.PREF_USERNAME, '');
    await Preferences.setString(
        '${Constants.PREF_USER_INFO}_$username', jsonEncode(userInfo));
  }

  static Future<UserInfo> loadUserInfo() async {
    String username = Preferences.getString(Constants.PREF_USERNAME, '');
    String json =
        Preferences.getString('${Constants.PREF_USER_INFO}_$username', '');
    if (json == '') return null;
    return UserInfo.fromJson(jsonDecode(json));
  }

  static void saveLeaveData(String value, LeavesData leaveData) async {
    if (leaveData == null) return;
    String username = Preferences.getString(Constants.PREF_USERNAME, '');
    await Preferences.setString(
        '${Constants.PREF_LEAVE_DATA}_${username}_$value',
        jsonEncode(leaveData));
  }

  static Future<LeavesData> loadLeaveData(String value) async {
    String username = Preferences.getString(Constants.PREF_USERNAME, '');
    String json = Preferences.getString(
        '${Constants.PREF_LEAVE_DATA}_${username}_$value', '');
    if (json == '') return null;
    return LeavesData.fromJson(jsonDecode(json));
  }

  static void saveBusReservationsData(
      BusReservationsData busReservationsData) async {
    if (busReservationsData == null) return;
    String username = Preferences.getString(Constants.PREF_USERNAME, '');
    await Preferences.setString(
        '${Constants.PREF_BUS_RESERVATIONS_DATA}_$username',
        jsonEncode(busReservationsData));
  }

  static Future<BusReservationsData> loadBusReservationsData() async {
    String username = Preferences.getString(Constants.PREF_USERNAME, '');
    String json = Preferences.getString(
        '${Constants.PREF_BUS_RESERVATIONS_DATA}_$username', '');
    if (json == '') return null;
    return BusReservationsData.fromJson(jsonDecode(json));
  }

  static void savePictureData(Uint8List bytes) async {
    if (bytes == null) return;

    String username = Preferences.getString(Constants.PREF_USERNAME, '');
    await Preferences.setString(
        '${Constants.PREF_PICTURE_DATA}_$username', base64.encode(bytes));
  }

  static Future<Uint8List> loadPictureData() async {
    String username = Preferences.getString(Constants.PREF_USERNAME, '');
    String base64String =
        Preferences.getString('${Constants.PREF_PICTURE_DATA}_$username', '');
    if (base64String == '') return null;
    return base64.decode(base64String);
  }
}
