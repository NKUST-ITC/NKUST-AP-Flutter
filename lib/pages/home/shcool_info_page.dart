import 'package:ap_common/resources/ap_theme.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/res/app_icon.dart';
import 'package:nkust_ap/utils/global.dart';

class SchoolInfoPage extends StatefulWidget {
  static const String routerName = "/ShcoolInfo";

  @override
  SchoolInfoPageState createState() => SchoolInfoPageState();
}

class SchoolInfoPageState extends State<SchoolInfoPage>
    with SingleTickerProviderStateMixin {
  final List<Widget> _children = [
    NotificationPage(),
    PhonePage(),
    SchedulePage()
  ];

  AppLocalizations app;

  TabController controller;

  int _currentIndex = 0;

  @override
  void initState() {
    FA.setCurrentScreen("SchoolInfoPage", "school_info_page.dart");
    controller = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(app.schoolInfo),
        backgroundColor: ApTheme.of(context).blue,
      ),
      body: TabBarView(
        children: _children,
        controller: controller,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            controller.animateTo(_currentIndex);
          });
        },
        fixedColor: ApTheme.of(context).yellow,
        items: [
          BottomNavigationBarItem(
            icon: Icon(AppIcon.fiberNew),
            title: Text(app.notifications),
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcon.phone),
            title: Text(app.phones),
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcon.dateRange),
            title: Text(app.events),
          ),
        ],
      ),
    );
  }
}
