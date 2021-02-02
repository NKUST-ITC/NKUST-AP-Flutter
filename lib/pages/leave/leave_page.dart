import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/leave/leave_apply_page.dart';
import 'package:nkust_ap/pages/leave/leave_record_page.dart';

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
  ApLocalizations ap;

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
    ap = ApLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(ap.leave),
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
            label: ap.leaveApply,
          ),
          BottomNavigationBarItem(
            icon: Icon(ApIcon.assignment),
            label: ap.leaveRecords,
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
