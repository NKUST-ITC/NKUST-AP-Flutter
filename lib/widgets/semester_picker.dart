import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/config/constants.dart';

typedef SemesterCallback = void Function(Semester semester, int index);

class SemesterPicker extends StatefulWidget {
  final SemesterCallback? onSelect;
  final String? featureTag;

  const SemesterPicker({super.key, this.onSelect, this.featureTag});

  @override
  SemesterPickerState createState() => SemesterPickerState();
}

class SemesterPickerState extends State<SemesterPicker> {
  late SemesterData semesterData;
  Semester? selectSemester;

  int currentIndex = 0;

  @override
  void initState() {
    _getSemester();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primaryContainer.withAlpha(77),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          if (selectSemester != null) pickSemester();
          if (widget.featureTag != null) {
            AnalyticsUtil.instance
                .logEvent('${widget.featureTag}_item_picker_click');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.calendar_month_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8.0),
              Text(
                selectSemester?.text ?? '',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4.0),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colorScheme.primary,
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
      widget.onSelect
          ?.call(semesterData.defaultSemester, semesterData.defaultIndex);
      if (mounted) {
        setState(() {
          selectSemester = semesterData.defaultSemester;
        });
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
          final String newSemester =
              '${Helper.username}_${semesterData.defaultSemester.code}';
          PreferenceUtil.instance.setString(
            ApConstants.currentSemesterCode,
            newSemester,
          );
          if (mounted) {
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    showDialog<int>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(ApLocalizations.of(context).pickSemester),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: semesterData.data.length,
            itemBuilder: (BuildContext context, int index) {
              final bool isSelected = index == currentIndex;
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                selected: isSelected,
                selectedTileColor: colorScheme.primaryContainer.withAlpha(77),
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  semesterData.data[index].text,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  currentIndex = index;
                  widget.onSelect!(semesterData.data[currentIndex], currentIndex);
                  setState(() {
                    selectSemester = semesterData.data[currentIndex];
                  });
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
