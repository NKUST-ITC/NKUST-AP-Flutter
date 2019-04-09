import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/hint_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _State { loading, finish, error, empty, offlineEmpty }

class ScorePageRoute extends MaterialPageRoute {
  ScorePageRoute() : super(builder: (BuildContext context) => ScorePage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FadeTransition(opacity: animation, child: ScorePage());
  }
}

class ScorePage extends StatefulWidget {
  static const String routerName = "/score";

  @override
  ScorePageState createState() => ScorePageState();
}

class ScorePageState extends State<ScorePage>
    with SingleTickerProviderStateMixin {
  AppLocalizations app;

  _State state = _State.loading;

  List<TableRow> scoreWeightList = [];

  int selectSemesterIndex;

  Semester selectSemester;
  SemesterData semesterData;
  ScoreData scoreData;

  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    FA.setCurrentScreen("ScorePage", "score_page.dart");
    _getSemester();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      // Appbar
      appBar: AppBar(
        // Title
        title: Text(app.score),
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
              child: FlatButton(
                onPressed: (semesterData != null) ? _selectSemester : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      selectSemester == null ? "" : selectSemester.text,
                      style: TextStyle(
                          color: Resource.Colors.blue, fontSize: 18.0),
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
            Container(
              child: isOffline
                  ? Text(
                      app.offlineScore,
                      style: TextStyle(color: Resource.Colors.grey),
                    )
                  : null,
            ),
            Expanded(
              flex: 19,
              child: RefreshIndicator(
                onRefresh: () async {
                  _getSemesterScore();
                  FA.logAction('refresh', 'swipe');
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
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case _State.error:
      case _State.empty:
        return FlatButton(
          onPressed: () {
            if (state == _State.error)
              _getSemesterScore();
            else
              _selectSemester();
            FA.logAction('retry', 'click');
          },
          child: HintContent(
            icon: Icons.assignment,
            content: state == _State.error ? app.clickToRetry : app.scoreEmpty,
          ),
        );
      case _State.offlineEmpty:
        return HintContent(
          icon: Icons.class_,
          content: app.noOfflineData,
        );
      default:
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
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
                    columnWidths: const <int, TableColumnWidth>{
                      0: FlexColumnWidth(2.5),
                      1: FlexColumnWidth(1.0),
                      2: FlexColumnWidth(1.0),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border: TableBorder.symmetric(
                      inside: BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                    children: scoreWeightList,
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10.0,
                      ),
                    ),
                    border: Border.all(color: Colors.grey, width: 1.5),
                  ),
                  child: Column(
                    children: <Widget>[
                      _textBorder(
                          "${app.conductScore}：${scoreData.content.detail.conduct}",
                          true),
                      _textBorder(
                          "${app.average}：${scoreData.content.detail.average}",
                          false),
                      _textBorder(
                          "${app.rank}：${scoreData.content.detail.classRank}",
                          false),
                      _textBorder(
                          "${app.percentage}：${scoreData.content.detail.classPercentage}",
                          false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  _textBlueStyle() {
    return TextStyle(color: Resource.Colors.blue, fontSize: 16.0);
  }

  _textStyle() {
    return TextStyle(color: Colors.black, fontSize: 14.0);
  }

  _scoreTitle() => TableRow(
        children: <Widget>[
          _scoreTextBorder(app.subject, true),
          _scoreTextBorder(app.midtermScore, true),
          _scoreTextBorder(app.finalScore, true),
        ],
      );

  Widget _textBorder(String text, bool isTop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        border: Border(
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

  TableRow _scoreTableRowTitle(Score score) {
    return TableRow(children: <Widget>[
      _scoreTextBorder(score.title, false),
      _scoreTextBorder(score.middleScore, false),
      _scoreTextBorder(score.finalScore, false)
    ]);
  }

  void _selectSemester() {
    if (semesterData.semesters == null) return;
    var semesters = <SimpleDialogOption>[];
    for (var semester in semesterData.semesters) {
      semesters.add(_dialogItem(semesters.length, semester.text));
    }
    FA.logAction('pick_yms', 'click');
    showDialog<int>(
        context: context,
        builder: (BuildContext context) => SimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            title: Text(app.picksSemester),
            children: semesters)).then<void>((int position) {
      if (position != null) {
        if (mounted) {
          setState(() {
            selectSemesterIndex = position;
            selectSemester = semesterData.semesters[selectSemesterIndex];
          });
          _getSemesterScore();
        }
      }
    });
  }

  void _getSemester() async {
    this.semesterData = await CacheUtils.loadSemesterData();
    if (this.semesterData == null) return;
    setState(() {
      selectSemester = semesterData.defaultSemester;
      selectSemesterIndex = semesterData.defaultIndex;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(Constants.PREF_IS_OFFLINE_LOGIN)) {
      _getSemesterScore();
      return;
    }
    Helper.instance.getSemester().then((semesterData) {
      setState(() {
        this.semesterData = semesterData;
        selectSemester = semesterData.defaultSemester;
        selectSemesterIndex = semesterData.defaultIndex;
      });
      _getSemesterScore();
      CacheUtils.saveSemesterData(semesterData);
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
            Utils.handleDioError(e, app);
            break;
        }
      } else {
        throw e;
      }
    });
  }

  _renderScoreDataWidget() {
    scoreWeightList.clear();
    scoreWeightList.add(_scoreTitle());
    for (var score in scoreData.content.scores) {
      scoreWeightList.add(_scoreTableRowTitle(score));
    }
  }

  _getSemesterScore() async {
    Helper.cancelToken.cancel("");
    Helper.cancelToken = CancelToken();
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(Constants.PREF_IS_OFFLINE_LOGIN))
        _loadOfflineData();
      else
        Helper.instance.getScores(textList[0], textList[1]).then((response) {
          if (mounted)
            setState(() {
              scoreData = response;
              if (scoreData.status == 204)
                state = _State.empty;
              else {
                _renderScoreDataWidget();
                state = _State.finish;
              }
              CacheUtils.saveScoreData(
                  semesterData.semesters[selectSemesterIndex].value, scoreData);
            });
        }).catchError((e) {
          if (e is DioError) {
            switch (e.type) {
              case DioErrorType.RESPONSE:
                Utils.handleResponseError(
                    context, 'getSemesterScore', mounted, e);
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
          _loadOfflineData();
        });
    } else {
      setState(() {
        state = _State.error;
      });
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

  _loadOfflineData() async {
    scoreData = await CacheUtils.loadScoreData(
        semesterData.semesters[selectSemesterIndex].value);
    setState(() {
      isOffline = true;
      if (scoreData == null)
        state = _State.offlineEmpty;
      else if (scoreData.status == 204)
        state = _State.empty;
      else {
        _renderScoreDataWidget();
        state = _State.finish;
      }
    });
  }
}
