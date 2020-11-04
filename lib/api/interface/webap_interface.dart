import 'package:ap_common/models/general_response.dart';
import 'package:ap_common/models/semester_data.dart';
import 'package:ap_common/models/user_info.dart';
import 'package:ap_common/models/score_data.dart';
import 'package:ap_common/models/course_data.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';
import 'package:nkust_ap/models/room_data.dart';

abstract class WebApInterface {
  Future<GeneralResponse> login({String username, String password});

  Future<GeneralResponse> logout();

  Future<UserInfo> getUserInfo();

  Future<SemesterData> getSemesters();

  Future<ScoreData> getScores({String year, String value});

  Future<CourseData> getCourseTable({String year, String value});

  Future<MidtermAlertsData> getMidtermAlerts({String year, String value});

  Future<RoomData> roomList({String campusAreaId});

  Future<CourseData> getRoomCourseTable(
      {String roomId, String year, String value});
}
