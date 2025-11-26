import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/score_widgets.dart';
import 'package:nkust_ap/widgets/semester_picker.dart';

class ScorePage extends StatefulWidget {
  static const String routerName = '/score';

  @override
  ScorePageState createState() => ScorePageState();
}

class ScorePageState extends State<ScorePage> {
  final GlobalKey<SemesterPickerState> key = GlobalKey<SemesterPickerState>();

  late ApLocalizations ap;

  CustomScoreState state = CustomScoreState.loading;
  Semester? selectSemester;
  SemesterData? semesterData;
  ScoreData? scoreData;
  bool isOffline = false;
  String? customStateHint = '';

  @override
  void initState() {
    AnalyticsUtil.instance.setCurrentScreen('ScorePage', 'score_page.dart');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ap = ApLocalizations.of(context);
    return CustomScoreScaffold(
      state: state,
      scoreData: scoreData,
      customHint: isOffline ? ap.offlineScore : null,
      customStateHint: customStateHint,
      itemPicker: SemesterPicker(
        key: key,
        featureTag: 'score',
        onSelect: (Semester semester, int index) {
          setState(() {
            selectSemester = semester;
            state = CustomScoreState.loading;
          });
          if (PreferenceUtil.instance.getBool(
            Constants.prefIsOfflineLogin,
            false,
          )) {
            _loadOfflineScoreData();
          } else {
            _getSemesterScore();
          }
        },
      ),
      onRefresh: () {
        _getSemesterScore();
        AnalyticsUtil.instance.logEvent('refresh_swipe');
      },
      onSearchButtonClick: () => key.currentState!.pickSemester(),
    );
  }

  Future<void> _getSemesterScore() async {
    Helper.cancelToken?.cancel('');
    Helper.cancelToken = CancelToken();
    if (PreferenceUtil.instance.getBool(Constants.prefIsOfflineLogin, false)) {
      _loadOfflineScoreData();
    } else {
      Helper.instance.getScores(
        semester: selectSemester!,
        callback: GeneralCallback<ScoreData?>(
          onSuccess: (ScoreData? data) {
            if (mounted) {
              setState(() {
                if (data == null) {
                  state = CustomScoreState.empty;
                  key.currentState?.markSemesterEmpty(selectSemester!);
                } else {
                  scoreData = data;
                  state = CustomScoreState.finish;
                  scoreData!.save(selectSemester!.cacheSaveTag);
                  key.currentState?.markSemesterHasData(selectSemester!);
                }
              });
            }
          },
          onFailure: (DioException e) async {
            if (await _loadOfflineScoreData() && e.type != DioExceptionType.cancel) {
              setState(() {
                state = CustomScoreState.custom;
                customStateHint = e.i18nMessage;
              });
            }
            if (e.hasResponse) {
              AnalyticsUtil.instance.logApiEvent(
                'getSemesterScore',
                e.response!.statusCode!,
                message: e.message ?? '',
              );
            }
          },
          onError: (GeneralResponse response) async {
            if (await _loadOfflineScoreData()) {
              setState(() {
                state = CustomScoreState.custom;
                customStateHint = response.getGeneralMessage(context);
              });
            }
          },
        ),
      );
    }
  }

  Future<bool> _loadOfflineScoreData() async {
    scoreData = ScoreData.load(selectSemester!.cacheSaveTag);
    if (mounted) {
      setState(() {
        isOffline = true;
        state = scoreData == null ? CustomScoreState.offlineEmpty : CustomScoreState.finish;
      });
    }
    return scoreData == null;
  }
}
