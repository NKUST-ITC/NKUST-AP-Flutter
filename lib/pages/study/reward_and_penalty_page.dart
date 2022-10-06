import 'package:ap_common/models/semester_data.dart';
import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common/widgets/hint_content.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/reward_and_penalty_data.dart';
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

class RewardAndPenaltyPage extends StatefulWidget {
  static const String routerName = '/user/reward-and-penalty';

  @override
  _RewardAndPenaltyPageState createState() => _RewardAndPenaltyPageState();
}

class _RewardAndPenaltyPageState extends State<RewardAndPenaltyPage> {
  final GlobalKey<SemesterPickerState> key = GlobalKey<SemesterPickerState>();

  late ApLocalizations ap;

  _State state = _State.loading;
  String? customStateHint;

  late Semester selectSemester;
  SemesterData? semesterData;
  late RewardAndPenaltyData rewardAndPenaltyData;

  bool isOffline = false;

  @override
  void initState() {
    FirebaseAnalyticsUtils.instance.setCurrentScreen(
      'RewardAndPenaltyPage',
      'reward_and_penalty_page.dart',
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
        title: Text(ap.rewardAndPenalty),
        backgroundColor: ApTheme.of(context).blue,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: () {
          key.currentState!.pickSemester();
        },
      ),
      body: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const SizedBox(height: 8.0),
          SemesterPicker(
            key: key,
            featureTag: 'reward',
            onSelect: (Semester semester, int index) {
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
              style: TextStyle(color: ApTheme.of(context).grey),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _getMidtermAlertsData();
                FirebaseAnalyticsUtils.instance.logEvent('refresh_swipe');
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
        return ap.rewardAndPenaltyEmpty;
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
              key.currentState!.pickSemester();
            } else {
              _getMidtermAlertsData();
            }
            FirebaseAnalyticsUtils.instance.logEvent('retry_click');
          },
          child: HintContent(
            icon: ApIcon.classIcon,
            content: stateHint!,
          ),
        );
      case _State.finish:
        return ListView.builder(
          itemBuilder: (_, int index) {
            return _midtermAlertsItem(rewardAndPenaltyData.data[index]);
          },
          itemCount: rewardAndPenaltyData.data.length,
        );
    }
  }

  Widget _midtermAlertsItem(RewardAndPenalty item) {
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
            item.reason,
            style: const TextStyle(fontSize: 18.0),
          ),
          trailing: Text(
            item.type,
            style: TextStyle(
              fontSize: 16.0,
              color: item.isReward ? Colors.green : Colors.red,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              sprintf(
                ap.rewardAndPenaltyContent,
                <dynamic>[
                  item.counts,
                  item.date,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getMidtermAlertsData() async {
    if (Preferences.getBool(Constants.prefIsOfflineLogin, false)) {
      setState(() {
        state = _State.offline;
      });
      return;
    }
    Helper.cancelToken!.cancel('');
    Helper.cancelToken = CancelToken();
    Helper.instance.getRewardAndPenalty(
      semester: selectSemester,
      callback: GeneralCallback<RewardAndPenaltyData>(
        onSuccess: (RewardAndPenaltyData data) {
          if (mounted) {
            setState(() {
              rewardAndPenaltyData = data;
              if (data.data.isEmpty) {
                state = _State.empty;
              } else {
                state = _State.finish;
              }
            });
          }
        },
        onFailure: (DioError e) {
          setState(() {
            state = _State.custom;
            customStateHint = e.i18nMessage;
          });
          if (e.hasResponse) {
            FirebaseAnalyticsUtils.instance.logApiEvent(
              'getRewardAndPenalty',
              e.response!.statusCode!,
              message: e.message,
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
