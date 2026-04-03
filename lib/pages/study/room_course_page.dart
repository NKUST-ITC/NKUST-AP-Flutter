import 'package:ap_common/ap_common.dart' hide SemesterPicker;
import 'package:ap_common_flutter_ui/ap_common_flutter_ui.dart' as ap_ui;
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
  late ApLocalizations ap;

  CourseState state = CourseState.loading;

  Semester? selectSemester;
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
    ap = context.ap;
    return CourseScaffold(
      title: '${ap.classroomCourseTableSearch} - ${widget.room.name}',
      state: state,
      courseData: courseData,
      customStateHint: customStateHint,
      enableNotifyControl: false,
      semesterData: semesterData,
      onSelect: (int index) {
        setState(() {
          selectSemester = semesterData!.data[index];
          semesterData = semesterData?.copyWith(currentIndex: index);
          state = CourseState.loading;
        });
        _getRoomCourseTable();
      },
      itemPicker: SemesterPicker(
        featureTag: 'room_coruse',
        selectSemester: selectSemester,
        currentIndex: semesterData?.currentIndex ?? 0,
        onDataLoaded: (SemesterData data) => semesterData = data,
        onSelect: (Semester semester, int index) {
          setState(() {
            selectSemester = semester;
            semesterData = semesterData?.copyWith(currentIndex: index);
            state = CourseState.loading;
          });
          _getRoomCourseTable();
        },
      ),
      onRefresh: () {
        _getRoomCourseTable();
      },
      onSearchButtonClick: () {
        if (semesterData != null) {
          ap_ui.SemesterPicker.show(
            context: context,
            semesterData: semesterData!,
            currentIndex: semesterData!.currentIndex,
            onSelect: (Semester semester, int index) {
              setState(() {
                selectSemester = semester;
                semesterData = semesterData?.copyWith(currentIndex: index);
                state = CourseState.loading;
              });
              _getRoomCourseTable();
            },
          );
        }
      },
    );
  }

  Future<void> _getRoomCourseTable() async {
    try {
      final CourseData data = await Helper.instance.getRoomCourseTables(
        roomId: widget.room.id,
        semester: selectSemester!,
      );
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
    } on GeneralResponse catch (generalResponse) {
      if (mounted) {
        setState(() {
          state = CourseState.custom;
          customStateHint = generalResponse.getGeneralMessage(context);
        });
      }
    } on DioException catch (e) {
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
    }
  }
}
