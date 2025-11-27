import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/room_data.dart';
import 'package:nkust_ap/widgets/course_scaffold.dart';
import 'package:nkust_ap/widgets/semester_picker.dart';

class EmptyRoomPage extends StatefulWidget {
  final Room room;

  const EmptyRoomPage({super.key, required this.room});

  @override
  EmptyRoomPageState createState() => EmptyRoomPageState();
}

class EmptyRoomPageState extends State<EmptyRoomPage> {
  final GlobalKey<SemesterPickerState> key = GlobalKey<SemesterPickerState>();

  late ApLocalizations ap;

  CustomCourseState state = CustomCourseState.loading;
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
    String roomDisplayName = widget.room.name;
    if (widget.room.name.startsWith('(')) {
      int depth = 0;
      for (int i = 0; i < widget.room.name.length; i++) {
        if (widget.room.name[i] == '(') {
          depth++;
        } else if (widget.room.name[i] == ')') {
          depth--;
          if (depth == 0) {
            roomDisplayName = widget.room.name.substring(i + 1).trim();
            break;
          }
        }
      }
    }

    return CustomCourseScaffold(
      title: roomDisplayName,
      state: state,
      courseData: courseData,
      customStateHint: customStateHint,
      itemPicker: SemesterPicker(
        key: key,
        featureTag: 'room_coruse',
        onSelect: (Semester semester, int index) {
          setState(() {
            selectSemester = semester;
            state = CustomCourseState.loading;
          });
          semesterData = key.currentState!.semesterData;
          _getRoomCourseTable();
        },
      ),
      onRefresh: _getRoomCourseTable,
      onSearchButtonClick: () => key.currentState!.pickSemester(),
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
              state = courseData.courses.isNotEmpty
                  ? CustomCourseState.finish
                  : CustomCourseState.empty;
            });
            if (courseData.courses.isNotEmpty) {
              key.currentState?.markSemesterHasData(selectSemester);
            } else {
              key.currentState?.markSemesterEmpty(selectSemester);
            }
          }
        },
        onFailure: (DioException e) async {
          if (e.type != DioExceptionType.cancel && mounted) {
            setState(() {
              state = CustomCourseState.custom;
              customStateHint = e.i18nMessage;
            });
            key.currentState?.markSemesterEmpty(selectSemester);
          }
          if (e.hasResponse) {
            AnalyticsUtil.instance.logApiEvent(
              'getRoomCourseTables',
              e.response!.statusCode!,
              message: e.message ?? '',
            );
          }
        },
        onError: (GeneralResponse response) async {
          if (mounted) {
            setState(() {
              state = CustomCourseState.custom;
              customStateHint = response.getGeneralMessage(context);
            });
            key.currentState?.markSemesterEmpty(selectSemester);
          }
        },
      ),
    );
  }
}
