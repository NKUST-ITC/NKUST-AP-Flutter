import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/api/leave_response.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/res/app_icon.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/utils/preferences.dart';
import 'package:nkust_ap/widgets/default_dialog.dart';
import 'package:nkust_ap/widgets/hint_content.dart';
import 'package:nkust_ap/widgets/semester_picker.dart';

enum _State { loading, finish, error, empty, offlineEmpty }

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

  AppLocalizations app;

  _State state = _State.loading;

  Orientation orientation;

  Semester selectSemester;
  SemesterData semesterData;
  LeavesData leaveData;

  double count = 1.0;

  bool hasNight = false;
  bool isOffline = false;

  TextStyle get _textBlueStyle =>
      TextStyle(color: Resource.Colors.blueText, fontSize: 16.0);

  TextStyle get _textStyle => TextStyle(fontSize: 15.0);

  @override
  void initState() {
    FA.setCurrentScreen('LeaveRecordPage', 'leave_record_page.dart');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    app = AppLocalizations.of(context);
    return Container(
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
              app.offlineLeaveData,
              style: TextStyle(color: Resource.Colors.grey),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (isOffline) await Helper.instance.initByPreference();
                await _getSemesterLeaveRecord();
                FA.logAction('refresh', 'swipe');
                return null;
              },
              child: OrientationBuilder(builder: (_, orientation) {
                return _body(orientation);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(Orientation orientation) {
    this.orientation = orientation;
    switch (state) {
      case _State.loading:
        return Container(
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case _State.error:
      case _State.empty:
        return FlatButton(
          onPressed: () {
            if (state == _State.error)
              _getSemesterLeaveRecord();
            else
              key.currentState.pickSemester();
            FA.logAction('retry', 'click');
          },
          child: HintContent(
            icon: AppIcon.assignment,
            content: state == _State.error ? app.clickToRetry : app.leaveEmpty,
          ),
        );
      case _State.offlineEmpty:
        return HintContent(
          icon: AppIcon.classIcon,
          content: app.noOfflineData,
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
                  Text(app.leaveNight),
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
    widgets.add(_textBorder(app.date, true));
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

  TableRow _leaveBorder(Leaves leave, List<String> timeCodes) {
    List<Widget> widgets = [];
    widgets.add(InkWell(
      child: _textBorder(leave.date.substring(4), false),
      onTap: (leave.leaveSheetId.isEmpty && leave.instructorsComment.isEmpty)
          ? null
          : () {
              showDialog(
                context: context,
                builder: (BuildContext context) => DefaultDialog(
                  title: app.leaveContent,
                  actionText: app.iKnow,
                  actionFunction: () =>
                      Navigator.of(context, rootNavigator: true).pop('dialog'),
                  contentWidget: RichText(
                    text: TextSpan(
                        style: TextStyle(
                            color: Resource.Colors.grey,
                            height: 1.3,
                            fontSize: 16.0),
                        children: [
                          TextSpan(
                              text: '${app.leaveSheetId}：',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: '${leave.leaveSheetId}\n'),
                          TextSpan(
                              text: '${app.instructorsComment}：'
                                  '${leave.instructorsComment.length < 8 ? '' : '\n'}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  '${leave.instructorsComment.replaceAll('：', ' ')}'),
                        ]),
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
    setState(() {
      leaveData = LeavesData.sample();
      if (leaveData == null)
        state = _State.empty;
      else {
        state = _State.finish;
      }
    });
    return;
    Helper.instance
        .getLeaves(selectSemester.year, selectSemester.value)
        .then((response) {
      if (mounted)
        setState(() {
          leaveData = response;
          if (leaveData == null)
            state = _State.empty;
          else {
            state = _State.finish;
          }
        });
      CacheUtils.saveLeaveData(selectSemester.value, leaveData);
    }).catchError((e) {
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.handleResponseError(
                context, 'getSemesterLeaveRecord', mounted, e);
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            if (mounted) {
              setState(() {
                state = _State.error;
                Utils.handleDioError(context, e);
              });
            }
            break;
        }
        _loadOfflineLeaveData();
      } else {
        throw e;
      }
    });
  }

  void _loadOfflineLeaveData() async {
    leaveData = await CacheUtils.loadLeaveData(selectSemester.value);
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
