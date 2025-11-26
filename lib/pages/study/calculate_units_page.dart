import 'package:ap_common/ap_common.dart';
import 'package:ap_common_firebase/ap_common_firebase.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/global.dart';

enum _State { ready, loading, finish, error, empty, offline, custom }

class CalculateUnitsPage extends StatefulWidget {
  static const String routerName = '/calculateUnits';

  @override
  CalculateUnitsPageState createState() => CalculateUnitsPageState();
}

class CalculateUnitsPageState extends State<CalculateUnitsPage> with SingleTickerProviderStateMixin {
  late ApLocalizations ap;

  _State state = _State.ready;
  String? customStateHint = '';

  int currentSemesterIndex = 0;
  SemesterData? semesterData;
  List<Semester> semesterList = [];

  double unitsTotal = 0.0;
  double requiredUnitsTotal = 0.0;
  double electiveUnitsTotal = 0.0;
  double otherUnitsTotal = 0.0;

  int startYear = 0;
  int count = 0;

  List<Score> coreGeneralEducations = [];
  List<Score> extendGeneralEducations = [];

  DateTime start = DateTime.now();

  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'CalculateUnitsPage',
      'calculate_units_page.dart',
    );
    _getSemester();
  }

  @override
  Widget build(BuildContext context) {
    ap = ApLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(ap.calculateCredits)),
      body: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(height: 16.0),
          Expanded(
            child: Text(
              ap.calculateUnitsContent,
              style: TextStyle(color: colorScheme.primary, fontSize: 16.0),
            ),
          ),
          Expanded(
            flex: 19,
            child: RefreshIndicator(
              onRefresh: () async {
                AnalyticsUtil.instance.logEvent('refresh_swipe');
                _calculate();
              },
              child: _body(),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _textBlueStyle() {
    return TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontSize: 16.0,
    );
  }

  TextStyle _textStyle() => const TextStyle(fontSize: 14.0);

  TableRow _scoreTitle() => TableRow(
        children: [
          _scoreTextBorder(ap.generalEductionCourse, true),
          _scoreTextBorder(ap.semesterScore, true),
        ],
      );

  Widget _textBorder(String text, bool isTop) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? BorderSide.none : BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Text(text, textAlign: TextAlign.center, style: _textBlueStyle()),
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
      children: [
        _scoreTextBorder(score.title, false),
        _scoreTextBorder(score.semesterScore, false),
      ],
    );
  }

  Widget _body() {
    final colorScheme = Theme.of(context).colorScheme;
    switch (state) {
      case _State.loading:
        return Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
          child: HintContent(icon: ApIcon.apps, content: ap.beginCalculate),
        );
      case _State.offline:
        return HintContent(icon: ApIcon.offlineBolt, content: ap.offlineMode);
      default:
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            height: (MediaQuery.of(context).size.height - 66.0) * (19 / 20),
            child: Column(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 1.5,
                    ),
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(3.0),
                      1: FlexColumnWidth(),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border: TableBorder.symmetric(
                      inside: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    children: _renderScoreWidgets(),
                  ),
                ),
                const SizedBox(height: 20.0),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      _textBorder('${ap.requiredCredits}：$requiredUnitsTotal', true),
                      _textBorder('${ap.electiveCredits}：$electiveUnitsTotal', false),
                      _textBorder('${ap.otherCredits}：$otherUnitsTotal', false),
                      _textBorder('${ap.totalCredits}：$unitsTotal', false),
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
    final scoreWeightList = <TableRow>[_scoreTitle()];
    for (final i in coreGeneralEducations) {
      scoreWeightList.add(_generalEducationsBorder(i));
    }
    for (final i in extendGeneralEducations) {
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
    semesterList = [];
    coreGeneralEducations = [];
    extendGeneralEducations = [];
    start = DateTime.now();
    _getSemesterScore();
  }

  DioExceptionCallback get _onFailure => (e) {
        setState(() {
          state = _State.custom;
          customStateHint = e.i18nMessage;
        });
      };

  GeneralResponseCallback get _onError => (response) {
        setState(() {
          state = _State.custom;
          customStateHint = response.getGeneralMessage(context);
        });
      };

  Future<void> _getSemester() async {
    if (PreferenceUtil.instance.getBool(Constants.prefIsOfflineLogin, false)) {
      setState(() => state = _State.offline);
      return;
    }
    Helper.instance.getSemester(
      callback: GeneralCallback<SemesterData>(
        onSuccess: (data) => semesterData = data,
        onFailure: _onFailure,
        onError: _onError,
      ),
    );
  }

  void _getSemesterScore() {
    Helper.cancelToken!.cancel('');
    Helper.cancelToken = CancelToken();
    setState(() => state = _State.loading);
    if (semesterData == null) {
      _getSemester();
      return;
    }
    Helper.instance.getScores(
      semester: semesterData!.data[currentSemesterIndex],
      callback: GeneralCallback<ScoreData?>(
        onSuccess: (data) {
          if (startYear == -1) {
            startYear = int.parse(
              semesterData!.data[currentSemesterIndex].year,
            );
          }
          semesterList.add(semesterData!.data[currentSemesterIndex]);
          if (data?.scores != null) {
            for (final score in data!.scores) {
              if (score.semesterScore == null || score.semesterScore!.isEmpty) {
                continue;
              }
              final semesterScore = double.tryParse(score.semesterScore!);
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
                if (score.title.contains('延伸通識') || score.title.contains('博雅')) {
                  extendGeneralEducations.add(score);
                } else if (score.title.contains('核心通識') || score.title.contains('核心')) {
                  coreGeneralEducations.add(score);
                }
              }
            }
          }
          final currentYear = int.parse(
            semesterData!.data[currentSemesterIndex].year,
          );
          if (currentSemesterIndex < semesterData!.data.length - 1 &&
              ((startYear - currentYear).abs() <= 6 || startYear == -1)) {
            currentSemesterIndex++;
            if (mounted) _getSemesterScore();
          } else {
            final end = DateTime.now();
            final second = (end.millisecondsSinceEpoch - start.millisecondsSinceEpoch) / 1000;
            (AnalyticsUtil.instance as FirebaseAnalyticsUtils).logCalculateUnits(second);
            unitsTotal = requiredUnitsTotal + electiveUnitsTotal + otherUnitsTotal;
            if (mounted) setState(() => state = _State.finish);
          }
        },
        onFailure: _onFailure,
        onError: _onError,
      ),
    );
  }
}
