import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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

  InAppWebViewController webViewController;

  String get path {
    switch (_currentIndex) {
      case 0:
        return 'https://mobile.nkust.edu.tw/Student/Leave/Create';
      case 1:
      default:
        return 'https://mobile.nkust.edu.tw/Student/Absenteeism';
    }
  }

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
      body: InAppWebView(
        initialUrl: path,
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(),
        ),
        onWebViewCreated: (InAppWebViewController webViewController) {
          this.webViewController = webViewController;
        },
      ),
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
      webViewController.loadUrl(url: path);
    });
  }
}
