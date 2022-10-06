import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/global.dart';

class BusRulePage extends StatefulWidget {
  static const String routerName = '/bus/rule';

  const BusRulePage();

  @override
  BusRulePageState createState() => BusRulePageState();
}

class BusRulePageState extends State<BusRulePage> {
  AppLocalizations? app;

  @override
  void initState() {
    FirebaseAnalyticsUtils.instance
        .setCurrentScreen('BusRulePage', 'bus_rule_page.dart');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(app!.busRule),
        backgroundColor: ApTheme.of(context).blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: SelectableText.rich(
          TextSpan(
            style: TextStyle(
              color: ApTheme.of(context).grey,
              height: 1.3,
              fontSize: 16.0,
            ),
            children: <TextSpan>[
              TextSpan(
                text: app!.busRuleReservationRuleTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              TextSpan(
                text: app!.busRuleTravelBy,
              ),
              TextSpan(
                text: 'http://bus.kuas.edu.tw/',
                style: TextStyle(
                  color: ApTheme.of(context).blueAccent,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => ApUtils.launchUrl('http://bus.kuas.edu.tw/'),
              ),
              TextSpan(text: app!.busRuleFourteenDay),
              TextSpan(
                text: app!.busRuleReservationTime,
                style: TextStyle(color: ApTheme.of(context).red),
              ),
              TextSpan(
                text: app!.busRuleCancellingTitle,
              ),
              TextSpan(
                text: app!.busRuleCancelingTime,
                style: TextStyle(color: ApTheme.of(context).red),
              ),
              TextSpan(
                text: app!.busRuleFollow,
              ),
              TextSpan(
                text: app!.busRuleTakeOn,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              TextSpan(
                text: app!.busRuleTwentyDollars,
              ),
              TextSpan(
                text: app!.busRulePrepareCoins,
                style: TextStyle(color: ApTheme.of(context).blueText),
              ),
              TextSpan(
                text: app!.busRuleIdCard,
              ),
              TextSpan(
                text: app!.busRuleNoIdCard,
                style: TextStyle(
                  color: ApTheme.of(context).red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: app!.busRuleFollowingTime,
                style: TextStyle(color: ApTheme.of(context).red),
              ),
              TextSpan(
                text: app!.busRuleLateAndNoReservation,
              ),
              TextSpan(
                text: app!.busRuleStandbyTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              TextSpan(
                text: app!.busRuleStandbyRule,
              ),
              TextSpan(
                text: app!.busRuleFineTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              TextSpan(
                text: app!.busRuleFineRule,
                style: TextStyle(color: ApTheme.of(context).red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
