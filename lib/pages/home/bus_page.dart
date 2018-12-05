import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:nkust_ap/pages/page.dart';
import 'package:nkust_ap/utils/app_localizations.dart';

class BusPageRoute extends MaterialPageRoute {
  BusPageRoute() : super(builder: (BuildContext context) => new BusPage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: new BusPage());
  }
}

class BusPage extends StatefulWidget {
  static const String routerName = "/bus";
  final List<Widget> _children = [
    new BusReservePage(),
    new BusReservationsPage()
  ];

  @override
  BusPageState createState() => new BusPageState(_children);
}

class BusPageState extends State<BusPage>
    with SingleTickerProviderStateMixin {
  final List<Widget> _children;
  int _currentIndex = 0;
  List<String> _title;

  AppLocalizations local;

  TabController controller;

  BusPageState(this._children);

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    local = AppLocalizations.of(context);
    _title = [local.busReserve, local.busReservations];
    return new Scaffold(
      // Appbar
      appBar: new AppBar(
        // Title
        title: new Text(_title[_currentIndex]),
        backgroundColor: Resource.Colors.blue,
      ),
      body: TabBarView(children: _children,controller: controller,physics: new NeverScrollableScrollPhysics()),
      bottomNavigationBar: new BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        fixedColor: Resource.Colors.yellow,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.date_range),
            title: Text(_title[0]),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            title: Text(_title[1]),
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
