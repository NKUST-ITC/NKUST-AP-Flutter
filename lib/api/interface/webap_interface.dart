import 'package:ap_common/ap_common.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';
import 'package:nkust_ap/models/room_data.dart';

abstract class WebApInterface {
  Future<GeneralResponse> login({
    required String username,
    required String password,
  });

  Future<GeneralResponse> logout();

  Future<UserInfo> getUserInfo();

  Future<SemesterData> getSemesters();

  Future<ScoreData> getScores({
    required String year,
    required String value,
  });

  Future<CourseData> getCourseTable({
    required String year,
    required String value,
  });

  Future<MidtermAlertsData> getMidtermAlerts({
    required String year,
    required String value,
  });

  Future<RoomData> roomList({
    required String campusAreaId,
  });

  Future<CourseData> getRoomCourseTable({
    required String roomId,
    required String year,
    required String value,
  });
}
