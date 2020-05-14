import 'package:ap_common/callback/general_callback.dart';
import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:flutter/material.dart';
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
  AppLocalizations app;

  TabController controller;

  int _currentIndex = 0;

  final List<Widget> _children = [
    BusReservePage(),
    BusReservationsPage(),
    BusViolationRecordsPage()
  ];

  @override
  void initState() {
    _currentIndex = widget.initIndex;
    controller =
        TabController(length: 3, initialIndex: widget.initIndex, vsync: this);
    getBusViolationRecords();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(app.bus),
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
      body: TabBarView(
        children: _children,
        controller: controller,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        fixedColor: ApTheme.of(context).yellow,
        items: [
          BottomNavigationBarItem(
            icon: Icon(ApIcon.dateRange),
            title: Text(app.busReserve),
          ),
          BottomNavigationBarItem(
            icon: Icon(ApIcon.assignment),
            title: Text(app.busReservations),
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: <Widget>[
                Icon(ApIcon.monetizationOn),
                if (ShareDataWidget.of(context).data.hasBusViolationRecords)
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
            title: Text(app.busViolationRecords),
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      controller.animateTo(_currentIndex);
    });
  }

  void getBusViolationRecords() {
    Helper.instance.getBusViolationRecords(
      callback: GeneralCallback(
        onSuccess: (BusViolationRecordsData data) {
          print(data.reservations.length);
          setState(() {
            ShareDataWidget.of(context).data.hasBusViolationRecords =
                data.hasBusViolationRecords;
          });
        },
        onError: (GeneralResponse response) {},
        onFailure: (DioError e) {},
      ),
    );
  }
}
