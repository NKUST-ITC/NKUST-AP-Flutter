import 'package:ap_common/callback/general_callback.dart';
import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common/widgets/hint_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';
import 'package:nkust_ap/models/semester_data.dart';
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
  static const String routerName = "/user/midtermAlerts";

  @override
  _MidtermAlertsPageState createState() => _MidtermAlertsPageState();
}

class _MidtermAlertsPageState extends State<MidtermAlertsPage> {
  final key = GlobalKey<SemesterPickerState>();

  ApLocalizations ap;

  _State state = _State.loading;
  String customStateHint;

  Semester selectSemester;
  SemesterData semesterData;
  MidtermAlertsData midtermAlertData;

  bool isOffline = false;

  @override
  void initState() {
    FirebaseAnalyticsUtils.instance.setCurrentScreen(
      "MidtermAlertsPage",
      "midterm_alerts_page.dart",
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
        child: Icon(Icons.search),
        onPressed: () {
          key.currentState.pickSemester();
        },
      ),
      body: Container(
        child: Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(height: 8.0),
            SemesterPicker(
                key: key,
                featureTag: 'midterm_alerts',
                onSelect: (semester, index) {
                  setState(() {
                    selectSemester = semester;
                    state = _State.loading;
                  });
                  _getMidtermAlertsData();
                }),
            if (isOffline)
              Text(
                ap.offlineScore,
                style: TextStyle(color: ApTheme.of(context).grey),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _getMidtermAlertsData();
                  FirebaseAnalyticsUtils.instance.logEvent('refresh_swipe');
                  return null;
                },
                child: _body(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get stateHint {
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

  _body() {
    switch (state) {
      case _State.loading:
        return Container(
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case _State.empty:
      case _State.error:
      case _State.empty:
      case _State.offline:
      case _State.custom:
        return InkWell(
                onTap: () {
            if (state == _State.empty)
              key.currentState.pickSemester();
            else
              _getMidtermAlertsData();
            FirebaseAnalyticsUtils.instance.logEvent('retry_click');
          },
          child: HintContent(
            icon: stateIcon,
            content: stateHint,
          ),
        );
      case _State.finish:
        return ListView.builder(
          itemBuilder: (_, index) {
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
            style: TextStyle(fontSize: 18.0),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              sprintf(
                ap.midtermAlertsContent,
                [
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

  _getMidtermAlertsData() async {
    if (Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false)) {
      setState(() {
        state = _State.offline;
      });
      return;
    }
    Helper.cancelToken.cancel('');
    Helper.cancelToken = CancelToken();
    Helper.instance.getMidtermAlerts(
      semester: selectSemester,
      callback: GeneralCallback(
        onSuccess: (MidtermAlertsData data) {
          if (mounted)
            setState(() {
              midtermAlertData = data;
              if (data == null || data.courses.length == 0)
                state = _State.empty;
              else
                state = _State.finish;
            });
        },
        onFailure: (DioError e) {
          setState(() {
            state = _State.custom;
            customStateHint = e.i18nMessage;
          });
          if (e.hasResponse)
            FirebaseAnalyticsUtils.instance.logApiEvent(
                'getMidtermAlert', e.response.statusCode,
                message: e.message);
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
