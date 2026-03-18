import 'package:ap_common/ap_common.dart' hide SemesterPicker;
import 'package:ap_common_flutter_ui/ap_common_flutter_ui.dart' as ap_ui;
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/semester_picker.dart';

class ScorePage extends StatefulWidget {
  static const String routerName = '/score';

  @override
  ScorePageState createState() => ScorePageState();
}

class ScorePageState extends State<ScorePage> {
  late ApLocalizations ap;

  ScoreState state = ScoreState.loading;

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
      semesterData: semesterData,
      onSelect: (int index) {
        setState(() {
          selectSemester = semesterData!.data[index];
          semesterData = semesterData?.copyWith(currentIndex: index);
          state = ScoreState.loading;
        });
        if (PreferenceUtil.instance
            .getBool(Constants.prefIsOfflineLogin, false)) {
          _loadOfflineScoreData();
        } else {
          _getSemesterScore();
        }
      },
      itemPicker: SemesterPicker(
        featureTag: 'score',
        selectSemester: selectSemester,
        currentIndex: semesterData?.currentIndex ?? 0,
        onDataLoaded: (SemesterData data) => semesterData = data,
        onSelect: (Semester semester, int index) {
          setState(() {
            selectSemester = semester;
            semesterData = semesterData?.copyWith(currentIndex: index);
            state = ScoreState.loading;
          });
          if (PreferenceUtil.instance
              .getBool(Constants.prefIsOfflineLogin, false)) {
            _loadOfflineScoreData();
          } else {
            _getSemesterScore();
          }
        },
      ),
      onRefresh: () async {
        //TODO implement block callback function
        await _getSemesterScore();
        AnalyticsUtil.instance.logEvent('refresh_swipe');
        return null;
      },
      onSearchButtonClick: () {
        if (semesterData != null) {
          ap_ui.SemesterPicker.show(
            context: context,
            semesterData: semesterData!,
            currentIndex: semesterData!.currentIndex,
            onSelect: (Semester semester, int index) {
              setState(() {
                selectSemester = semester;
                semesterData = semesterData?.copyWith(currentIndex: index);
                state = ScoreState.loading;
              });
              if (PreferenceUtil.instance
                  .getBool(Constants.prefIsOfflineLogin, false)) {
                _loadOfflineScoreData();
              } else {
                _getSemesterScore();
              }
            },
          );
        }
      },
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
                  state = ScoreState.empty;
                } else {
                  scoreData = data;
                  state = ScoreState.finish;
                  scoreData!.save(selectSemester!.cacheSaveTag);
                }
              });
            }
          },
          onFailure: (DioException e) async {
            if (await _loadOfflineScoreData() &&
                e.type != DioExceptionType.cancel) {
              setState(() {
                state = ScoreState.custom;
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
          onError: (GeneralResponse generalResponse) async {
            if (await _loadOfflineScoreData()) {
              setState(() {
                state = ScoreState.custom;
                customStateHint = generalResponse.getGeneralMessage(context);
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
        if (scoreData == null) {
          state = ScoreState.offlineEmpty;
        } else {
          state = ScoreState.finish;
        }
      });
    }
    return scoreData == null;
  }
}
