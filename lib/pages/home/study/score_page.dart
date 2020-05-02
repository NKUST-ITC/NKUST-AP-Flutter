import 'package:ap_common/models/score_data.dart';
import 'package:ap_common/scaffold/score_scaffold.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/semester_picker.dart';

class ScorePage extends StatefulWidget {
  static const String routerName = '/score';

  @override
  ScorePageState createState() => ScorePageState();
}

class ScorePageState extends State<ScorePage> {
  final key = GlobalKey<SemesterPickerState>();

  ApLocalizations ap;

  ScoreState state = ScoreState.loading;

  Semester selectSemester;
  SemesterData semesterData;
  ScoreData scoreData;

  bool isOffline = false;

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
    ap = ApLocalizations.of(context);
    return ScoreScaffold(
      state: state,
      scoreData: scoreData,
      customHint: isOffline ? ap.offlineScore : '',
      itemPicker: SemesterPicker(
        key: key,
        onSelect: (semester, index) {
          setState(() {
            selectSemester = semester;
            state = ScoreState.loading;
          });
          if (Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false))
            _loadOfflineScoreData();
          else
            _getSemesterScore();
        },
      ),
      onRefresh: () async {
        await _getSemesterScore();
        FA.logAction('refresh', 'swipe');
        return null;
      },
      onSearchButtonClick: () {
        key.currentState.pickSemester();
      },
      details: [
        '${ap.conductScore}：${scoreData?.detail?.conduct}',
        '${ap.average}：${scoreData?.detail?.average}',
        '${ap.rank}：${scoreData?.detail?.classRank}',
        '${ap.percentage}：${scoreData?.detail?.classPercentage}',
      ],
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
              state = ScoreState.empty;
            } else {
              scoreData = response;
              state = ScoreState.finish;
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
                  state = ScoreState.error;
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
          state = ScoreState.offlineEmpty;
        else {
          state = ScoreState.finish;
        }
      });
    }
  }
}
