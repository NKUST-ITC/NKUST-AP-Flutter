import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/home/leave/leave_apply_page.dart';
import 'package:nkust_ap/pages/home/leave/leave_record_page.dart';
import 'package:nkust_ap/utils/global.dart';

class LeavePage extends StatefulWidget {
  static const String routerName = "/leave";
  final List<Widget> _children = [
    LeaveApplyPage(),
    LeaveRecordPage(),
  ];
  final int initIndex;

  LeavePage({this.initIndex = 0});

  @override
  LeavePageState createState() => LeavePageState();
}

class LeavePageState extends State<LeavePage>
    with SingleTickerProviderStateMixin {
  AppLocalizations app;

  TabController controller;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initIndex;
    controller =
        TabController(length: 2, initialIndex: widget.initIndex, vsync: this);
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
        backgroundColor: ApTheme.of(context).blue,
      ),
      body: TabBarView(
          children: widget._children,
          controller: controller,
          physics: NeverScrollableScrollPhysics()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        fixedColor: ApTheme.of(context).yellow,
        items: [
          BottomNavigationBarItem(
            icon: Icon(ApIcon.edit),
            title: Text(app.leaveApply),
          ),
          BottomNavigationBarItem(
            icon: Icon(ApIcon.assignment),
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
