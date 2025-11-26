import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/ap_helper.dart';
import 'package:nkust_ap/api/mobile_nkust_helper.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/pages/bus/bus_rule_page.dart';
import 'package:nkust_ap/pages/bus/bus_violation_records_page.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';

class BusPage extends StatefulWidget {
  static const String routerName = '/bus';
  final int initIndex;

  const BusPage({this.initIndex = 0});

  @override
  BusPageState createState() => BusPageState();
}

class BusPageState extends State<BusPage> with SingleTickerProviderStateMixin {
  AppLocalizations? app;
  TabController? controller;
  int _currentIndex = 0;
  Future<bool>? _login;

  final _children = <Widget>[
    BusReservePage(),
    BusReservationsPage(),
    BusViolationRecordsPage(),
  ];

  @override
  void initState() {
    _currentIndex = widget.initIndex;
    controller = TabController(
      length: 3,
      initialIndex: widget.initIndex,
      vsync: this,
    );
    _login = Future.microtask(() => login());
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(app!.bus),
        actions: [
          IconButton(
            icon: Icon(ApIcon.info),
            onPressed: () {
              ApUtils.pushCupertinoStyle(context, const BusRulePage());
            },
          ),
        ],
        elevation: _currentIndex == 2 ? 0.0 : null,
      ),
      body: FutureBuilder<bool>(
        future: _login,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data!) {
            return TabBarView(
              controller: controller,
              physics: const NeverScrollableScrollPhysics(),
              children: _children,
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return InkWell(
              onTap: () => _login = Future.microtask(() => login()),
              child: HintContent(
                content: ApLocalizations.of(context).clickToRetry,
                icon: ApIcon.error,
              ),
            );
          }
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: onTabTapped,
        destinations: [
          NavigationDestination(
            icon: Icon(ApIcon.dateRange),
            label: app!.busReserve,
          ),
          NavigationDestination(
            icon: Icon(ApIcon.assignment),
            label: app!.busReservations,
          ),
          NavigationDestination(
            icon: Stack(
              children: [
                Icon(ApIcon.monetizationOn),
                if (ShareDataWidget.of(context)!.data.hasBusViolationRecords)
                  Positioned(
                    top: -1.0,
                    right: -1.0,
                    child: Icon(
                      Icons.brightness_1,
                      size: 10.0,
                      color: colorScheme.error,
                    ),
                  ),
              ],
            ),
            label: app!.busViolationRecords,
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      controller!.animateTo(_currentIndex);
    });
  }

  void getBusViolationRecords() {
    Helper.instance.getBusViolationRecords(
      callback: GeneralCallback<BusViolationRecordsData>(
        onSuccess: (data) {
          if (mounted) {
            setState(() {
              ShareDataWidget.of(context)!.data.hasBusViolationRecords =
                  data.hasBusViolationRecords;
            });
          }
          AnalyticsUtil.instance.setUserProperty(
            Constants.canUseBus,
            AnalyticsConstants.yes,
          );
          AnalyticsUtil.instance.setUserProperty(
            Constants.hasBusViolation,
            data.hasBusViolationRecords
                ? AnalyticsConstants.yes
                : AnalyticsConstants.no,
          );
        },
        onError: (_) {},
        onFailure: (e) {
          if (e.hasResponse &&
              (e.response!.statusCode == 401 ||
                  e.response!.statusCode == 403)) {
            AnalyticsUtil.instance.setUserProperty(
              Constants.canUseBus,
              AnalyticsConstants.no,
            );
          }
        },
      ),
    );
  }

  Future<bool> login() async {
    if (MobileNkustHelper.instance.cookiesData == null) {
      try {
        await WebApHelper.instance.loginVms();
      } catch (e, s) {
        CrashlyticsUtil.instance.recordError(e, s);
        return false;
      }
    }
    if (widget.initIndex != 2) getBusViolationRecords();
    return true;
  }
}
