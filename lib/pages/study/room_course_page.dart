import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/room_data.dart';
import 'package:nkust_ap/widgets/semester_picker.dart';

class EmptyRoomPage extends StatefulWidget {
  final Room room;

  const EmptyRoomPage({
    super.key,
    required this.room,
  });

  @override
  _EmptyRoomPageState createState() => _EmptyRoomPageState();
}

class _EmptyRoomPageState extends State<EmptyRoomPage> {
  final GlobalKey<SemesterPickerState> key = GlobalKey<SemesterPickerState>();

  late ApLocalizations ap;

  CourseState state = CourseState.loading;

  late Semester selectSemester;
  SemesterData? semesterData;

  CourseData courseData = CourseData.empty();

  String? customStateHint;

  @override
  void initState() {
    AnalyticsUtil.instance.setCurrentScreen(
      'RoomCoursePage',
      'room_course_page.dart',
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ap = ApLocalizations.of(context);
    return CourseScaffold(
      title: '${ap.classroomCourseTableSearch} - ${widget.room.name}',
      state: state,
      courseData: courseData,
      customStateHint: customStateHint,
      enableNotifyControl: false,
      itemPicker: SemesterPicker(
        key: key,
        featureTag: 'room_coruse',
        onSelect: (Semester semester, int index) {
          setState(() {
            selectSemester = semester;
            state = CourseState.loading;
          });
          semesterData = key.currentState!.semesterData;
          _getRoomCourseTable();
        },
      ),
      onRefresh: () {
        _getRoomCourseTable();
      },
      onSearchButtonClick: () {
        key.currentState!.pickSemester();
      },
    );
  }

  Future<void> _getRoomCourseTable() async {
    Helper.instance.getRoomCourseTables(
      roomId: widget.room.id,
      semester: selectSemester,
      callback: GeneralCallback<CourseData>(
        onSuccess: (CourseData data) {
          courseData = data;
          if (mounted) {
            setState(() {
              if (courseData.courses.isNotEmpty) {
                state = CourseState.finish;
              } else {
                state = CourseState.empty;
              }
            });
          }
        },
        onFailure: (DioException e) async {
          if (e.type != DioExceptionType.cancel && mounted) {
            setState(() {
              state = CourseState.custom;
              customStateHint = e.i18nMessage;
            });
          }
          if (e.hasResponse) {
            AnalyticsUtil.instance.logApiEvent(
              'getRoomCourseTables',
              e.response!.statusCode!,
              message: e.message ?? '',
            );
          }
        },
        onError: (GeneralResponse generalResponse) async {
          if (mounted) {
            setState(() {
              state = CourseState.custom;
              customStateHint = generalResponse.getGeneralMessage(context);
            });
          }
        },
      ),
    );
  }
}
