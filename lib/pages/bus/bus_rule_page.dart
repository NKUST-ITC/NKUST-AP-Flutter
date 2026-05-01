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
  NkustLocalizations? app;

  @override
  void initState() {
    AnalyticsUtil.instance
        .setCurrentScreen('BusRulePage', 'bus_rule_page.dart');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    app = context.t;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(app!.busRule)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: SelectableText.rich(
          TextSpan(
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              height: 1.3,
              fontSize: 16.0,
            ),
            children: [
              TextSpan(
                text: app!.busRuleReservationRuleTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              TextSpan(text: app!.busRuleTravelBy),
              TextSpan(
                text: 'http://bus.kuas.edu.tw/',
                style: TextStyle(
                  color: colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => PlatformUtil.instance.launchUrl(
                        'http://bus.kuas.edu.tw/',
                      ),
              ),
              TextSpan(text: app!.busRuleFourteenDay),
              TextSpan(
                text: app!.busRuleReservationTime,
                style: TextStyle(color: colorScheme.error),
              ),
              TextSpan(text: app!.busRuleCancellingTitle),
              TextSpan(
                text: app!.busRuleCancelingTime,
                style: TextStyle(color: colorScheme.error),
              ),
              TextSpan(text: app!.busRuleFollow),
              TextSpan(
                text: app!.busRuleTakeOn,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              TextSpan(text: app!.busRuleTwentyDollars),
              TextSpan(
                text: app!.busRulePrepareCoins,
                style: TextStyle(color: colorScheme.primary),
              ),
              TextSpan(text: app!.busRuleIdCard),
              TextSpan(
                text: app!.busRuleNoIdCard,
                style: TextStyle(
                  color: colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: app!.busRuleFollowingTime,
                style: TextStyle(color: colorScheme.error),
              ),
              TextSpan(text: app!.busRuleLateAndNoReservation),
              TextSpan(
                text: app!.busRuleStandbyTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              TextSpan(text: app!.busRuleStandbyRule),
              TextSpan(
                text: app!.busRuleFineTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              TextSpan(
                text: app!.busRuleFineRule,
                style: TextStyle(color: colorScheme.error),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
