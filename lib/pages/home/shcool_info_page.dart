import 'package:flutter/material.dart';
import 'package:nkust_ap/res/app_icon.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';

class SchoolInfoPageRoute extends MaterialPageRoute {
  SchoolInfoPageRoute()
      : super(builder: (BuildContext context) => new SchoolInfoPage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: new SchoolInfoPage());
  }
}

class SchoolInfoPage extends StatefulWidget {
  static const String routerName = "/ShcoolInfo";

  @override
  SchoolInfoPageState createState() => new SchoolInfoPageState();
}

class SchoolInfoPageState extends State<SchoolInfoPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  TabController controller;
  final List<Widget> _children = [
    new NotificationPage(),
    new PhonePage(),
    new SchedulePage()
  ];

  AppLocalizations app;

  @override
  void initState() {
    super.initState();
    FA.setCurrentScreen("SchoolInfoPage", "school_info_page.dart");
    controller = TabController(length: 3, vsync: this);
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
        title: new Text(app.schoolInfo),
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

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      controller.animateTo(_currentIndex);
    });
  }
}
