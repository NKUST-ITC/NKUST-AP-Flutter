import 'package:ap_common/callback/general_callback.dart';
import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common/widgets/default_dialog.dart';
import 'package:ap_common/widgets/hint_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/leave_data.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/semester_picker.dart';

enum _State {
  loading,
  finish,
  error,
  empty,
  offlineEmpty,
  custom,
}

class LeaveRecordPage extends StatefulWidget {
  static const String routerName = '/leave/record';

  @override
  LeaveRecordPageState createState() => LeaveRecordPageState();
}

class LeaveRecordPageState extends State<LeaveRecordPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final key = GlobalKey<SemesterPickerState>();

  ApLocalizations ap;

  _State state = _State.loading;
  String customStateHint = '';

  Orientation orientation;

  Semester selectSemester;
  SemesterData semesterData;
  LeaveData leaveData;

  double count = 1.0;

  bool hasNight = false;
  bool isOffline = false;

  TextStyle get _textBlueStyle =>
      TextStyle(color: ApTheme.of(context).blueText, fontSize: 16.0);

  TextStyle get _textStyle => TextStyle(fontSize: 15.0);

  @override
  void initState() {
    FirebaseAnalyticsUtils.instance
        .setCurrentScreen('LeaveRecordPage', 'leave_record_page.dart');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ap = ApLocalizations.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          key.currentState.pickSemester();
        },
      ),
      body: SizedBox(
        width: double.infinity,
        child: Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(height: 8.0),
            SemesterPicker(
              key: key,
              onSelect: (semester, index) {
                setState(() {
                  selectSemester = semester;
                  state = _State.loading;
                });
                if (Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false))
                  _loadOfflineLeaveData();
                else
                  _getSemesterLeaveRecord();
              },
            ),
            if (isOffline)
              Text(
                ap.offlineLeaveData,
                style: TextStyle(color: ApTheme.of(context).grey),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _getSemesterLeaveRecord();
                  FirebaseAnalyticsUtils.instance.logAction('refresh', 'swipe');
                  return null;
                },
                child: OrientationBuilder(
                  builder: (_, orientation) {
                    return _body(orientation);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get errorTitle {
    switch (state) {
      case _State.loading:
      case _State.finish:
        return '';
      case _State.error:
        return ap.somethingError;
      case _State.empty:
        return ap.leaveEmpty;
      case _State.offlineEmpty:
        return ap.noOfflineData;
      case _State.custom:
        return customStateHint;
    }
    return '';
  }

  Widget _body(Orientation orientation) {
    this.orientation = orientation;
    switch (state) {
      case _State.loading:
        return Container(
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case _State.error:
      case _State.empty:
      case _State.offlineEmpty:
      case _State.custom:
        return FlatButton(
          onPressed: () {
            if (state == _State.empty || state == _State.offlineEmpty)
              key.currentState.pickSemester();
            else
              _getSemesterLeaveRecord();
            FirebaseAnalyticsUtils.instance.logAction('retry', 'click');
          },
          child: HintContent(
            icon: ApIcon.assignment,
            content: errorTitle,
          ),
        );
      default:
        hasNight = _checkHasNight();
        final leaveTitle = _leaveTitle(leaveData.timeCodes);
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                if (hasNight && orientation == Orientation.portrait)
                  Text(ap.leaveNight),
                SizedBox(height: 16.0),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10.0,
                      ),
                    ),
                    border: Border.all(color: Colors.grey, width: 1.5),
                  ),
                  child: Table(
                    columnWidths: {
                      0: FractionColumnWidth(0.15),
                    },
                    defaultColumnWidth: FractionColumnWidth(0.85 / count),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border: TableBorder.symmetric(
                      inside: BorderSide(color: Colors.grey),
                    ),
                    children: [
                      leaveTitle,
                      for (var leave in leaveData.leaves)
                        _leaveBorder(leave, leaveData.timeCodes)
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  bool _checkHasNight() {
    if (leaveData == null) return false;
    if (leaveData.leaves == null) return false;
    for (var leave in leaveData.leaves) {
      if (leave.leaveSections == null) continue;
      for (var section in leave.leaveSections) {
        if (section.section.length > 1) return true;
      }
    }
    return false;
  }

  TableRow _leaveTitle(List<String> timeCodes) {
    List<Widget> widgets = [];
    widgets.add(_textBorder(ap.date, true));
    for (var timeCode in timeCodes) {
      if (hasNight) {
        if (orientation == Orientation.landscape)
          widgets.add(_textBorder(timeCode, true));
        else if (timeCode.length < 2) widgets.add(_textBorder(timeCode, true));
      } else if (timeCode.length < 2) widgets.add(_textBorder(timeCode, true));
    }
    count = widgets.length.toDouble();
    return TableRow(children: widgets);
  }

  Widget _textBorder(String text, bool isTitle) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
      alignment: Alignment.center,
      child: Text(
        text ?? '',
        textAlign: TextAlign.center,
        style: isTitle ? _textBlueStyle : _textStyle,
      ),
    );
  }

  TableRow _leaveBorder(Leave leave, List<String> timeCodes) {
    List<Widget> widgets = [];
    widgets.add(InkWell(
      child: _textBorder(
        leave.dateText,
        false,
      ),
      onTap: (leave.leaveSheetId.isEmpty && leave.instructorsComment.isEmpty)
          ? null
          : () {
              showDialog(
                context: context,
                builder: (BuildContext context) => DefaultDialog(
                  title: ap.leaveContent,
                  actionText: ap.iKnow,
                  actionFunction: () =>
                      Navigator.of(context, rootNavigator: true).pop('dialog'),
                  contentWidget: RichText(
                    text: TextSpan(
                      style: TextStyle(
                          color: ApTheme.of(context).grey,
                          height: 1.3,
                          fontSize: 16.0),
                      children: [
                        TextSpan(
                          text: '${ap.leaveSheetId}：',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '${leave.leaveSheetId}\n'),
                        TextSpan(
                          text: '${ap.date}：',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '${leave.date}\n'),
                        TextSpan(
                          text: '${ap.instructorsComment}：'
                              '${leave.instructorsComment.length < 8 ? '' : '\n'}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              '${leave.instructorsComment.replaceAll('：', ' ')}',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
    ));
    for (var timeCode in timeCodes) {
      if (hasNight) {
        if (orientation == Orientation.landscape)
          widgets.add(_textBorder(leave.getReason(timeCode), false));
        else if (timeCode.length < 2)
          widgets.add(_textBorder(leave.getReason(timeCode), false));
      } else if (timeCode.length < 2)
        widgets.add(_textBorder(leave.getReason(timeCode), false));
    }
    return TableRow(children: widgets);
  }

  _getSemesterLeaveRecord() async {
    Helper.cancelToken.cancel('');
    Helper.cancelToken = CancelToken();
    Helper.instance.getLeaves(
      semester: selectSemester,
      callback: GeneralCallback(
        onSuccess: (LeaveData data) {
          if (mounted)
            setState(() {
              leaveData = data;
              if (leaveData == null || leaveData.leaves.length == 0)
                state = _State.empty;
              else {
                state = _State.finish;
              }
            });
          print(state);
          leaveData.save(selectSemester.cacheSaveTag);
        },
        onFailure: (DioError e) {
          setState(() {
            state = _State.custom;
            customStateHint = ApLocalizations.dioError(context, e);
          });
          if (e.hasResponse)
            FirebaseAnalyticsUtils.instance.logApiEvent(
                'getSemesterLeaveRecord', e.response.statusCode,
                message: e.message);
          _loadOfflineLeaveData();
        },
        onError: (GeneralResponse response) {
          setState(() {
            state = _State.custom;
            customStateHint = response.getGeneralMessage(context);
          });
          _loadOfflineLeaveData();
        },
      ),
    );
  }

  void _loadOfflineLeaveData() async {
    leaveData = LeaveData.load(selectSemester.cacheSaveTag);
    if (mounted) {
      setState(() {
        isOffline = true;
        if (this.leaveData == null) {
          state = _State.offlineEmpty;
        } else {
          state = _State.finish;
        }
      });
    }
  }
}
