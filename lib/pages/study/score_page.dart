import 'package:ap_common/callback/general_callback.dart';
import 'package:ap_common/models/score_data.dart';
import 'package:ap_common/scaffold/score_scaffold.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/semester_picker.dart';

class ScorePage extends StatefulWidget {
  static const String routerName = '/score';

  @override
  ScorePageState createState() => ScorePageState();
}

class ScorePageState extends State<ScorePage> {
  final key = GlobalKey<SemesterPickerState>();

  late ApLocalizations ap;

  ScoreState state = ScoreState.loading;

  Semester? selectSemester;
  SemesterData? semesterData;
  ScoreData? scoreData;

  bool isOffline = false;

  String? customStateHint = '';

  @override
  void initState() {
    FirebaseAnalyticsUtils.instance
        .setCurrentScreen('ScorePage', 'score_page.dart');
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
      customStateHint: customStateHint,
      itemPicker: SemesterPicker(
        key: key,
        featureTag: 'score',
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
        FirebaseAnalyticsUtils.instance.logEvent('refresh_swipe');
        return null;
      },
      onSearchButtonClick: () {
        key.currentState!.pickSemester();
      },
      details: [
        '${ap.conductScore}：${scoreData?.detail.conduct ?? ''}',
        '${ap.average}：${scoreData?.detail.average ?? ''}',
        '${ap.classRank}：${scoreData?.detail.classRank ?? ''}',
        '${ap.departmentRank}：${scoreData?.detail.departmentRank ?? ''}',
      ],
    );
  }

  _getSemesterScore() async {
    Helper.cancelToken?.cancel('');
    Helper.cancelToken = CancelToken();
    if (Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false))
      _loadOfflineScoreData();
    else
      Helper.instance.getScores(
        semester: selectSemester,
        callback: GeneralCallback(onSuccess: (ScoreData? data) {
          if (mounted)
            setState(() {
              if (data == null) {
                state = ScoreState.empty;
              } else {
                scoreData = data;
                state = ScoreState.finish;
                scoreData!.save(selectSemester!.cacheSaveTag);
              }
            });
        }, onFailure: (DioError e) async {
          if (await _loadOfflineScoreData() && e.type != DioErrorType.cancel)
            setState(() {
              state = ScoreState.custom;
              customStateHint = e.i18nMessage;
            });
          if (e.hasResponse)
            FirebaseAnalyticsUtils.instance.logApiEvent(
                'getSemesterScore', e.response!.statusCode!,
                message: e.message);
        }, onError: (GeneralResponse generalResponse) async {
          if (await _loadOfflineScoreData())
            setState(() {
              state = ScoreState.custom;
              customStateHint = generalResponse.getGeneralMessage(context);
            });
        }),
      );
  }

  Future<bool> _loadOfflineScoreData() async {
    scoreData = ScoreData.load(selectSemester!.cacheSaveTag);
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
    return scoreData == null;
  }
}
