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

  const BusPage({
    this.initIndex = 0,
  });

  @override
  BusPageState createState() => BusPageState();
}

class BusPageState extends State<BusPage> with SingleTickerProviderStateMixin {
  TabController? controller;

  int _currentIndex = 0;

  final List<Widget> _children = <Widget>[
    BusReservePage(),
    BusReservationsPage(),
    BusViolationRecordsPage(),
  ];

  Future<bool>? _login;

  @override
  void initState() {
    _currentIndex = widget.initIndex;
    controller =
        TabController(length: 3, initialIndex: widget.initIndex, vsync: this);
    _login = Future<bool>.microtask(() => login());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.bus),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              ApIcon.info,
              color: Colors.white,
            ),
            onPressed: () {
              ApUtils.pushCupertinoStyle(
                context,
                const BusRulePage(),
              );
            },
          ),
        ],
        elevation: (_currentIndex == 2) ? 0.0 : null,
      ),
      body: FutureBuilder<bool>(
        future: _login,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data!) {
            return TabBarView(
              controller: controller,
              physics: const NeverScrollableScrollPhysics(),
              children: _children,
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return InkWell(
              onTap: () {
                _login = Future<bool>.microtask(() => login());
              },
              child: HintContent(
                content: context.ap.clickToRetry,
                icon: ApIcon.error,
              ),
            );
          }
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: onTabTapped,
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: Icon(ApIcon.dateRange),
            label: context.t.busReserve,
          ),
          NavigationDestination(
            icon: Icon(ApIcon.assignment),
            label: context.t.busReservations,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible:
                  ShareDataWidget.of(context)!.data.hasBusViolationRecords,
              child: Icon(ApIcon.monetizationOn),
            ),
            label: context.t.busViolationRecords,
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

  Future<void> getBusViolationRecords() async {
    try {
      final BusViolationRecordsData data =
          await Helper.instance.getBusViolationRecords();
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
        (data.hasBusViolationRecords)
            ? AnalyticsConstants.yes
            : AnalyticsConstants.no,
      );
    } on DioException catch (e) {
      if (e.hasResponse &&
          (e.response!.statusCode == 401 || e.response!.statusCode == 403)) {
        AnalyticsUtil.instance.setUserProperty(
          Constants.canUseBus,
          AnalyticsConstants.no,
        );
      }
    } catch (e, s) {
      CrashlyticsUtil.instance.recordError(e, s);
    }
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
