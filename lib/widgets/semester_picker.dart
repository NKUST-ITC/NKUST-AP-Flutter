import 'package:ap_common/ap_common.dart';
import 'package:ap_common_flutter_ui/ap_common_flutter_ui.dart' as ap_ui;
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/config/constants.dart';

typedef SemesterCallback = void Function(Semester semester, int index);

class SemesterPicker extends StatefulWidget {
  final SemesterCallback? onSelect;
  final Function(SemesterData data)? onDataLoaded;
  final String? featureTag;
  final Semester? selectSemester;
  final int currentIndex;

  const SemesterPicker({
    super.key,
    this.onSelect,
    this.onDataLoaded,
    this.featureTag,
    this.selectSemester,
    this.currentIndex = 0,
  });

  @override
  SemesterPickerState createState() => SemesterPickerState();
}

class SemesterPickerState extends State<SemesterPicker> {
  late SemesterData semesterData;
  Semester? selectSemester;

  int currentIndex = 0;

  @override
  void initState() {
    selectSemester = widget.selectSemester;
    currentIndex = widget.currentIndex;
    _getSemester();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SemesterPicker oldWidget) {
    if (widget.selectSemester != null &&
        widget.selectSemester != oldWidget.selectSemester) {
      setState(() {
        selectSemester = widget.selectSemester;
      });
    }
    if (widget.currentIndex != oldWidget.currentIndex) {
      setState(() {
        currentIndex = widget.currentIndex;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          //ignore: unnecessary_null_comparison
          if (semesterData != null) pickSemester();
          if (widget.featureTag != null) {
            AnalyticsUtil.instance
                .logEvent('${widget.featureTag}_item_picker_click');
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.calendar_month_rounded,
                size: 16,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 6),
              Text(
                selectSemester?.text ?? '',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 20,
                color: colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadSemesterData() async {
    final SemesterData? cacheData = SemesterData.load();
    if (cacheData != null) {
      semesterData = cacheData;
      widget.onDataLoaded?.call(semesterData);
      if (selectSemester == null) {
        widget.onSelect
            ?.call(semesterData.defaultSemester, semesterData.defaultIndex);
        if (mounted) {
          setState(() {
            selectSemester = semesterData.defaultSemester;
            currentIndex = semesterData.defaultIndex;
          });
        }
      }
    }
  }

  Future<void> _getSemester() async {
    if (PreferenceUtil.instance.getBool(Constants.prefIsOfflineLogin, false)) {
      _loadSemesterData();
      return;
    }
    Helper.instance.getSemester(
      callback: GeneralCallback<SemesterData>(
        onSuccess: (SemesterData data) {
          semesterData = data;
          semesterData.save();
          widget.onDataLoaded?.call(semesterData);
          final String _ = PreferenceUtil.instance.getString(
            ApConstants.currentSemesterCode,
            ApConstants.semesterLatest,
          );
          final String newSemester =
              '${Helper.username}_${semesterData.defaultSemester.code}';
          PreferenceUtil.instance.setString(
            ApConstants.currentSemesterCode,
            newSemester,
          );
          if (mounted && selectSemester == null) {
            currentIndex = semesterData.defaultIndex;
            widget.onSelect?.call(
              semesterData.defaultSemester,
              semesterData.defaultIndex,
            );
            setState(() {
              selectSemester = semesterData.defaultSemester;
            });
          }
        },
        onFailure: (DioException e) {
          if (e.i18nMessage != null) {
            UiUtil.instance.showToast(context, e.i18nMessage!);
          }
          if (e.hasResponse) {
            AnalyticsUtil.instance.logApiEvent(
              'getSemester',
              e.response!.statusCode!,
              message: e.message ?? '',
            );
          }
        },
        onError: (GeneralResponse response) {
          UiUtil.instance
              .showToast(context, response.getGeneralMessage(context));
        },
      ),
    );
  }

  void pickSemester() {
    ap_ui.SemesterPicker.show(
      context: context,
      semesterData: semesterData,
      currentIndex: currentIndex,
      onSelect: (Semester semester, int index) {
        currentIndex = index;
        widget.onSelect!(semesterData.data[currentIndex], currentIndex);
        setState(() {
          selectSemester = semesterData.data[currentIndex];
        });
      },
      featureTag: widget.featureTag,
    );
  }
}
