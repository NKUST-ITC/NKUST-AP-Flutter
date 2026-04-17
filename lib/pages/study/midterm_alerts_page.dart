import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/exceptions/api_exception.dart';
import 'package:nkust_ap/api/exceptions/api_exception_l10n.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';
import 'package:nkust_ap/utils/global.dart';

enum _State {
  loading,
  finish,
  error,
  empty,
  offline,
  custom,
}

class MidtermAlertsPage extends StatefulWidget {
  static const String routerName = '/user/midtermAlerts';

  @override
  _MidtermAlertsPageState createState() => _MidtermAlertsPageState();
}

class _MidtermAlertsPageState extends State<MidtermAlertsPage> {
  late ApLocalizations ap;

  _State state = _State.loading;
  String? customStateHint;

  Semester? selectSemester;
  SemesterData? semesterData;
  late MidtermAlertsData midtermAlertData;

  bool isOffline = false;

  final SemesterPickerController _pickerController = SemesterPickerController();

  @override
  void initState() {
    AnalyticsUtil.instance.setCurrentScreen(
      'MidtermAlertsPage',
      'midterm_alerts_page.dart',
    );
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
    ap = context.ap;
    return Scaffold(
      appBar: AppBar(
        title: Text(ap.midtermAlerts),
      ),
      floatingActionButton: semesterData == null
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.search),
              onPressed: () {
                SemesterPicker.show(
                  context: context,
                  semesterData: semesterData!,
                  currentIndex: semesterData!.currentIndex,
                  controller: _pickerController,
                  onSelect: (Semester semester, int index) {
                    setState(() {
                      selectSemester = semester;
                      semesterData =
                          semesterData?.copyWith(currentIndex: index);
                      state = _State.loading;
                    });
                    _getMidtermAlertsData();
                  },
                );
              },
            ),
      body: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const SizedBox(height: 8.0),
          if (semesterData != null)
            SemesterPicker(
              semesterData: semesterData!,
              currentIndex: semesterData!.currentIndex,
              featureTag: 'midterm_alerts',
              controller: _pickerController,
              onSelect: (Semester semester, int index) {
                setState(() {
                  selectSemester = semester;
                  semesterData = semesterData?.copyWith(currentIndex: index);
                  state = _State.loading;
                });
                _getMidtermAlertsData();
              },
            ),
          if (isOffline)
            Text(
              ap.offlineScore,
              style: TextStyle(color: ApTheme.of(context).grey),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _getMidtermAlertsData();
                AnalyticsUtil.instance.logEvent('refresh_swipe');
                return;
              },
              child: _body(),
            ),
          ),
        ],
      ),
    );
  }

  String? get stateHint {
    switch (state) {
      case _State.error:
        return ap.somethingError;
      case _State.empty:
        return ap.midtermAlertsEmpty;
      case _State.offline:
        return ap.noOfflineData;
      case _State.custom:
        return customStateHint;
      default:
        return '';
    }
  }

  IconData get stateIcon {
    switch (state) {
      case _State.offline:
        return ApIcon.offlineBolt;
      case _State.error:
      case _State.empty:
      case _State.custom:
      default:
        return ApIcon.classIcon;
    }
  }

  Widget _body() {
    switch (state) {
      case _State.loading:
        return Container(
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        );
      case _State.empty:
      case _State.error:
      case _State.offline:
      case _State.custom:
        return InkWell(
          onTap: () {
            if (state == _State.empty) {
              if (semesterData != null) {
                SemesterPicker.show(
                  context: context,
                  semesterData: semesterData!,
                  currentIndex: semesterData!.currentIndex,
                  controller: _pickerController,
                  onSelect: (Semester semester, int index) {
                    setState(() {
                      selectSemester = semester;
                      semesterData =
                          semesterData?.copyWith(currentIndex: index);
                      state = _State.loading;
                    });
                    _getMidtermAlertsData();
                  },
                );
              }
            } else {
              _getMidtermAlertsData();
            }
            AnalyticsUtil.instance.logEvent('retry_click');
          },
          child: HintContent(
            icon: stateIcon,
            content: stateHint!,
          ),
        );
      case _State.finish:
        return ListView.builder(
          itemBuilder: (_, int index) {
            return _midtermAlertsItem(midtermAlertData.courses[index]);
          },
          itemCount: midtermAlertData.courses.length,
        );
    }
  }

  Widget _midtermAlertsItem(MidtermAlerts item) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(
            item.title,
            style: const TextStyle(fontSize: 18.0),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              ap.midtermAlertsContent(
                arg1: item.reason ?? '',
                arg2: item.remark ?? '',
              ),
            ),
          ),
        ),
      ),
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
      }
      return;
    }
    try {
      final SemesterData data = await Helper.instance.getSemester();
      data.save();
      if (mounted) {
        setState(() {
          semesterData = data.copyWith(currentIndex: data.defaultIndex);
          selectSemester = data.defaultSemester;
        });
        _getMidtermAlertsData();
      }
    } on ApException catch (e) {
      if (e is CancelledException) return;
      if (mounted) {
        UiUtil.instance.showToast(context, e.toLocalizedMessage(context));
      }
      if (e is ServerException && e.httpStatusCode != null) {
        AnalyticsUtil.instance.logApiEvent(
          'getSemester',
          e.httpStatusCode!,
          message: e.message,
        );
      }
    }
  }

  Future<void> _getMidtermAlertsData() async {
    if (PreferenceUtil.instance.getBool(Constants.prefIsOfflineLogin, false)) {
      setState(() {
        state = _State.offline;
      });
      return;
    }
    Helper.cancelToken!.cancel('');
    Helper.cancelToken = CancelToken();
    try {
      final MidtermAlertsData data = await Helper.instance.getMidtermAlerts(
        semester: selectSemester!,
      );
      if (mounted) {
        setState(() {
          midtermAlertData = data;
          if (data.courses.isEmpty) {
            state = _State.empty;
            _pickerController.markSemesterEmpty(selectSemester!);
          } else {
            state = _State.finish;
            _pickerController.markSemesterHasData(selectSemester!);
          }
        });
      }
    } on ApException catch (e) {
      if (e is CancelledException) return;
      if (mounted) {
        _pickerController.markSemesterHasData(selectSemester!);
      }
      setState(() {
        state = _State.custom;
        customStateHint = e.toLocalizedMessage(context);
      });
      if (e is ServerException && e.httpStatusCode != null) {
        AnalyticsUtil.instance.logApiEvent(
          'getMidtermAlert',
          e.httpStatusCode!,
          message: e.message,
        );
      }
    }
  }
}
