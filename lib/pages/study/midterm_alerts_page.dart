import 'package:ap_common/ap_common.dart' hide SemesterPicker;
import 'package:ap_common_flutter_ui/ap_common_flutter_ui.dart' as ap_ui;
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/semester_picker.dart';
import 'package:sprintf/sprintf.dart';

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

  @override
  void initState() {
    AnalyticsUtil.instance.setCurrentScreen(
      'MidtermAlertsPage',
      'midterm_alerts_page.dart',
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ap = ApLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(ap.midtermAlerts),
        backgroundColor: ApTheme.of(context).blue,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: () {
          if (semesterData != null) {
            ap_ui.SemesterPicker.show(
              context: context,
              semesterData: semesterData!,
              currentIndex: semesterData!.currentIndex,
              onSelect: (Semester semester, int index) {
                setState(() {
                  selectSemester = semester;
                  semesterData = semesterData?.copyWith(currentIndex: index);
                  state = _State.loading;
                });
                _getMidtermAlertsData();
              },
            );
          }
        },
      ),
      body: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const SizedBox(height: 8.0),
          SemesterPicker(
            selectSemester: selectSemester,
            currentIndex: semesterData?.currentIndex ?? 0,
            onDataLoaded: (SemesterData data) => semesterData = data,
            featureTag: 'midterm_alerts',
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
                ap_ui.SemesterPicker.show(
                  context: context,
                  semesterData: semesterData!,
                  currentIndex: semesterData!.currentIndex,
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
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
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
              sprintf(
                ap.midtermAlertsContent,
                <dynamic>[
                  item.reason ?? '',
                  item.remark ?? '',
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
    Helper.instance.getMidtermAlerts(
      semester: selectSemester!,
      callback: GeneralCallback<MidtermAlertsData>(
        onSuccess: (MidtermAlertsData data) {
          if (mounted) {
            setState(() {
              midtermAlertData = data;
              if (data.courses.isEmpty) {
                state = _State.empty;
              } else {
                state = _State.finish;
              }
            });
          }
        },
        onFailure: (DioException e) {
          setState(() {
            state = _State.custom;
            customStateHint = e.i18nMessage;
          });
          if (e.hasResponse) {
            AnalyticsUtil.instance.logApiEvent(
              'getMidtermAlert',
              e.response!.statusCode!,
              message: e.message ?? '',
            );
          }
        },
        onError: (GeneralResponse response) {
          setState(() {
            state = _State.custom;
            customStateHint = response.getGeneralMessage(context);
          });
        },
      ),
    );
  }
}
