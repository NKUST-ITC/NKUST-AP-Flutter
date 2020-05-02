import 'package:ap_common/scaffold/course_scaffold.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/semester_data.dart';
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/semester_picker.dart';

class CoursePage extends StatefulWidget {
  static const String routerName = '/course';

  @override
  CoursePageState createState() => CoursePageState();
}

class CoursePageState extends State<CoursePage> {
  final key = GlobalKey<SemesterPickerState>();

  AppLocalizations app;

  CourseState state = CourseState.loading;

  Semester selectSemester;
  SemesterData semesterData;
  CourseData courseData;

  bool isOffline = false;

  @override
  void initState() {
    FA.setCurrentScreen('CoursePage', 'course_page.dart');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return CourseScaffold(
      state: state,
      courseData: courseData,
      customHint: isOffline ? app.offlineCourse : '',
      itemPicker: SemesterPicker(
        key: key,
        onSelect: (semester, index) {
          setState(() {
            selectSemester = semester;
            state = CourseState.loading;
          });
          if (Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false))
            _loadCourseData(semester.code);
          else
            _getCourseTables();
        },
      ),
      onRefresh: () async {
        await _getCourseTables();
        FA.logAction('refresh', 'swipe');
        return null;
      },
      onSearchButtonClick: () {
        key.currentState.pickSemester();
      },
    );
  }

  void _loadCourseData(String value) async {
    courseData = await CacheUtils.loadCourseData(value);
    if (mounted) {
      setState(() {
        isOffline = true;
        if (this.courseData == null) {
          state = CourseState.offlineEmpty;
        } else {
          state = CourseState.finish;
        }
      });
    }
  }

  _getCourseTables() async {
    Helper.cancelToken.cancel('');
    Helper.cancelToken = CancelToken();
    Helper.instance
        .getCourseTables(selectSemester.year, selectSemester.value)
        .then((response) {
      if (mounted)
        setState(() {
          if (response == null) {
            state = CourseState.empty;
          } else {
            courseData = response;
            isOffline = false;
            CacheUtils.saveCourseData(selectSemester.code, courseData);
            state = CourseState.finish;
          }
        });
    }).catchError((e) {
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.handleResponseError(context, 'getCourseTables', mounted, e);
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            if (mounted)
              setState(() {
                state = CourseState.error;
              });
            Utils.handleDioError(context, e);
            break;
        }
      } else {
        throw e;
      }
      _loadCourseData(selectSemester.code);
    });
  }
}
