import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/global.dart';

class BusRulePage extends StatefulWidget {
  static const String routerName = "/bus/rule";

  BusRulePage();

  @override
  BusRulePageState createState() => new BusRulePageState();
}

class BusRulePageState extends State<BusRulePage> {
  AppLocalizations app;

  @override
  void initState() {
    FirebaseAnalyticsUtils.instance
        .setCurrentScreen("BusRulePage", "bus_rule_page.dart");
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    //TODO English version
    return new Scaffold(
      appBar: AppBar(
        title: Text(app.busRule),
        backgroundColor: ApTheme.of(context).blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: SelectableText.rich(
          TextSpan(
              style: TextStyle(
                  color: Resource.Colors.grey, height: 1.3, fontSize: 16.0),
              children: [
                TextSpan(
                  text: app.busTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
                TextSpan(
                  text: app.please,
                ),
                TextSpan(
                    text: "http://bus.kuas.edu.tw/",
                    style: TextStyle(
                      color: Resource.Colors.blueAccent,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap =
                          () => Utils.launchUrl('http://bus.kuas.edu.tw/')),
                TextSpan(
                    text: app.busRule1
                ),
                TextSpan(
                  text: app.busRule2,
                  style: TextStyle(color: Resource.Colors.red),
                ),
                TextSpan(
                  text: app.busRule3,
                ),
                TextSpan(
                  text: app.busRule4,
                  style: TextStyle(color: Resource.Colors.red),
                ),
                TextSpan(
                  text: app.busRule4,
                ),
                TextSpan(
                  text: app.busRule5,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
                TextSpan(
                  text: app.busRule6,
                ),
                TextSpan(
                  text: app.busRule7,
                  style: TextStyle(color: Resource.Colors.blueText),
                ),
                TextSpan(
                  text: app.busRule8,
                ),
                TextSpan(
                  text: app.busRule9,
                  style: TextStyle(
                      color: Resource.Colors.red, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: app.busRule10,
                  style: TextStyle(color: Resource.Colors.red),
                ),
                TextSpan(
                  text: app.busRule11,
                ),
                TextSpan(
                  text: app.busRule12,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
                TextSpan(
                  text: app.busRule13,
                ),
                TextSpan(
                  text: app.busRule14,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
                TextSpan(
                  text: app.busRule15,
                  style: TextStyle(color: Resource.Colors.red),
                ),
              ]),
        ),
      ),
    );
  }
}
