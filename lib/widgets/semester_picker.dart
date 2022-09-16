import 'package:ap_common/callback/general_callback.dart';
import 'package:ap_common/config/ap_constants.dart';
import 'package:ap_common/models/course_notify_data.dart';
import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/analytics_utils.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/utils/notification_utils.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common/widgets/option_dialog.dart';
import 'package:ap_common_firebase/utils/firebase_analytics_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/semester_data.dart';

typedef SemesterCallback = void Function(Semester? semester, int? index);

class SemesterPicker extends StatefulWidget {
  final SemesterCallback? onSelect;
  final String? featureTag;

  const SemesterPicker({Key? key, this.onSelect, this.featureTag})
      : super(key: key);

  @override
  SemesterPickerState createState() => SemesterPickerState();
}

class SemesterPickerState extends State<SemesterPicker> {
  SemesterData? semesterData;
  Semester? selectSemester;

  int? currentIndex = 0;

  @override
  void initState() {
    _getSemester();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (semesterData != null) pickSemester();
        if (widget.featureTag != null)
          AnalyticsUtils.instance
              ?.logEvent('${widget.featureTag}_item_picker_click');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 16.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              selectSemester?.text ?? '',
              style: TextStyle(
                color: ApTheme.of(context).semesterText,
                fontSize: 18.0,
              ),
            ),
            SizedBox(width: 8.0),
            Icon(
              ApIcon.keyboardArrowDown,
              color: ApTheme.of(context).semesterText,
            )
          ],
        ),
      ),
    );
  }

  void _loadSemesterData() async {
    this.semesterData = SemesterData.load();
    if (this.semesterData == null) return;
    widget.onSelect!(semesterData!.defaultSemester, semesterData!.defaultIndex);
    if (mounted) {
      setState(() {
        selectSemester = semesterData!.defaultSemester;
      });
    }
  }

  void _getSemester() async {
    if (Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false)) {
      _loadSemesterData();
      return;
    }
    Helper.instance!.getSemester(
      callback: GeneralCallback(
        onSuccess: (SemesterData? data) {
          this.semesterData = data;
          semesterData!.save();
          var oldSemester = Preferences.getString(
            ApConstants.currentSemesterCode,
            ApConstants.semesterLatest,
          );
          final newSemester =
              '${Helper.username}_${semesterData!.defaultSemester!.code}';
          Preferences.setString(
            ApConstants.currentSemesterCode,
            newSemester,
          );
          //TODO clear old course notify, but may be improve
          if (!oldSemester.contains(semesterData!.defaultSemester!.code)) {
            CourseNotifyData notifyData = CourseNotifyData.load(oldSemester);
            if (notifyData != null && NotificationUtils.isSupport) {
              CourseNotifyData.clearOldVersionNotification(
                  tag: oldSemester, newTag: semesterData!.defaultSemester!.code);
            }
          }
          if (mounted) {
            currentIndex = semesterData!.defaultIndex;
            widget.onSelect!(
                semesterData!.defaultSemester, semesterData!.defaultIndex);
            setState(() {
              selectSemester = semesterData!.defaultSemester;
            });
          }
        },
        onFailure: (DioError e) {
          ApUtils.showToast(context, e.i18nMessage);
          if (e.hasResponse)
            FirebaseAnalyticsUtils.instance.logApiEvent(
                'getSemester', e.response!.statusCode!,
                message: e.message);
        },
        onError: (GeneralResponse response) {
          ApUtils.showToast(context, response.getGeneralMessage(context));
        },
      ),
    );
  }

  void pickSemester() {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) => SimpleOptionDialog(
        title: ApLocalizations.of(context).pickSemester,
        items: [for (var item in semesterData!.data!) item.text!],
        index: currentIndex!,
        onSelected: (index) {
          currentIndex = index;
          widget.onSelect!(semesterData!.data![currentIndex!], currentIndex);
          setState(() {
            selectSemester = semesterData!.data![currentIndex!];
          });
        },
      ),
    );
  }
}
