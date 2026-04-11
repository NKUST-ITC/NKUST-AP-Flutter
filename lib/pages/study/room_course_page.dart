import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/room_data.dart';

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
  CourseState state = CourseState.loading;

  Semester? selectSemester;
  SemesterData? semesterData;

  CourseData courseData = CourseData.empty();

  String? customStateHint;

  final SemesterPickerController _pickerController = SemesterPickerController();

  @override
  void initState() {
    AnalyticsUtil.instance.setCurrentScreen(
      'RoomCoursePage',
      'room_course_page.dart',
    );
    _getSemester();
    super.initState();
  }

  @override
  void dispose() {
    _pickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CourseScaffold(
      title: '${context.ap.classroomCourseTableSearch} - ${widget.room.name}',
      state: state,
      courseData: courseData,
      customStateHint: customStateHint,
      enableNotifyControl: false,
      semesterData: semesterData,
      semesterPickerController: _pickerController,
      onSelect: (int index) {
        setState(() {
          selectSemester = semesterData!.data[index];
          semesterData = semesterData?.copyWith(currentIndex: index);
          state = CourseState.loading;
        });
        _getRoomCourseTable();
      },
      onRefresh: () {
        _getRoomCourseTable();
      },
    );
  }

  Future<void> _getSemester() async {
    if (PreferenceUtil.instance.getBool(Constants.prefIsOfflineLogin, false)) {
      final SemesterData? cacheData = SemesterData.load();
      if (cacheData != null && mounted) {
        setState(() {
          semesterData = cacheData.copyWith(
            currentIndex: cacheData.defaultIndex,
          );
          selectSemester = semesterData!.defaultSemester;
        });
        _getRoomCourseTable();
      }
      return;
    }
    try {
      final SemesterData data = await Helper.instance.getSemester();
      data.save();
      if (mounted) {
        setState(() {
          semesterData = data.copyWith(currentIndex: data.defaultIndex);
          selectSemester = data.defaultSemester;
        });
        _getRoomCourseTable();
      }
    } on GeneralResponse catch (response) {
      if (mounted) {
        UiUtil.instance.showToast(context, response.getGeneralMessage(context));
      }
    } on DioException catch (e) {
      if (e.i18nMessage != null && mounted) {
        UiUtil.instance.showToast(context, e.i18nMessage!);
      }
      if (e.hasResponse) {
        AnalyticsUtil.instance.logApiEvent(
          'getSemester',
          e.response!.statusCode!,
          message: e.message ?? '',
        );
      }
    }
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
            _pickerController.markSemesterHasData(selectSemester!);
          } else {
            state = CourseState.empty;
            _pickerController.markSemesterEmpty(selectSemester!);
          }
        });
      }
    } on GeneralResponse catch (generalResponse) {
      if (mounted) {
        _pickerController.markSemesterHasData(selectSemester!);
        setState(() {
          state = CourseState.custom;
          customStateHint = generalResponse.getGeneralMessage(context);
        });
      }
    } on DioException catch (e) {
      if (e.type != DioExceptionType.cancel && mounted) {
        _pickerController.markSemesterHasData(selectSemester!);
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
