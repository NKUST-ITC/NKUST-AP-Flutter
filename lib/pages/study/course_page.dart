import 'package:ap_common/ap_common.dart';
import 'package:ap_common_plugin/ap_common_plugin.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/global.dart';

class CoursePage extends StatefulWidget {
  static const String routerName = '/course';

  @override
  CoursePageState createState() => CoursePageState();
}

class CoursePageState extends State<CoursePage> {
  CourseState state = CourseState.loading;

  Semester? selectSemester;
  SemesterData? semesterData;
  CourseData courseData = CourseData.empty();

  CourseNotifyData? notifyData;

  bool isOffline = false;

  String? customStateHint = '';

  final SemesterPickerController _pickerController = SemesterPickerController();

  String get courseNotifyCacheKey => PreferenceUtil.instance.getString(
        ApConstants.currentSemesterCode,
        ApConstants.semesterLatest,
      );

  @override
  void initState() {
    AnalyticsUtil.instance.setCurrentScreen('CoursePage', 'course_page.dart');
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
      state: state,
      courseData: courseData,
      notifyData: notifyData,
      customHint: isOffline ? context.ap.offlineCourse : '',
      customStateHint: customStateHint,
      enableNotifyControl: semesterData != null &&
          selectSemester!.code == semesterData!.defaultSemester.code,
      courseNotifySaveKey: courseNotifyCacheKey,
      androidResourceIcon: Constants.androidDefaultNotificationName,
      enableCaptureCourseTable: true,
      semesterData: semesterData,
      semesterPickerController: _pickerController,
      onSelect: (int index) {
        setState(() {
          selectSemester = semesterData!.data[index];
          semesterData = semesterData?.copyWith(currentIndex: index);
          state = CourseState.loading;
        });
        notifyData = CourseNotifyData.load(courseNotifyCacheKey);
        _loadCacheData(selectSemester!.code);
        if (!PreferenceUtil.instance
            .getBool(Constants.prefIsOfflineLogin, false)) {
          _getCourseTables();
        }
      },
      onRefresh: () async {
        await _getCourseTables();
        AnalyticsUtil.instance.logEvent('refresh_swipe');
        return null;
      },
    );
  }

  Future<void> _getSemester() async {
    if (PreferenceUtil.instance.getBool(Constants.prefIsOfflineLogin, false)) {
      final SemesterData? cacheData = SemesterData.load();
      if (cacheData != null && mounted) {
        setState(() {
          semesterData = cacheData;
          selectSemester = semesterData!.defaultSemester;
        });
        _loadCacheData(selectSemester!.code);
      }
      return;
    }
    try {
      final SemesterData data = await Helper.instance.getSemester();
      data.save();
      final String newSemester =
          '${Helper.username}_${data.defaultSemester.code}';
      PreferenceUtil.instance.setString(
        ApConstants.currentSemesterCode,
        newSemester,
      );
      if (mounted) {
        setState(() {
          semesterData = data;
          selectSemester = data.defaultSemester;
        });
        notifyData = CourseNotifyData.load(courseNotifyCacheKey);
        _loadCacheData(selectSemester!.code);
        _getCourseTables();
      }
    } on GeneralResponse catch (response) {
      if (mounted) {
        UiUtil.instance
            .showToast(context, response.getGeneralMessage(context));
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
    try {
      final CourseData data = await Helper.instance.getCourseTables(
        semester: selectSemester!,
        semesterDefault: semesterData!.defaultSemester,
      );
      if (mounted) {
        setState(() {
          if (data.courses.isEmpty) {
            state = CourseState.empty;
            _pickerController.markSemesterEmpty(selectSemester!);
          } else {
            courseData = data;
            isOffline = false;
            courseData.save(selectSemester!.cacheSaveTag);
            ApCommonPlugin.updateCourseWidget(courseData);
            state = CourseState.finish;
            notifyData = CourseNotifyData.load(courseNotifyCacheKey);
            _pickerController.markSemesterHasData(selectSemester!);
          }
        });
      }
    } on GeneralResponse catch (generalResponse) {
      if (mounted) {
        _pickerController.markSemesterHasData(selectSemester!);
      }
      if (await _loadCacheData(selectSemester!.code)) {
        setState(() {
          state = CourseState.custom;
          customStateHint = generalResponse.getGeneralMessage(context);
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        _pickerController.markSemesterHasData(selectSemester!);
      }
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
    }
  }
}
