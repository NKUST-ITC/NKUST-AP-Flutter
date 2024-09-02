import 'package:ap_common/models/score_data.dart';
import 'package:ap_common/models/semester_data.dart';
import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common/widgets/hint_content.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/global.dart';

enum _State {
  ready,
  loading,
  finish,
  error,
  empty,
  offline,
  custom,
}

class CalculateUnitsPage extends StatefulWidget {
  static const String routerName = '/calculateUnits';

  @override
  CalculateUnitsPageState createState() => CalculateUnitsPageState();
}

class CalculateUnitsPageState extends State<CalculateUnitsPage>
    with SingleTickerProviderStateMixin {
  late ApLocalizations ap;

  _State state = _State.ready;
  String? customStateHint = '';

  int currentSemesterIndex = 0;

  SemesterData? semesterData;
  List<Semester> semesterList = <Semester>[];

  double unitsTotal = 0.0;
  double requiredUnitsTotal = 0.0;
  double electiveUnitsTotal = 0.0;
  double otherUnitsTotal = 0.0;

  int startYear = 0;
  int count = 0;

  List<Score> coreGeneralEducations = <Score>[];
  List<Score> extendGeneralEducations = <Score>[];

  DateTime start = DateTime.now();

  @override
  void initState() {
    super.initState();
    FirebaseAnalyticsUtils.instance.setCurrentScreen(
      'CalculateUnitsPage',
      'calculate_units_page.dart',
    );
    _getSemester();
  }

  TextStyle _textBlueStyle() {
    return TextStyle(color: ApTheme.of(context).blueText, fontSize: 16.0);
  }

  TextStyle _textStyle() {
    return const TextStyle(fontSize: 14.0);
  }

  TableRow _scoreTitle() => TableRow(
        children: <Widget>[
          _scoreTextBorder(ap.generalEductionCourse, true),
          _scoreTextBorder(ap.semesterScore, true),
        ],
      );

  Widget _textBorder(String text, bool isTop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? BorderSide.none
              : const BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: _textBlueStyle(),
      ),
    );
  }

  Widget _scoreTextBorder(String? text, bool isTitle) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
      alignment: Alignment.center,
      child: Text(
        text ?? '',
        textAlign: TextAlign.center,
        style: isTitle ? _textBlueStyle() : _textStyle(),
      ),
    );
  }

  TableRow _generalEducationsBorder(Score score) {
    return TableRow(
      children: <Widget>[
        _scoreTextBorder(score.title, false),
        _scoreTextBorder(score.semesterScore, false),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ap = ApLocalizations.of(context);
    return Scaffold(
      // Appbar
      appBar: AppBar(
        // Title
        title: Text(ap.calculateCredits),
        backgroundColor: ApTheme.of(context).blue,
      ),
      body: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const SizedBox(height: 16.0),
          Expanded(
            child: Text(
              ap.calculateUnitsContent,
              style: TextStyle(
                color: ApTheme.of(context).blueText,
                fontSize: 16.0,
              ),
            ),
          ),
          Expanded(
            flex: 19,
            child: RefreshIndicator(
              onRefresh: () async {
                FirebaseAnalyticsUtils.instance.logEvent('refresh_swipe');
                _calculate();
                return;
              },
              child: _body(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    switch (state) {
      case _State.loading:
        return Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const CircularProgressIndicator(),
              const SizedBox(height: 16.0),
              Text(ap.calculating, style: _textBlueStyle()),
            ],
          ),
        );
      case _State.error:
      case _State.empty:
      case _State.custom:
        return InkWell(
          onTap: _calculate,
          child: HintContent(
            icon: ApIcon.assignment,
            content: state == _State.error ? ap.clickToRetry : customStateHint!,
          ),
        );
      case _State.ready:
        return InkWell(
          onTap: _calculate,
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
            padding: const EdgeInsets.all(16.0),
            height: (MediaQuery.of(context).size.height - 66.0) * (19 / 20),
            child: Column(
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(
                        10.0,
                      ),
                    ),
                    border: Border.all(color: Colors.grey, width: 1.5),
                  ),
                  child: Table(
                    columnWidths: const <int, TableColumnWidth>{
                      0: FlexColumnWidth(3.0),
                      1: FlexColumnWidth(),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border: const TableBorder.symmetric(
                      inside: BorderSide(color: Colors.grey),
                    ),
                    children: _renderScoreWidgets(),
                  ),
                ),
                const SizedBox(height: 20.0),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(
                        10.0,
                      ),
                    ),
                    border: Border.all(color: Colors.grey, width: 1.5),
                  ),
                  child: Column(
                    children: <Widget>[
                      _textBorder(
                        '${ap.requiredCredits}：$requiredUnitsTotal',
                        true,
                      ),
                      _textBorder(
                        '${ap.electiveCredits}：$electiveUnitsTotal',
                        false,
                      ),
                      _textBorder(
                        '${ap.otherCredits}：$otherUnitsTotal',
                        false,
                      ),
                      _textBorder(
                        '${ap.totalCredits}：$unitsTotal',
                        false,
                      ),
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
    final List<TableRow> scoreWeightList = <TableRow>[];
    scoreWeightList.add(_scoreTitle());
    /*for (var i = 0; i < scoreDataList.length; i++)
      scoreWeightList.add(_scoreBorder(semesterList[i], scoreDataList[i]));*/
    for (final Score i in coreGeneralEducations) {
      scoreWeightList.add(_generalEducationsBorder(i));
    }
    for (final Score i in extendGeneralEducations) {
      scoreWeightList.add(_generalEducationsBorder(i));
    }
    return scoreWeightList;
  }

  Future<void> _calculate() async {
    unitsTotal = 0.0;
    requiredUnitsTotal = 0.0;
    electiveUnitsTotal = 0.0;
    otherUnitsTotal = 0.0;

    startYear = -1;
    count = 0;
    currentSemesterIndex = 0;
    semesterList = <Semester>[];
    coreGeneralEducations = <Score>[];
    extendGeneralEducations = <Score>[];
    start = DateTime.now();
    _getSemesterScore();
  }

  DioExceptionCallback get _onFailure => (DioException e) {
        setState(() {
          state = _State.custom;
          customStateHint = e.i18nMessage;
        });
      };

  GeneralResponseCallback get _onError => (GeneralResponse response) {
        setState(() {
          state = _State.custom;
          customStateHint = response.getGeneralMessage(context);
        });
      };

  Future<void> _getSemester() async {
    if (Preferences.getBool(Constants.prefIsOfflineLogin, false)) {
      setState(() {
        state = _State.offline;
      });
      return;
    }
    Helper.instance.getSemester(
      callback: GeneralCallback<SemesterData>(
        onSuccess: (SemesterData? data) {
          semesterData = data;
        },
        onFailure: _onFailure,
        onError: _onError,
      ),
    );
  }

  void _getSemesterScore() {
    Helper.cancelToken!.cancel('');
    Helper.cancelToken = CancelToken();
    setState(() {
      state = _State.loading;
    });
    if (semesterData == null) {
      _getSemester();
      return;
    }
    Helper.instance.getScores(
      semester: semesterData!.data[currentSemesterIndex],
      callback: GeneralCallback<ScoreData?>(
        onSuccess: (ScoreData? data) {
          if (startYear == -1) {
            startYear =
                int.parse(semesterData!.data[currentSemesterIndex].year);
          }
          semesterList.add(semesterData!.data[currentSemesterIndex]);
          if (data?.scores != null) {
            for (final Score score in data!.scores) {
              if (score.semesterScore == null || score.semesterScore!.isEmpty) {
                continue;
              }
              final double? semesterScore =
                  double.tryParse(score.semesterScore!);
              if ((semesterScore != null && semesterScore >= 60.0) ||
                  score.semesterScore == '合格' ||
                  score.semesterScore == '通過') {
                if (score.required == '【必修】') {
                  requiredUnitsTotal += double.parse(score.units);
                } else if (score.required == '【選修】') {
                  electiveUnitsTotal += double.parse(score.units);
                } else {
                  otherUnitsTotal += double.parse(score.units);
                }
                if (score.title.contains('延伸通識') ||
                    score.title.contains('博雅')) {
                  extendGeneralEducations.add(score);
                } else if (score.title.contains('核心通識') ||
                    score.title.contains('核心')) {
                  coreGeneralEducations.add(score);
                }
              }
            }
          }
          final int currentYear =
              int.parse(semesterData!.data[currentSemesterIndex].year);
          if (currentSemesterIndex < semesterData!.data.length - 1 &&
              ((startYear - currentYear).abs() <= 6 || startYear == -1)) {
            currentSemesterIndex++;
            if (mounted) _getSemesterScore();
          } else {
            final DateTime end = DateTime.now();
            final double second =
                (end.millisecondsSinceEpoch - start.millisecondsSinceEpoch) /
                    1000;
            FirebaseAnalyticsUtils.instance.logCalculateUnits(second);
            unitsTotal =
                requiredUnitsTotal + electiveUnitsTotal + otherUnitsTotal;
            if (mounted) {
              setState(() {
                state = _State.finish;
              });
            }
          }
        },
        onFailure: _onFailure,
        onError: _onError,
      ),
    );
  }
}
