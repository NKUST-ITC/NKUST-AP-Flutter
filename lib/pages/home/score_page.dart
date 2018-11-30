import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/utils.dart';

enum ScoreState { loading, finish, error, empty }

class ScorePageRoute extends MaterialPageRoute {
  ScorePageRoute() : super(builder: (BuildContext context) => new ScorePage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: new ScorePage());
  }
}

class ScorePage extends StatefulWidget {
  static const String routerName = "/score";

  @override
  ScorePageState createState() => new ScorePageState();
}

class ScorePageState extends State<ScorePage>
    with SingleTickerProviderStateMixin {
  List<Widget> scoreWeightList = [];

  var selectSemesterIndex;
  Semester selectSemester;

  SemesterData semesterData;
  ScoreData scoreData;

  ScoreState state = ScoreState.loading;

  AppLocalizations local;

  @override
  void initState() {
    super.initState();
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

  _scoreTitle() => Container(
        width: double.infinity,
        child: Row(
          children: <Widget>[
            Expanded(child: _scoreTextBorder(local.subject, false, true)),
            Expanded(child: _scoreTextBorder(local.midtermScore, false, true)),
            Expanded(child: _scoreTextBorder(local.finalScore, true, true)),
          ],
        ),
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

  Widget _scoreTextBorder(String text, bool isEnd, bool isTitle) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(vertical: 2.0),
      decoration: new BoxDecoration(
        border: new Border(
          right: isEnd
              ? BorderSide.none
              : BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text ?? "",
        textAlign: TextAlign.center,
        style: isTitle ? _textBlueStyle() : _textStyle(),
      ),
    );
  }

  Widget _scoreBorder(Score score) {
    return Container(
      width: double.infinity,
      decoration: new BoxDecoration(
        border: new Border(
          top: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: _scoreTextBorder(score.title, false, false)),
          Expanded(child: _scoreTextBorder(score.middleScore, false, false)),
          Expanded(child: _scoreTextBorder(score.finalScore, true, false)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    local = AppLocalizations.of(context);
    return new Scaffold(
      // Appbar
      appBar: new AppBar(
        // Title
        title: new Text(local.score),
        backgroundColor: Resource.Colors.blue,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: FlatButton(
                onPressed: _selectSemester,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      selectSemester == null ? "" : selectSemester.text,
                      style: _textBlueStyle(),
                    ),
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
                onRefresh: () => _getSemesterScore(),
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
      case ScoreState.loading:
        return Container(
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case ScoreState.error:
      case ScoreState.empty:
        return FlatButton(
          onPressed:
              state == ScoreState.error ? _getSemesterScore : _selectSemester,
          child: Center(
            child: Flex(
              mainAxisAlignment: MainAxisAlignment.center,
              direction: Axis.vertical,
              children: <Widget>[
                SizedBox(
                  child: Icon(
                    Icons.assignment,
                    size: 150.0,
                  ),
                  width: 200.0,
                ),
                Text(
                  state == ScoreState.error
                      ? local.clickToRetry
                      : local.scoreEmpty,
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        );
      default:
        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 8.0),
              Container(
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      10.0,
                    ),
                  ),
                  border: new Border.all(color: Colors.grey, width: 1.0),
                ),
                child: Flex(
                  direction: Axis.vertical,
                  children: scoreWeightList,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Container(
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      10.0,
                    ),
                  ),
                  border: new Border.all(color: Colors.grey, width: 1.0),
                ),
                child: Column(
                  children: <Widget>[
                    _textBorder(
                        "${local.conductScore}：${scoreData.content.detail.conduct}",
                        true),
                    _textBorder(
                        "${local.average}：${scoreData.content.detail.average}",
                        false),
                    _textBorder(
                        "${local.rank}：${scoreData.content.detail.classRank}",
                        false),
                    _textBorder(
                        "${local.percentage}：${scoreData.content.detail.classPercentage}",
                        false),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  void _selectSemester() {
    var semesters = <SimpleDialogOption>[];
    for (var semester in semesterData.semesters) {
      semesters.add(_dialogItem(semesters.length, semester.text));
    }
    showDialog<int>(
        context: context,
        builder: (BuildContext context) => SimpleDialog(
            title: Text(local.picksSemester),
            children: semesters)).then<void>((int position) {
      if (position != null) {
        selectSemesterIndex = position;
        selectSemester = semesterData.semesters[selectSemesterIndex];
        _getSemesterScore();
        setState(() {});
      }
    });
  }

  void _getSemester() {
    Helper.instance.getSemester().then((semesterData) {
      this.semesterData = semesterData;
      selectSemester = semesterData.defaultSemester;
      selectSemesterIndex = 0;
      _getSemesterScore();
      setState(() {});
    }).catchError((e) {
      assert(e is DioError);
      DioError dioError = e as DioError;
      switch (dioError.type) {
        case DioErrorType.RESPONSE:
          Utils.showToast(AppLocalizations.of(context).tokenExpiredContent);
          Navigator.popUntil(
              context, ModalRoute.withName(Navigator.defaultRouteName));
          break;
        case DioErrorType.CANCEL:
          break;
        default:
          state = ScoreState.error;
          Utils.handleDioError(dioError, local);
          break;
      }
    });
  }

  _getSemesterScore() async {
    Helper.cancelToken.cancel("");
    Helper.cancelToken = CancelToken();
    scoreWeightList.clear();
    state = ScoreState.loading;
    setState(() {});
    var textList = semesterData.semesters[selectSemesterIndex].value.split(",");
    if (textList.length == 2) {
      Helper.instance.getScores(textList[0], textList[1]).then((response) {
        setState(() {
          print(response.status);
          scoreData = response;
          if (scoreData.status == 204)
            state = ScoreState.empty;
          else {
            scoreWeightList.add(_scoreTitle());
            for (var score in scoreData.content.scores) {
              scoreWeightList.add(_scoreBorder(score));
            }
            state = ScoreState.finish;
          }
        });
      }).catchError((e) {
        assert(e is DioError);
        DioError dioError = e as DioError;
        switch (dioError.type) {
          case DioErrorType.RESPONSE:
            Utils.showToast(AppLocalizations.of(context).tokenExpiredContent);
            Navigator.popUntil(
                context, ModalRoute.withName(Navigator.defaultRouteName));
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            setState(() {
              state = ScoreState.error;
              Utils.handleDioError(dioError, local);
            });
            break;
        }
      });
    } else {
      state = ScoreState.error;
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
