import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/semester_picker.dart';
import 'package:sprintf/sprintf.dart';

enum _State { loading, finish, error, empty, offline, custom }

class MidtermAlertsPage extends StatefulWidget {
  static const String routerName = '/user/midtermAlerts';

  @override
  MidtermAlertsPageState createState() => MidtermAlertsPageState();
}

class MidtermAlertsPageState extends State<MidtermAlertsPage> {
  final key = GlobalKey<SemesterPickerState>();

  late ApLocalizations ap;

  _State state = _State.loading;
  String? customStateHint;

  late Semester selectSemester;
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
  Widget build(BuildContext context) {
    ap = ApLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(ap.midtermAlerts)),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: () => key.currentState!.pickSemester(),
      ),
      body: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(height: 8.0),
          SemesterPicker(
            key: key,
            featureTag: 'midterm_alerts',
            onSelect: (semester, index) {
              setState(() {
                selectSemester = semester;
                state = _State.loading;
              });
              _getMidtermAlertsData();
            },
          ),
          if (isOffline)
            Text(
              ap.offlineScore,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _getMidtermAlertsData();
                AnalyticsUtil.instance.logEvent('refresh_swipe');
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
              key.currentState!.pickSemester();
            } else {
              _getMidtermAlertsData();
            }
            AnalyticsUtil.instance.logEvent('retry_click');
          },
          child: HintContent(icon: stateIcon, content: stateHint!),
        );
      case _State.finish:
        return ListView.builder(
          itemBuilder: (_, index) => _midtermAlertsItem(midtermAlertData.courses[index]),
          itemCount: midtermAlertData.courses.length,
        );
    }
  }

  Widget _midtermAlertsItem(MidtermAlerts item) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(item.title, style: const TextStyle(fontSize: 18.0)),
          subtitle: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              sprintf(
                ap.midtermAlertsContent,
                [item.reason ?? '', item.remark ?? ''],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getMidtermAlertsData() async {
    if (PreferenceUtil.instance.getBool(Constants.prefIsOfflineLogin, false)) {
      setState(() => state = _State.offline);
      return;
    }
    Helper.cancelToken!.cancel('');
    Helper.cancelToken = CancelToken();
    Helper.instance.getMidtermAlerts(
      semester: selectSemester,
      callback: GeneralCallback<MidtermAlertsData>(
        onSuccess: (data) {
          if (mounted) {
            setState(() {
              midtermAlertData = data;
              state = data.courses.isEmpty ? _State.empty : _State.finish;
            });
          }
        },
        onFailure: (e) {
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
        onError: (response) {
          setState(() {
            state = _State.custom;
            customStateHint = response.getGeneralMessage(context);
          });
        },
      ),
    );
  }
}
