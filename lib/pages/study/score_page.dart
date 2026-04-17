import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/exceptions/api_exception.dart';
import 'package:nkust_ap/api/exceptions/api_exception_l10n.dart';
import 'package:nkust_ap/utils/global.dart';

class ScorePage extends StatefulWidget {
  static const String routerName = '/score';

  @override
  ScorePageState createState() => ScorePageState();
}

class ScorePageState extends State<ScorePage> {
  ScoreState state = ScoreState.loading;

  Semester? selectSemester;
  SemesterData? semesterData;
  ScoreData? scoreData;

  bool isOffline = false;

  String? customStateHint = '';

  final SemesterPickerController _pickerController = SemesterPickerController();

  @override
  void initState() {
    AnalyticsUtil.instance.setCurrentScreen('ScorePage', 'score_page.dart');
    _getSemester();
    super.initState();
  }

  @override
  void dispose() {
    _pickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScoreScaffold(
      state: state,
      scoreData: scoreData,
      customHint: isOffline ? context.ap.offlineScore : '',
      customStateHint: customStateHint,
      semesterData: semesterData,
      semesterPickerController: _pickerController,
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
      onRefresh: () async {
        await _getSemesterScore();
        AnalyticsUtil.instance.logEvent('refresh_swipe');
        return null;
      },
    );
  }

  Future<void> _getSemester() async {
    if (PreferenceUtil.instance.getBool(Constants.prefIsOfflineLogin, false)) {
      final SemesterData? cacheData = SemesterData.load();
      if (cacheData != null && mounted) {
        setState(() {
          semesterData = cacheData.copyWith(
            currentIndex: cacheData.defaultIndex,
          );
          selectSemester = semesterData!.defaultSemester;
        });
        _loadOfflineScoreData();
      }
      return;
    }
    try {
      final SemesterData data = await Helper.instance.getSemester();
      data.save();
      final String newSemester =
          '${Helper.username}_${data.defaultSemester.code}';
      PreferenceUtil.instance.setString(
        ApConstants.currentSemesterCode,
        newSemester,
      );
      if (mounted) {
        setState(() {
          semesterData = data.copyWith(currentIndex: data.defaultIndex);
          selectSemester = data.defaultSemester;
        });
        _getSemesterScore();
      }
    } on ApException catch (e) {
      if (mounted) {
        UiUtil.instance.showToast(context, e.toLocalizedMessage(context));
      }
    } on GeneralResponse catch (response) {
      if (mounted) {
        UiUtil.instance.showToast(context, response.getGeneralMessage(context));
      }
    } on DioException catch (e) {
      if (e.i18nMessage != null && mounted) {
        UiUtil.instance.showToast(context, e.i18nMessage!);
      }
      if (e.hasResponse) {
        AnalyticsUtil.instance.logApiEvent(
          'getSemester',
          e.response!.statusCode!,
          message: e.message ?? '',
        );
      }
    }
  }

  Future<void> _getSemesterScore() async {
    Helper.cancelToken?.cancel('');
    Helper.cancelToken = CancelToken();
    if (PreferenceUtil.instance.getBool(Constants.prefIsOfflineLogin, false)) {
      _loadOfflineScoreData();
    } else {
      try {
        final ScoreData? data = await Helper.instance.getScores(
          semester: selectSemester!,
        );
        if (mounted) {
          setState(() {
            isOffline = false;
            if (data == null) {
              state = ScoreState.empty;
              _pickerController.markSemesterEmpty(selectSemester!);
            } else {
              scoreData = data;
              state = ScoreState.finish;
              scoreData!.save(selectSemester!.cacheSaveTag);
              _pickerController.markSemesterHasData(selectSemester!);
            }
          });
        }
      } on ApException catch (e) {
        if (mounted) {
          _pickerController.markSemesterHasData(selectSemester!);
        }
        if (await _loadOfflineScoreData()) {
          setState(() {
            state = ScoreState.custom;
            customStateHint = e.toLocalizedMessage(context);
          });
        }
        rethrow;
      } on GeneralResponse catch (generalResponse) {
        if (mounted) {
          _pickerController.markSemesterHasData(selectSemester!);
        }
        if (await _loadOfflineScoreData()) {
          setState(() {
            state = ScoreState.custom;
            customStateHint = generalResponse.getGeneralMessage(context);
          });
        }
        rethrow;
      } on DioException catch (e) {
        if (mounted) {
          _pickerController.markSemesterHasData(selectSemester!);
        }
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
      } catch (e) {
        if (mounted) {
          _pickerController.markSemesterHasData(selectSemester!);
        }
        if (await _loadOfflineScoreData()) {
          if (mounted) {
            setState(() {
              state = ScoreState.custom;
              customStateHint = e.toString();
            });
          }
        } else if (mounted) {
          setState(() => state = ScoreState.error);
        }
        rethrow;
      }
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
