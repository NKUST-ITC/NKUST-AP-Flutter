import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/hint_content.dart';

enum _State { ready, loading, finish, error, empty }

class CalculateUnitsPageRoute extends MaterialPageRoute {
  CalculateUnitsPageRoute()
      : super(builder: (BuildContext context) => new CalculateUnitsPage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(
        opacity: animation, child: new CalculateUnitsPage());
  }
}

class CalculateUnitsPage extends StatefulWidget {
  static const String routerName = "/calculateUnits";

  @override
  CalculateUnitsPageState createState() => new CalculateUnitsPageState();
}

class CalculateUnitsPageState extends State<CalculateUnitsPage>
    with SingleTickerProviderStateMixin {
  AppLocalizations app;

  _State state = _State.ready;

  int currentSemesterIndex;

  Semester selectSemester;
  SemesterData semesterData;
  List<Semester> semesterList;
  List<ScoreData> scoreDataList;

  double unitsTotal;
  double requiredUnitsTotal;
  double electiveUnitsTotal;
  double otherUnitsTotal;

  int startYear = 0;

  List<Score> coreGeneralEducations;
  List<Score> extendGeneralEducations;

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
    return TextStyle(color: Resource.Colors.blue, fontSize: 16.0);
  }

  _textStyle() {
    return TextStyle(color: Colors.black, fontSize: 14.0);
  }

  _scoreTitle() => TableRow(
        children: <Widget>[
          _scoreTextBorder(app.generalEductionCourse, true),
          _scoreTextBorder(app.finalScore, true),
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

  _scoreBorder(Semester semester, ScoreData score) {
    return TableRow(children: <Widget>[
      _scoreTextBorder(semester.text, false),
      _scoreTextBorder("${score.content.detail.average}", false),
      _scoreTextBorder("${score.content.detail.classRank}", false)
    ]);
  }

  _generalEducationsBorder(Score score) {
    return TableRow(children: <Widget>[
      _scoreTextBorder(score.title, false),
      _scoreTextBorder(score.finalScore, false),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return new Scaffold(
      // Appbar
      appBar: new AppBar(
        // Title
        title: new Text(app.calculateUnits),
        backgroundColor: Resource.Colors.blue,
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
                app.calculateUnitsContent,
                style: TextStyle(color: Resource.Colors.blue, fontSize: 16.0),
              ),
            ),
            Expanded(
              flex: 19,
              child: RefreshIndicator(
                onRefresh: () => _calculate(),
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
                Text(app.calculating, style: _textBlueStyle())
              ],
            ),
            alignment: Alignment.center);
      case _State.error:
      case _State.empty:
        return FlatButton(
          onPressed: _calculate,
          child: HintContent(
            icon: Icons.assignment,
            content: state == _State.error ? app.clickToRetry : app.scoreEmpty,
          ),
        );
      case _State.ready:
        return FlatButton(
          onPressed: _calculate,
          child: HintContent(
            icon: Icons.apps,
            content: app.beginCalculate,
          ),
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
                          "${app.requiredUnits}：$requiredUnitsTotal", true),
                      _textBorder(
                          "${app.electiveUnits}：$electiveUnitsTotal", false),
                      _textBorder("${app.otherUnits}：$otherUnitsTotal", false),
                      _textBorder("${app.unitsTotal}：$unitsTotal", false),
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
    currentSemesterIndex = 0;
    semesterList = [];
    scoreDataList = [];
    coreGeneralEducations = [];
    extendGeneralEducations = [];
    _getSemesterScore();
  }

  _getSemester() async {
    Helper.instance.getSemester().then((semesterData) {
      this.semesterData = semesterData;
      selectSemester = semesterData.defaultSemester;
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

  _getSemesterScore() {
    Helper.cancelToken.cancel("");
    Helper.cancelToken = CancelToken();
    setState(() {
      state = _State.loading;
    });
    if (semesterData.semesters == null) {
      _getSemester();
      return;
    }
    var textList =
        semesterData.semesters[currentSemesterIndex].value.split(",");
    if (textList.length == 2) {
      Helper.instance.getScores(textList[0], textList[1]).then((response) {
        if (mounted)
          setState(() {
            if (response.status == 200) {
              if (startYear == -1) startYear = int.parse(textList[0]);
              //scoreWeightList.add(_scoreTitle());
              semesterList.add(semesterData.semesters[currentSemesterIndex]);
              scoreDataList.add(response);
              for (var score in response.content.scores) {
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
            var currentYear = int.parse(textList[0]);
            if (currentSemesterIndex < semesterData.semesters.length - 1 &&
                (startYear - currentYear).abs() <= 6) {
              currentSemesterIndex++;
              if (mounted) _getSemesterScore();
            } else {
              unitsTotal =
                  requiredUnitsTotal + electiveUnitsTotal + otherUnitsTotal;
              if (mounted) {
                setState(() {
                  state = _State.finish;
                });
              }
            }
          });
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
              setState(() {
                state = _State.error;
                Utils.handleDioError(e, app);
              });
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
}
