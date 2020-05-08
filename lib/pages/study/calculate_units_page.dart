import 'package:ap_common/models/score_data.dart';
import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/widgets/hint_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _State { ready, loading, finish, error, empty, offline }

class CalculateUnitsPage extends StatefulWidget {
  static const String routerName = "/calculateUnits";

  @override
  CalculateUnitsPageState createState() => new CalculateUnitsPageState();
}

class CalculateUnitsPageState extends State<CalculateUnitsPage>
    with SingleTickerProviderStateMixin {
  ApLocalizations ap;

  _State state = _State.ready;

  int currentSemesterIndex;

  Semester selectSemester;
  SemesterData semesterData;
  List<Semester> semesterList;

  double unitsTotal;
  double requiredUnitsTotal;
  double electiveUnitsTotal;
  double otherUnitsTotal;

  int startYear = 0;
  int count = 0;

  List<Score> coreGeneralEducations;
  List<Score> extendGeneralEducations;

  DateTime start;

  @override
  void initState() {
    super.initState();
    FA.setCurrentScreen("CalculateUnitsPage", "calculate_units_page.dart");
    _getSemester();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _textBlueStyle() {
    return TextStyle(color: ApTheme.of(context).blueText, fontSize: 16.0);
  }

  _textStyle() {
    return TextStyle(fontSize: 14.0);
  }

  _scoreTitle() => TableRow(
        children: <Widget>[
          _scoreTextBorder(ap.generalEductionCourse, true),
          _scoreTextBorder(ap.finalScore, true),
        ],
      );

  Widget _textBorder(String text, bool isTop) {
    return new Container(
      width: double.infinity,
      padding: EdgeInsets.all(2.0),
      decoration: new BoxDecoration(
        border: new Border(
          top: isTop
              ? BorderSide.none
              : BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Text(
        text ?? "",
        textAlign: TextAlign.center,
        style: _textBlueStyle(),
      ),
    );
  }

  Widget _scoreTextBorder(String text, bool isTitle) {
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

  _generalEducationsBorder(Score score) {
    return TableRow(children: <Widget>[
      _scoreTextBorder(score.title, false),
      _scoreTextBorder(score.finalScore, false),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    ap = ApLocalizations.of(context);
    return new Scaffold(
      // Appbar
      appBar: new AppBar(
        // Title
        title: new Text(ap.calculateUnits),
        backgroundColor: ApTheme.of(context).blue,
      ),
      body: Container(
        child: Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(height: 16.0),
            Expanded(
              flex: 1,
              child: Text(
                ap.calculateUnitsContent,
                style: TextStyle(
                    color: ApTheme.of(context).blueText, fontSize: 16.0),
              ),
            ),
            Expanded(
              flex: 19,
              child: RefreshIndicator(
                onRefresh: () async {
                  FA.logAction('refresh', 'swipe');
                  _calculate();
                  return null;
                },
                child: _body(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    switch (state) {
      case _State.loading:
        return Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 16.0),
                Text(ap.calculating, style: _textBlueStyle())
              ],
            ),
            alignment: Alignment.center);
      case _State.error:
      case _State.empty:
        return FlatButton(
          onPressed: _calculate,
          child: HintContent(
            icon: ApIcon.assignment,
            content: state == _State.error ? ap.clickToRetry : ap.scoreEmpty,
          ),
        );
      case _State.ready:
        return FlatButton(
          onPressed: _calculate,
          child: HintContent(
            icon: ApIcon.apps,
            content: ap.beginCalculate,
          ),
        );
      case _State.offline:
        return HintContent(
          icon: ApIcon.offlineBolt,
          content: ap.offlineMode,
        );
      default:
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: EdgeInsets.all(16.0),
            height: (MediaQuery.of(context).size.height - 66.0) * (19 / 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
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
                    columnWidths: const <int, TableColumnWidth>{
                      0: FlexColumnWidth(3.0),
                      1: FlexColumnWidth(1.0),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border: TableBorder.symmetric(
                        inside: BorderSide(color: Colors.grey)),
                    children: _renderScoreWidgets(),
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10.0,
                      ),
                    ),
                    border: new Border.all(color: Colors.grey, width: 1.5),
                  ),
                  child: Column(
                    children: <Widget>[
                      _textBorder(
                          "${ap.requiredUnits}：$requiredUnitsTotal", true),
                      _textBorder(
                          "${ap.electiveUnits}：$electiveUnitsTotal", false),
                      _textBorder("${ap.otherUnits}：$otherUnitsTotal", false),
                      _textBorder("${ap.unitsTotal}：$unitsTotal", false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  List<TableRow> _renderScoreWidgets() {
    List<TableRow> scoreWeightList = [];
    scoreWeightList.add(_scoreTitle());
    /*for (var i = 0; i < scoreDataList.length; i++)
      scoreWeightList.add(_scoreBorder(semesterList[i], scoreDataList[i]));*/
    for (var i in coreGeneralEducations) {
      scoreWeightList.add(_generalEducationsBorder(i));
    }
    for (var i in extendGeneralEducations) {
      scoreWeightList.add(_generalEducationsBorder(i));
    }
    return scoreWeightList;
  }

  _calculate() async {
    unitsTotal = 0.0;
    requiredUnitsTotal = 0.0;
    electiveUnitsTotal = 0.0;
    otherUnitsTotal = 0.0;

    startYear = -1;
    count = 0;
    currentSemesterIndex = 0;
    semesterList = [];
    coreGeneralEducations = [];
    extendGeneralEducations = [];
    start = DateTime.now();
    _getSemesterScore();
  }

  _getSemester() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(Constants.PREF_IS_OFFLINE_LOGIN)) {
      setState(() {
        state = _State.offline;
      });
      return;
    }
    Helper.instance.getSemester().then((semesterData) {
      this.semesterData = semesterData;
      setState(() {
        selectSemester = semesterData.defaultSemester;
      });
    }).catchError((e) {
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.handleResponseError(context, 'getSemester', mounted, e);
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            state = _State.error;
            Utils.handleDioError(context, e);
            break;
        }
      } else {
        throw e;
      }
    });
  }

  _getSemesterScore() {
    Helper.cancelToken.cancel("");
    Helper.cancelToken = CancelToken();
    setState(() {
      state = _State.loading;
    });
    if (semesterData == null || semesterData.data == null) {
      _getSemester();
      return;
    }
    Helper.instance
        .getScores(semester: semesterData.data[currentSemesterIndex])
        .then((response) {
      if (startYear == -1)
        startYear = int.parse(semesterData.data[currentSemesterIndex].year);
      //scoreWeightList.add(_scoreTitle());
      semesterList.add(semesterData.data[currentSemesterIndex]);

      if (response?.scores != null) {
        for (var score in response.scores) {
          var finalScore = double.tryParse(score.finalScore);
          if (finalScore != null) {
            if (finalScore >= 60.0) {
              if (score.required == "【必修】") {
                requiredUnitsTotal += double.parse(score.units);
              } else if (score.required == "【選修】") {
                electiveUnitsTotal += double.parse(score.units);
              } else {
                otherUnitsTotal += double.parse(score.units);
              }
              if (score.title.contains("延伸通識")) {
                extendGeneralEducations.add(score);
              } else if (score.title.contains("核心通識")) {
                coreGeneralEducations.add(score);
              }
            }
          }
        }
      }
      var currentYear = int.parse(semesterData.data[currentSemesterIndex].year);
      if (currentSemesterIndex < semesterData.data.length - 1 &&
          ((startYear - currentYear).abs() <= 6 || startYear == -1)) {
        currentSemesterIndex++;
        if (mounted) _getSemesterScore();
      } else {
        DateTime end = DateTime.now();
        var second =
            (end.millisecondsSinceEpoch - start.millisecondsSinceEpoch) / 1000;
        FA.logCalculateUnits(second);
        unitsTotal = requiredUnitsTotal + electiveUnitsTotal + otherUnitsTotal;
        if (mounted) {
          setState(() {
            state = _State.finish;
          });
        }
      }
    }).catchError((e) {
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.handleResponseError(context, 'getSemesterScore', mounted, e);
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            setState(() {
              state = _State.error;
            });
            Utils.handleDioError(context, e);
            break;
        }
      } else {
        throw e;
      }
    });
  }
}
