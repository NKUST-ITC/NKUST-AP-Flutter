import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/widgets/dialog_option.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/semester_data.dart';
import 'package:nkust_ap/res/app_icon.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/firebase_analytics_utils.dart';
import 'package:nkust_ap/utils/preferences.dart';
import 'package:nkust_ap/utils/utils.dart';

typedef SemesterCallback = void Function(Semester semester, int index);

class SemesterPicker extends StatefulWidget {
  final SemesterCallback onSelect;

  const SemesterPicker({Key key, this.onSelect}) : super(key: key);

  @override
  SemesterPickerState createState() => SemesterPickerState();
}

class SemesterPickerState extends State<SemesterPicker> {
  SemesterData semesterData;
  Semester selectSemester;

  @override
  void initState() {
    _getSemester();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        if (semesterData != null) pickSemester();
        FA.logAction('pick_yms', 'click');
      },
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
            AppIcon.keyboardArrowDown,
            color: ApTheme.of(context).semesterText,
          )
        ],
      ),
    );
  }

  void _loadSemesterData() async {
    this.semesterData = await CacheUtils.loadSemesterData();
    if (this.semesterData == null) return;
    widget.onSelect(semesterData.defaultSemester, semesterData.defaultIndex);
    if (mounted) {
      setState(() {
        selectSemester = semesterData.defaultSemester;
      });
    }
  }

  void _getSemester() async {
    if (Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false)) {
      _loadSemesterData();
      return;
    }
    Helper.instance.getSemester().then((semesterData) {
      this.semesterData = semesterData;
      CacheUtils.saveSemesterData(semesterData);
      if (mounted) {
        widget.onSelect(
            semesterData.defaultSemester, semesterData.defaultIndex);
        setState(() {
          selectSemester = semesterData.defaultSemester;
        });
      }
    }).catchError((e) {
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.handleResponseError(context, 'getSemester', mounted, e);
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            if (mounted) Utils.handleDioError(context, e);
            break;
        }
      } else {
        throw e;
      }
      _loadSemesterData();
      //widget.onSelect(semesterData.defaultSemester, semesterData.defaultIndex);
    });
  }

  void pickSemester() {
    int index = 0;
    for (var i = 0; i < semesterData.data.length; i++) {
      if (semesterData.data[i].text == selectSemester.text) index = i;
    }
    showDialog<int>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context).picksSemester),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        contentPadding: EdgeInsets.all(0.0),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.8,
          child: ListView.separated(
            controller: ScrollController(initialScrollOffset: index * 48.0),
            itemCount: semesterData.data.length,
            separatorBuilder: (BuildContext context, int index) {
              return Divider(height: 6.0);
            },
            itemBuilder: (BuildContext context, int index) {
              return DialogOption(
                text: semesterData.data[index].text,
                check: semesterData.data[index].text == selectSemester.text,
                onPressed: () {
                  Navigator.pop(context, index);
                },
              );
            },
          ),
        ),
      ),
    ).then<void>((int position) async {
      if (position != null) {
        widget.onSelect(semesterData.data[position], position);
        setState(() {
          selectSemester = semesterData.data[position];
        });
      }
    });
  }
}
