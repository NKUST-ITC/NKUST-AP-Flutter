import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/res/app_icon.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/utils/preferences.dart';
import 'package:nkust_ap/widgets/hint_content.dart';
import 'package:nkust_ap/widgets/semester_picker.dart';

enum _State { loading, finish, error, empty, offlineEmpty }

class ScorePage extends StatefulWidget {
  static const String routerName = '/score';

  @override
  ScorePageState createState() => ScorePageState();
}

class ScorePageState extends State<ScorePage> {
  final key = GlobalKey<SemesterPickerState>();

  AppLocalizations app;

  _State state = _State.loading;

  Semester selectSemester;
  SemesterData semesterData;
  ScoreData scoreData;

  bool isOffline = false;

  TextStyle get _textBlueStyle =>
      TextStyle(color: Resource.Colors.blueText, fontSize: 16.0);

  TextStyle get _textStyle => TextStyle(fontSize: 15.0);

  @override
  void initState() {
    FA.setCurrentScreen('ScorePage', 'score_page.dart');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(app.score),
        backgroundColor: Resource.Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          key.currentState.pickSemester();
        },
      ),
      body: Container(
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
                  if (Preferences.getBool(
                      Constants.PREF_IS_OFFLINE_LOGIN, false))
                    _loadOfflineScoreData();
                  else
                    _getSemesterScore();
                }),
            if (isOffline)
              Text(
                app.offlineScore,
                style: TextStyle(color: Resource.Colors.grey),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _getSemesterScore();
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
              key.currentState.pickSemester();
            FA.logAction('retry', 'click');
          },
          child: HintContent(
            icon: AppIcon.assignment,
            content: state == _State.error ? app.clickToRetry : app.scoreEmpty,
          ),
        );
      case _State.offlineEmpty:
        return HintContent(
          icon: AppIcon.classIcon,
          content: app.noOfflineData,
        );
      default:
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
                    children: [
                      TableRow(
                        children: <Widget>[
                          _scoreTextBorder(app.subject, true),
                          _scoreTextBorder(app.midtermScore, true),
                          _scoreTextBorder(app.finalScore, true),
                        ],
                      ),
                      for (var score in scoreData.scores)
                        _scoreTableRowTitle(score)
                    ],
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
                          '${app.conductScore}：${scoreData.detail.conduct}',
                          true),
                      _textBorder(
                          '${app.average}：${scoreData.detail.average}', false),
                      _textBorder(
                          '${app.rank}：${scoreData.detail.classRank}', false),
                      _textBorder(
                          '${app.percentage}：${scoreData.detail.classPercentage}',
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

  Widget _textBorder(String text, bool isTop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? BorderSide.none
              : BorderSide(color: Resource.Colors.grey, width: 0.5),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text ?? '',
        textAlign: TextAlign.center,
        style: _textBlueStyle,
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

  Widget _scoreTextBorder(String text, bool isTitle) {
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

  _getSemesterScore() async {
    Helper.cancelToken?.cancel('');
    Helper.cancelToken = CancelToken();
    if (Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false))
      _loadOfflineScoreData();
    else
      Helper.instance
          .getScores(selectSemester.year, selectSemester.value)
          .then((response) {
        if (mounted)
          setState(() {
            if (response == null) {
              state = _State.empty;
            } else {
              scoreData = response;
              state = _State.finish;
              CacheUtils.saveScoreData(selectSemester.code, scoreData);
            }
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
                  Utils.handleDioError(context, e);
                });
              }
              throw e;
              break;
          }
        } else {
          throw e;
        }
        _loadOfflineScoreData();
      });
  }

  _loadOfflineScoreData() async {
    scoreData = await CacheUtils.loadScoreData(selectSemester.code);
    if (mounted) {
      setState(() {
        isOffline = true;
        if (scoreData == null)
          state = _State.offlineEmpty;
        else {
          state = _State.finish;
        }
      });
    }
  }
}
