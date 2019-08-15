import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/home/bus/bus_rule_page.dart';
import 'package:nkust_ap/res/app_icon.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';

class BusPage extends StatefulWidget {
  static const String routerName = "/bus";
  final List<Widget> _children = [
    new BusReservePage(),
    new BusReservationsPage()
  ];
  final int initIndex;

  BusPage({this.initIndex = 0});

  @override
  BusPageState createState() => new BusPageState();
}

class BusPageState extends State<BusPage> with SingleTickerProviderStateMixin {
  AppLocalizations app;

  TabController controller;

  int _currentIndex = 0;

  @override
  void initState() {
    controller =
        TabController(length: 2, initialIndex: widget.initIndex, vsync: this);
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
    return new Scaffold(
      appBar: AppBar(
        title: Text(app.bus),
        backgroundColor: Resource.Colors.blue,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                AppIcon.info,
                color: Colors.white,
              ),
              onPressed: () {
                Utils.pushCupertinoStyle(context, BusRulePage());
              })
        ],
      ),
      body: TabBarView(
          children: widget._children,
          controller: controller,
          physics: NeverScrollableScrollPhysics()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        fixedColor: Resource.Colors.yellow,
        items: [
          BottomNavigationBarItem(
            icon: Icon(AppIcon.dateRange),
            title: Text(app.busReserve),
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcon.assignment),
            title: Text(app.busReservations),
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
}
