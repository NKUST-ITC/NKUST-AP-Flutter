import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/l10n/l10n.dart';

class ReportPage extends StatefulWidget {
  static const String routerName = '/report';

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AppLocalizations? app;

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(app!.reportProblem),
        backgroundColor: ApTheme.of(context).blue,
      ),
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(app!.reportNetProblem),
            subtitle: Text(app!.reportNetProblemSubTitle),
            onTap: () async {
              const String url =
                  'https://docs.google.com/forms/d/e/1FAIpQLSfAOZaF-aM4XwuJRXaSp1uzZ1nZqhl7M6-oc4xWrCbM4tqcuw/viewform';
              await PlatformUtil.instance.launchUrl(url);
              AnalyticsUtil.instance.logEvent('net_problem_click');
            },
          );
        },
      ),
    );
  }
}
