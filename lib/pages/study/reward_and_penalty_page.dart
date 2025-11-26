import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/reward_and_penalty_data.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/semester_picker.dart';
import 'package:sprintf/sprintf.dart';

enum _State { loading, finish, error, empty, offline, custom }

class RewardAndPenaltyPage extends StatefulWidget {
  static const String routerName = '/user/reward-and-penalty';

  @override
  RewardAndPenaltyPageState createState() => RewardAndPenaltyPageState();
}

class RewardAndPenaltyPageState extends State<RewardAndPenaltyPage> {
  final key = GlobalKey<SemesterPickerState>();

  late ApLocalizations ap;

  _State state = _State.loading;
  String? customStateHint;

  late Semester selectSemester;
  SemesterData? semesterData;
  late RewardAndPenaltyData rewardAndPenaltyData;

  bool isOffline = false;

  @override
  void initState() {
    AnalyticsUtil.instance.setCurrentScreen(
      'RewardAndPenaltyPage',
      'reward_and_penalty_page.dart',
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ap = ApLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(ap.rewardAndPenalty)),
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
            featureTag: 'reward',
            onSelect: (semester, index) {
              setState(() {
                selectSemester = semester;
                state = _State.loading;
              });
              _getRewardAndPenaltyData();
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
                await _getRewardAndPenaltyData();
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
              _getRewardAndPenaltyData();
            }
            AnalyticsUtil.instance.logEvent('retry_click');
          },
          child: HintContent(icon: ApIcon.classIcon, content: stateHint!),
        );
      case _State.finish:
        return ListView.builder(
          itemBuilder: (_, index) =>
              _rewardAndPenaltyItem(rewardAndPenaltyData.data[index]),
          itemCount: rewardAndPenaltyData.data.length,
        );
    }
  }

  Widget _rewardAndPenaltyItem(RewardAndPenalty item) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(item.reason, style: const TextStyle(fontSize: 18.0)),
          trailing: Text(
            item.type,
            style: TextStyle(
              fontSize: 16.0,
              color: item.isReward ? colorScheme.tertiary : colorScheme.error,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              sprintf(
                ap.rewardAndPenaltyContent,
                [item.counts, item.date],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getRewardAndPenaltyData() async {
    if (PreferenceUtil.instance.getBool(Constants.prefIsOfflineLogin, false)) {
      setState(() => state = _State.offline);
      return;
    }
    Helper.cancelToken!.cancel('');
    Helper.cancelToken = CancelToken();
    Helper.instance.getRewardAndPenalty(
      semester: selectSemester,
      callback: GeneralCallback<RewardAndPenaltyData>(
        onSuccess: (data) {
          if (mounted) {
            setState(() {
              rewardAndPenaltyData = data;
              state = data.data.isEmpty ? _State.empty : _State.finish;
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
              'getRewardAndPenalty',
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
