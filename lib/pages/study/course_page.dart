import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/semester_picker.dart';

class CoursePage extends StatefulWidget {
  static const String routerName = '/course';

  @override
  CoursePageState createState() => CoursePageState();
}

class CoursePageState extends State<CoursePage> {
  final GlobalKey<SemesterPickerState> key = GlobalKey<SemesterPickerState>();

  late ApLocalizations ap;

  CourseState state = CourseState.loading;

  Semester? selectSemester;
  SemesterData? semesterData;
  CourseData courseData = CourseData.empty();

  CourseNotifyData? notifyData;

  bool isOffline = false;

  String? customStateHint = '';

  String get courseNotifyCacheKey => PreferenceUtil.instance.getString(
        ApConstants.currentSemesterCode,
        ApConstants.semesterLatest,
      );

  @override
  void initState() {
    AnalyticsUtil.instance.setCurrentScreen('CoursePage', 'course_page.dart');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ap = ApLocalizations.of(context);
    return CourseScaffold(
      state: state,
      courseData: courseData,
      notifyData: notifyData,
      customHint: isOffline ? ap.offlineCourse : '',
      customStateHint: customStateHint,
      enableNotifyControl: semesterData != null &&
          selectSemester!.code == semesterData!.defaultSemester.code,
      courseNotifySaveKey: courseNotifyCacheKey,
      androidResourceIcon: Constants.androidDefaultNotificationName,
      enableCaptureCourseTable: true,
      itemPicker: SemesterPicker(
        key: key,
        featureTag: 'course',
        onSelect: (Semester semester, int index) {
          setState(() {
            selectSemester = semester;
            state = CourseState.loading;
          });
          semesterData = key.currentState!.semesterData;
          notifyData = CourseNotifyData.load(courseNotifyCacheKey);
          _loadCacheData(semester.code);
          if (!PreferenceUtil.instance
              .getBool(Constants.prefIsOfflineLogin, false)) {
            _getCourseTables();
          }
        },
      ),
      onRefresh: () async {
        await _getCourseTables();
        AnalyticsUtil.instance.logEvent('refresh_swipe');
        return null;
      },
      onSearchButtonClick: () {
        key.currentState!.pickSemester();
      },
    );
  }

  Future<bool> _loadCacheData(String value) async {
    final CourseData? cacheData = CourseData.load(selectSemester!.cacheSaveTag);
    if (mounted) {
      setState(() {
        isOffline = true;
        if (cacheData == null) {
          state = CourseState.offlineEmpty;
        } else {
          courseData = cacheData;
          state = courseData.courses.isEmpty
              ? CourseState.empty
              : CourseState.finish;
          notifyData = CourseNotifyData.load(courseNotifyCacheKey);
        }
      });
    }
    return cacheData == null;
  }

  Future<void> _getCourseTables() async {
    Helper.cancelToken!.cancel('');
    Helper.cancelToken = CancelToken();
    Helper.instance.getCourseTables(
      semester: selectSemester!,
      semesterDefault: semesterData!.defaultSemester,
      callback: GeneralCallback<CourseData>(
        onSuccess: (CourseData? data) {
          if (mounted) {
            setState(() {
              if (data == null || data.courses.isEmpty) {
                state = CourseState.empty;
              } else {
                courseData = data;
                isOffline = false;
                courseData.save(selectSemester!.cacheSaveTag);
                state = CourseState.finish;
                notifyData = CourseNotifyData.load(courseNotifyCacheKey);
              }
            });
          }
        },
        onFailure: (DioException e) async {
          if (await _loadCacheData(selectSemester!.code) &&
              e.type != DioExceptionType.cancel) {
            setState(() {
              state = CourseState.custom;
              customStateHint = e.i18nMessage;
            });
          }
          if (e.hasResponse) {
            AnalyticsUtil.instance.logApiEvent(
              'getCourseTables',
              e.response!.statusCode!,
              message: e.message ?? '',
            );
          }
        },
        onError: (GeneralResponse generalResponse) async {
          if (await _loadCacheData(selectSemester!.code)) {
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
