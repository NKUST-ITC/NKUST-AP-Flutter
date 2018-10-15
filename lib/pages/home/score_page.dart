import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';

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

  @override
  void initState() {
    super.initState();
    _getSemester();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _textStyle() {
    return TextStyle(color: Colors.blue, fontSize: 12.0);
  }

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
        style: _textStyle(),
      ),
    );
  }

  Widget _scoreTextBorder(String text, bool isEnd) {
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
        style: _textStyle(),
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
          Expanded(child: _scoreTextBorder(score.title, false)),
          Expanded(child: _scoreTextBorder(score.middleScore, false)),
          Expanded(child: _scoreTextBorder(score.finalScore, true)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // Appbar
      appBar: new AppBar(
        // Title
        title: new Text(Resource.Strings.score),
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
                child: Text(
                  selectSemester == null ? "" : selectSemester.text,
                  style: _textStyle(),
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
            onPressed: () {},
            child: Center(
              child: Flex(
                mainAxisAlignment: MainAxisAlignment.center,
                direction: Axis.vertical,
                children: <Widget>[
                  SizedBox(
                    child: Icon(
                      Icons.directions_bus,
                      size: 150.0,
                    ),
                    width: 200.0,
                  ),
                  Text(
                    state == ScoreState.error
                        ? "發生錯誤，點擊重試"
                        : "Oops！本學期沒有任何成績資料哦～\n請選擇其他學期\uD83D\uDE0B",
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ));
      default:
        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
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
                  children: scoreWeightList,
                ),
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
                        "操行成績：${scoreData.content.detail.conduct}", true),
                    _textBorder(
                        "總平均：${scoreData.content.detail.average}", false),
                    _textBorder(
                        "班名次/班人數：${scoreData.content.detail.classRank}", false),
                    _textBorder(
                        "班名次百分比：${scoreData.content.detail.classPercentage}",
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
            builder: (BuildContext context) =>
                SimpleDialog(title: const Text('請選擇學期'), children: semesters))
        .then<void>((int position) {
      if (position != null) {
        selectSemesterIndex = position;
        selectSemester = semesterData.semesters[selectSemesterIndex];
        _getSemesterScore();
        setState(() {});
      }
    });
  }

  void _getSemester() {
    Helper.instance.getSemester().then((response) {
      if (response.data == null) {
      } else {
        semesterData = SemesterData.fromJson(response.data);
        selectSemester = semesterData.defaultSemester;
        selectSemesterIndex = 0;
        _getSemesterScore();
        setState(() {});
      }
    });
  }

  _getSemesterScore() async {
    scoreWeightList.clear();
    state = ScoreState.loading;
    setState(() {});
    var textList = semesterData.semesters[selectSemesterIndex].value.split(",");
    if (textList.length == 2) {
      Helper.instance.getScore(textList[0], textList[1]).then((response) {
        if (response.data["status"] == 200) {
          scoreData = ScoreData.fromJson(response.data);
          print(response.data);
          print(scoreData.content.detail.classRank);
          for (var score in scoreData.content.scores) {
            scoreWeightList.add(_scoreBorder(score));
          }
          state = ScoreState.finish;
          setState(() {});
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
