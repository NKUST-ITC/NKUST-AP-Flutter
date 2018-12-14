import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:nkust_ap/pages/page.dart';
import 'package:nkust_ap/utils/app_localizations.dart';

class BusPageRoute extends MaterialPageRoute {
  BusPageRoute({this.initIndex = 0})
      : super(
            builder: (BuildContext context) =>
                new BusPage(initIndex: initIndex));

  final int initIndex;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(
        opacity: animation, child: new BusPage(initIndex: initIndex));
  }
}

class BusPage extends StatefulWidget {
  static const String routerName = "/bus";
  final List<Widget> _children = [
    new BusReservePage(),
    new BusReservationsPage()
  ];
  final int initIndex;

  BusPage({this.initIndex = 0});

  @override
  BusPageState createState() => new BusPageState(_children, initIndex);
}

class BusPageState extends State<BusPage> with SingleTickerProviderStateMixin {
  final List<Widget> _children;
  final int initIndex;
  int _currentIndex = 0;
  AppLocalizations app;

  TabController controller;

  BusPageState(this._children, this.initIndex) {
    _currentIndex = initIndex;
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, initialIndex: initIndex, vsync: this);
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
      appBar: new AppBar(
        title: new Text(app.bus),
        backgroundColor: Resource.Colors.blue,
      ),
      body: TabBarView(
          children: _children,
          controller: controller,
          physics: new NeverScrollableScrollPhysics()),
      bottomNavigationBar: new BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        fixedColor: Resource.Colors.yellow,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.date_range),
            title: Text(app.busReserve),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
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
