import 'package:ap_common/ap_common.dart';
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
  @override
  void initState() {
    AnalyticsUtil.instance
        .setCurrentScreen('BusRulePage', 'bus_rule_page.dart');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.busRule),
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
                text: context.t.busRuleReservationRuleTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              TextSpan(
                text: context.t.busRuleTravelBy,
              ),
              TextSpan(
                text: 'http://bus.kuas.edu.tw/',
                style: TextStyle(
                  color: ApTheme.of(context).blueAccent,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => PlatformUtil.instance
                      .launchUrl('http://bus.kuas.edu.tw/'),
              ),
              TextSpan(text: context.t.busRuleFourteenDay),
              TextSpan(
                text: context.t.busRuleReservationTime,
                style: TextStyle(color: ApTheme.of(context).red),
              ),
              TextSpan(
                text: context.t.busRuleCancellingTitle,
              ),
              TextSpan(
                text: context.t.busRuleCancelingTime,
                style: TextStyle(color: ApTheme.of(context).red),
              ),
              TextSpan(
                text: context.t.busRuleFollow,
              ),
              TextSpan(
                text: context.t.busRuleTakeOn,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              TextSpan(
                text: context.t.busRuleTwentyDollars,
              ),
              TextSpan(
                text: context.t.busRulePrepareCoins,
                style: TextStyle(color: ApTheme.of(context).blueText),
              ),
              TextSpan(
                text: context.t.busRuleIdCard,
              ),
              TextSpan(
                text: context.t.busRuleNoIdCard,
                style: TextStyle(
                  color: ApTheme.of(context).red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: context.t.busRuleFollowingTime,
                style: TextStyle(color: ApTheme.of(context).red),
              ),
              TextSpan(
                text: context.t.busRuleLateAndNoReservation,
              ),
              TextSpan(
                text: context.t.busRuleStandbyTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              TextSpan(
                text: context.t.busRuleStandbyRule,
              ),
              TextSpan(
                text: context.t.busRuleFineTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              TextSpan(
                text: context.t.busRuleFineRule,
                style: TextStyle(color: ApTheme.of(context).red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
