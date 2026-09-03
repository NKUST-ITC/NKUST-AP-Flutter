import 'package:ap_common/ap_common.dart';
import 'package:ap_common_plugin/ap_common_plugin.dart';
import 'package:flutter/material.dart';
import 'package:nkust_crawler/nkust_crawler.dart';
import 'package:nkust_ap/api/exceptions/api_exception_l10n.dart';
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

  /// API-fetched course data (before merging custom courses).
  CourseData? _apiCourseData;

  CustomCourseData _customCourseData = CustomCourseData();

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
      enableCustomCourse: true,
      customCourseData: _customCourseData,
      onCustomCourseChanged: _onCustomCourseChanged,
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
          semesterData = cacheData.copyWith(
            currentIndex: cacheData.defaultIndex,
          );
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
          semesterData = data.copyWith(currentIndex: data.defaultIndex);
          selectSemester = data.defaultSemester;
        });
        notifyData = CourseNotifyData.load(courseNotifyCacheKey);
        _loadCacheData(selectSemester!.code);
        _getCourseTables();
      }
    } on ApException catch (e) {
      if (e is CancelledException) return;
      if (mounted) {
        UiUtil.instance.showToast(context, e.toLocalizedMessage(context));
      }
      if (e is ServerException && e.httpStatusCode != null) {
        AnalyticsUtil.instance.logApiEvent(
          'getSemester',
          e.httpStatusCode!,
          message: e.message,
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
          _apiCourseData = cacheData;
          _customCourseData = CustomCourseData.load(courseNotifyCacheKey);
          courseData = cacheData.mergeCustom(_customCourseData.courses);
          // Any non-null cache (even if courses list is empty) maps to
          // `finish` so the offline view renders an empty course grid
          // rather than the `empty` error state which hides the table.
          // Matches ScorePage's _loadOfflineScoreData behaviour.
          state = CourseState.finish;
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
      );
      if (mounted) {
        _apiCourseData = data;
        // Only persist non-empty course data so a bad fetch (parser
        // hiccup / transient empty response) doesn't overwrite a
        // previously-working offline copy with nothing.
        if (data.courses.isNotEmpty) {
          data.save(selectSemester!.cacheSaveTag);
        }
        _customCourseData = CustomCourseData.load(courseNotifyCacheKey);
        courseData = data.mergeCustom(_customCourseData.courses);
        setState(() {
          if (courseData.courses.isEmpty) {
            state = CourseState.empty;
            _pickerController.markSemesterEmpty(selectSemester!);
          } else {
            isOffline = false;
            state = CourseState.finish;
            notifyData = CourseNotifyData.load(courseNotifyCacheKey);
            _pickerController.markSemesterHasData(selectSemester!);
          }
        });
        if (courseData.courses.isNotEmpty &&
            selectSemester!.code == semesterData!.defaultSemester.code) {
          await ApCommonPlugin.updateCourseWidget(courseData);
        }
      }
    } on ApException catch (e) {
      if (mounted) {
        _pickerController.markSemesterHasData(selectSemester!);
      }
      if (await _loadCacheData(selectSemester!.code) &&
          e is! CancelledException) {
        setState(() {
          state = CourseState.custom;
          customStateHint = e.toLocalizedMessage(context);
        });
      }
      if (e is ServerException && e.httpStatusCode != null) {
        AnalyticsUtil.instance.logApiEvent(
          'getCourseTables',
          e.httpStatusCode!,
          message: e.message,
        );
      }
    }
  }

  void _onCustomCourseChanged(CustomCourseData updated) {
    _customCourseData = CustomCourseData(
      courses: updated.courses,
      tag: courseNotifyCacheKey,
    );
    _customCourseData.save();
    if (_apiCourseData != null && mounted) {
      setState(() {
        courseData = _apiCourseData!.mergeCustom(_customCourseData.courses);
        if (courseData.courses.isEmpty) {
          state = CourseState.empty;
        } else {
          state = CourseState.finish;
        }
      });
    }
  }
}
