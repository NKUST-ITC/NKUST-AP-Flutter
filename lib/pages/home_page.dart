import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/home/dashboard_page.dart';
import 'package:nkust_ap/pages/home/setting_page.dart';
import 'package:nkust_ap/res/string.dart';
import 'package:nkust_ap/res/theme.dart' as Theme;

class HomePageRoute extends MaterialPageRoute {
  HomePageRoute()
      : super(builder: (BuildContext context) => new HomePage());


  // OPTIONAL IF YOU WISH TO HAVE SOME EXTRA ANIMATION WHILE ROUTING
  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: new HomePage());
  }
}
class HomePage extends StatefulWidget {
  static const String routerName = "/home";

  @override
  HomePageState createState() => new HomePageState();
}

// SingleTickerProviderStateMixin is used for animation
class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // Create a tab controller
  TabController controller;
  int _currentIndex = 0;
  final List<Widget> _children = [new DashboardPage(), new SettingPage()];

  @override
  void initState() {
    super.initState();

    // Initialize the Tab Controller
    controller = new TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // Appbar
      appBar: new AppBar(
        // Title
        title: new Text(Strings.app_name),
        // Set the background color of the App Bar
        backgroundColor: Theme.Colors.blue,
      ),
      // Set the TabBar view as the body of the Scaffold
      body: _children[_currentIndex],
      // Set the bottom navigation bar
      bottomNavigationBar: new BottomNavigationBar(
        // set the color of the bottom navigation bar
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        // set the tab bar as the child of bottom navigation bar
        items: [
          BottomNavigationBarItem(
            // set icon to the tab
            icon: Icon(Icons.dashboard),
            title: Text("主控版"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text("設定"),
          ),
        ],
        //,
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
