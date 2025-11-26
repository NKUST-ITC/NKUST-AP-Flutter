import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/course_scaffold.dart';
import 'package:nkust_ap/widgets/semester_picker.dart';

class CoursePage extends StatefulWidget {
  static const String routerName = '/course';

  @override
  CoursePageState createState() => CoursePageState();
}

class CoursePageState extends State<CoursePage> {
  final GlobalKey<SemesterPickerState> key = GlobalKey<SemesterPickerState>();

  late ApLocalizations ap;

  CustomCourseState state = CustomCourseState.loading;
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
  Widget build(BuildContext context) {
    ap = ApLocalizations.of(context);
    return CustomCourseScaffold(
      state: state,
      courseData: courseData,
      customHint: isOffline ? ap.offlineCourse : null,
      customStateHint: customStateHint,
      itemPicker: SemesterPicker(
        key: key,
        featureTag: 'course',
        onSelect: (Semester semester, int index) {
          setState(() {
            selectSemester = semester;
            state = CustomCourseState.loading;
          });
          semesterData = key.currentState!.semesterData;
          notifyData = CourseNotifyData.load(courseNotifyCacheKey);
          _loadCacheData(semester.code);
          if (!PreferenceUtil.instance.getBool(
            Constants.prefIsOfflineLogin,
            false,
          )) {
            _getCourseTables();
          }
        },
      ),
      onRefresh: () {
        _getCourseTables();
        AnalyticsUtil.instance.logEvent('refresh_swipe');
      },
      onSearchButtonClick: () => key.currentState!.pickSemester(),
    );
  }

  Future<bool> _loadCacheData(String value) async {
    final CourseData? cacheData = CourseData.load(selectSemester!.cacheSaveTag);
    if (mounted) {
      setState(() {
        isOffline = true;
        if (cacheData == null) {
          state = CustomCourseState.offlineEmpty;
        } else {
          courseData = cacheData;
          state = courseData.courses.isEmpty
              ? CustomCourseState.empty
              : CustomCourseState.finish;
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
      callback: GeneralCallback<CourseData?>(
        onSuccess: (CourseData? data) {
          if (mounted) {
            setState(() {
              if (data == null || data.courses.isEmpty) {
                state = CustomCourseState.empty;
                key.currentState?.markSemesterEmpty(selectSemester!);
              } else {
                courseData = data;
                isOffline = false;
                courseData.save(selectSemester!.cacheSaveTag);
                state = CustomCourseState.finish;
                notifyData = CourseNotifyData.load(courseNotifyCacheKey);
                key.currentState?.markSemesterHasData(selectSemester!);
              }
            });
          }
        },
        onFailure: (DioException e) async {
          if (await _loadCacheData(selectSemester!.code) &&
              e.type != DioExceptionType.cancel) {
            setState(() {
              state = CustomCourseState.custom;
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
        onError: (GeneralResponse response) async {
          if (await _loadCacheData(selectSemester!.code)) {
            setState(() {
              state = CustomCourseState.custom;
              customStateHint = response.getGeneralMessage(context);
            });
          }
        },
      ),
    );
  }
}
