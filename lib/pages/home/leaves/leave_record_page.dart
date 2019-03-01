import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/api/leave_response.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/default_dialog.dart';
import 'package:nkust_ap/widgets/hint_content.dart';

enum _State { loading, finish, error, empty }

class LeaveRecordPageRoute extends MaterialPageRoute {
  LeaveRecordPageRoute()
      : super(builder: (BuildContext context) => new LeaveRecordPage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: new LeaveRecordPage());
  }
}

class LeaveRecordPage extends StatefulWidget {
  static const String routerName = "/score";

  @override
  LeaveRecordPageState createState() => new LeaveRecordPageState();
}

class LeaveRecordPageState extends State<LeaveRecordPage>
    with SingleTickerProviderStateMixin {
  AppLocalizations app;

  _State state = _State.loading;

  List<TableRow> leaveWeightList = [];

  int selectSemesterIndex;

  Semester selectSemester;
  SemesterData semesterData;
  LeaveResponse leaveResponse;

  bool hasNight = false;

  Orientation orientation;

  double count = 1.0;

  @override
  void initState() {
    super.initState();
    FA.setCurrentScreen("LeaveRecordPage", "leave_record_page.dart");
    _getSemester();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _textBlueStyle() {
    return TextStyle(color: Resource.Colors.blue, fontSize: 16.0);
  }

  _textStyle() {
    return TextStyle(color: Colors.black, fontSize: 14.0);
  }

  _scoreTitle(List<String> timeCodes) {
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
        text ?? "",
        textAlign: TextAlign.center,
        style: isTitle ? _textBlueStyle() : _textStyle(),
      ),
    );
  }

  _leaveBorder(Leaves leave, List<String> timeCodes) {
    List<Widget> widgets = [];
    widgets.add(InkWell(
      child: _textBorder(leave.date.substring(4), false),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) => DefaultDialog(
              app.leaveContent,
              '${app.leaveSheetId}：${leave.leaveSheetId}\n'
              '${app.instructorsComment}：${leave.instructorsComment.length == 0 ? '' : '\n'}'
              '${leave.instructorsComment.replaceAll('：', ' ')}'),
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

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Container(
      child: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(height: 16.0),
          Expanded(
            flex: 1,
            child: FlatButton(
              onPressed: _selectSemester,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    selectSemester == null ? "" : selectSemester.text,
                    style:
                        TextStyle(color: Resource.Colors.blue, fontSize: 18.0),
                  ),
                  SizedBox(width: 8.0),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Resource.Colors.blue,
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 19,
            child: RefreshIndicator(
              onRefresh: () => _getSemesterLeaveRecord(),
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
    if (state == _State.finish) {
      hasNight = _checkHasNight();
      _renderLeavesWidget();
    }
    switch (state) {
      case _State.loading:
        return Container(
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case _State.error:
      case _State.empty:
        return FlatButton(
          onPressed:
              state == _State.error ? _getSemesterLeaveRecord : _selectSemester,
          child: HintContent(
            icon: Icons.assignment,
            content: state == _State.error ? app.clickToRetry : app.leaveEmpty,
          ),
        );
      default:
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                hasNight && orientation == Orientation.portrait
                    ? Text(app.leaveNight)
                    : Container(height: 0.0),
                SizedBox(height: 16.0),
                Container(
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10.0,
                      ),
                    ),
                    border: new Border.all(color: Colors.grey, width: 1.5),
                  ),
                  child: Table(
                    columnWidths: {
                      0: FractionColumnWidth(0.15),
                    },
                    defaultColumnWidth: FractionColumnWidth(0.85 / count),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border: TableBorder.symmetric(
                        inside: BorderSide(color: Colors.grey)),
                    children: leaveWeightList,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  void _selectSemester() {
    if (semesterData.semesters == null) return;
    var semesters = <SimpleDialogOption>[];
    for (var semester in semesterData.semesters) {
      semesters.add(_dialogItem(semesters.length, semester.text));
    }
    showDialog<int>(
        context: context,
        builder: (BuildContext context) => SimpleDialog(
            title: Text(app.picksSemester),
            children: semesters)).then<void>((int position) {
      if (position != null) {
        selectSemesterIndex = position;
        selectSemester = semesterData.semesters[selectSemesterIndex];
        _getSemesterLeaveRecord();
        setState(() {});
      }
    });
  }

  void _getSemester() {
    Helper.instance.getSemester().then((semesterData) {
      this.semesterData = semesterData;
      selectSemester = semesterData.defaultSemester;
      selectSemesterIndex = semesterData.defaultIndex;
      _getSemesterLeaveRecord();
      setState(() {});
    }).catchError((e) {
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.showToast(app.tokenExpiredContent);
            Navigator.popUntil(
                context, ModalRoute.withName(Navigator.defaultRouteName));
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            state = _State.error;
            Utils.handleDioError(e, app);
            break;
        }
      } else {
        throw e;
      }
    });
  }

  _getSemesterLeaveRecord() async {
    Helper.cancelToken.cancel("");
    Helper.cancelToken = CancelToken();
    leaveWeightList.clear();
    if (mounted) {
      setState(() {
        state = _State.loading;
      });
    }
    if (semesterData.semesters == null) {
      _getSemester();
      return;
    }
    var textList = semesterData.semesters[selectSemesterIndex].value.split(",");
    if (textList.length == 2) {
      Helper.instance.getLeaves(textList[0], textList[1]).then((response) {
        if (mounted)
          setState(() {
            leaveResponse = response;
            if (leaveResponse.status == 204)
              state = _State.empty;
            else {
              state = _State.finish;
            }
          });
      }).catchError((e) {
        if (e is DioError) {
          switch (e.type) {
            case DioErrorType.RESPONSE:
              if (e.response.statusCode == 401) {
                Utils.showToast(app.tokenExpiredContent);
                Navigator.popUntil(
                    context, ModalRoute.withName(Navigator.defaultRouteName));
              } else
                Utils.showToast(app.donateError);
              break;
            case DioErrorType.CANCEL:
              break;
            default:
              if (mounted) {
                setState(() {
                  state = _State.error;
                  Utils.handleDioError(e, app);
                });
              }
              break;
          }
        } else {
          throw e;
        }
      });
    } else {
      state = _State.error;
      setState(() {});
    }
  }

  SimpleDialogOption _dialogItem(int index, String text) {
    return SimpleDialogOption(
      child: Text(text),
      onPressed: () {
        Navigator.pop(context, index);
      },
    );
  }

  List<TableRow> _renderLeavesWidget() {
    leaveWeightList.clear();
    leaveWeightList.add(_scoreTitle(leaveResponse.timeCode));
    for (var leave in leaveResponse.leaves) {
      leaveWeightList.add(_leaveBorder(leave, leaveResponse.timeCode));
    }
    return leaveWeightList;
  }

  bool _checkHasNight() {
    if (leaveResponse == null) return false;
    if (leaveResponse.leaves == null) return false;
    for (var leave in leaveResponse.leaves) {
      if (leave.leaveSections == null) continue;
      for (var section in leave.leaveSections) {
        if (section.section.length > 1) return true;
      }
    }
    return false;
  }
}
