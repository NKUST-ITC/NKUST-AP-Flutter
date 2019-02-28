import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/home/leaves/leave_apply_page.dart';
import 'package:nkust_ap/pages/home/leaves/leave_record_page.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';

class LeavePageRoute extends MaterialPageRoute {
  LeavePageRoute({this.initIndex = 0})
      : super(
            builder: (BuildContext context) =>
                new LeavePage(initIndex: initIndex));

  final int initIndex;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(
        opacity: animation, child: new LeavePage(initIndex: initIndex));
  }
}

class LeavePage extends StatefulWidget {
  static const String routerName = "/leave";
  final List<Widget> _children = [
    LeaveApplyPage(),
    LeaveRecordPage(),
  ];
  final int initIndex;

  LeavePage({this.initIndex = 0});

  @override
  LeavePageState createState() => new LeavePageState(_children, initIndex);
}

class LeavePageState extends State<LeavePage>
    with SingleTickerProviderStateMixin {
  final List<Widget> _children;
  final int initIndex;
  int _currentIndex = 0;
  AppLocalizations app;

  TabController controller;

  LeavePageState(this._children, this.initIndex) {
    _currentIndex = initIndex;
  }

  @override
  void initState() {
    super.initState();
    FA.setCurrentScreen("LeavePage", "leave_page.dart");
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
    return Scaffold(
      appBar: AppBar(
        title: Text(app.leave),
        backgroundColor: Resource.Colors.blue,
      ),
      body: TabBarView(
          children: _children,
          controller: controller,
          physics: NeverScrollableScrollPhysics()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        fixedColor: Resource.Colors.yellow,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            title: Text(app.leaveApply),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            title: Text(app.leaveRecords),
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
