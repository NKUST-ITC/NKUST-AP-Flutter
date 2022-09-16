import 'package:ap_common/callback/general_callback.dart';
import 'package:ap_common/config/analytics_constants.dart';
import 'package:ap_common/l10n/l10n.dart';
import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/widgets/hint_content.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/ap_helper.dart';
import 'package:nkust_ap/api/mobile_nkust_helper.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/pages/bus/bus_rule_page.dart';
import 'package:nkust_ap/pages/bus/bus_violation_records_page.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';

class BusPage extends StatefulWidget {
  static const String routerName = "/bus";
  final int initIndex;

  BusPage({this.initIndex = 0});

  @override
  BusPageState createState() => BusPageState();
}

class BusPageState extends State<BusPage> with SingleTickerProviderStateMixin {
  AppLocalizations? app;

  TabController? controller;

  int _currentIndex = 0;

  final List<Widget> _children = [
    BusReservePage(),
    BusReservationsPage(),
    BusViolationRecordsPage()
  ];

  Future<bool>? _login;

  @override
  void initState() {
    _currentIndex = widget.initIndex;
    controller =
        TabController(length: 3, initialIndex: widget.initIndex, vsync: this);
    _login = Future.microtask(() => login());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(app!.bus),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                ApIcon.info,
                color: Colors.white,
              ),
              onPressed: () {
                ApUtils.pushCupertinoStyle(
                  context,
                  BusRulePage(),
                );
              })
        ],
        elevation: (_currentIndex == 2) ? 0.0 : null,
      ),
      body: FutureBuilder<bool>(
        future: _login,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.data!)
            return TabBarView(
              children: _children,
              controller: controller,
              physics: NeverScrollableScrollPhysics(),
            );
          else if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          else
            return InkWell(
              onTap: () {
                _login = Future.microtask(() => login());
              },
              child: HintContent(
                content: ApLocalizations.of(context).clickToRetry,
                icon: ApIcon.error,
              ),
            );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        fixedColor: ApTheme.of(context).yellow,
        items: [
          BottomNavigationBarItem(
            icon: Icon(ApIcon.dateRange),
            label: app!.busReserve,
          ),
          BottomNavigationBarItem(
            icon: Icon(ApIcon.assignment),
            label: app!.busReservations,
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: <Widget>[
                Icon(ApIcon.monetizationOn),
                if (ShareDataWidget.of(context)!.data!.hasBusViolationRecords)
                  Positioned(
                    top: -1.0,
                    right: -1.0,
                    child: Stack(
                      children: <Widget>[
                        Icon(
                          Icons.brightness_1,
                          size: 10.0,
                          color: ApTheme.of(context).red,
                        ),
                      ],
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
    Helper.instance!.getBusViolationRecords(
      callback: GeneralCallback(
        onSuccess: (BusViolationRecordsData data) {
          if (mounted)
            setState(() {
              ShareDataWidget.of(context)!.data!.hasBusViolationRecords =
                  data.hasBusViolationRecords;
            });
          FirebaseAnalyticsUtils.instance.setUserProperty(
            Constants.CAN_USE_BUS,
            AnalyticsConstants.yes,
          );
          FirebaseAnalyticsUtils.instance.setUserProperty(
            Constants.HAS_BUS_VIOLATION,
            (data?.hasBusViolationRecords ?? false)
                ? AnalyticsConstants.yes
                : AnalyticsConstants.no,
          );
        },
        onError: (GeneralResponse response) {},
        onFailure: (DioError e) {
          if (e.hasResponse &&
              (e.response!.statusCode == 401 || e.response!.statusCode == 403)) {
            FirebaseAnalyticsUtils.instance.setUserProperty(
              Constants.CAN_USE_BUS,
              AnalyticsConstants.no,
            );
          }
        },
      ),
    );
  }

  Future<bool> login() async {
    if (MobileNkustHelper.instance!.cookiesData == null) {
      try {
        await WebApHelper.instance!.loginToMobile();
      } catch (e) {
        return false;
      }
    }
    if (widget.initIndex != 2) getBusViolationRecords();
    return true;
  }
}
