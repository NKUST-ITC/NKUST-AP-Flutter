import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/page.dart';
import 'package:nkust_ap/res/resource.dart';

class HomePageRoute extends MaterialPageRoute {
  HomePageRoute() : super(builder: (BuildContext context) => new HomePage());

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
  TabController controller;
  int _currentIndex = 0;
  final List<Widget> _children = [
    new BusPage(),
    new CoursePage(),
    new ScorePage()
  ];

  @override
  void initState() {
    super.initState();
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
        backgroundColor: Colors.blue,
      ),
      // Set the TabBar view as the body of the Scaffold
      body: Text("主畫面"),
      // Set the bottom navigation bar
      bottomNavigationBar: new BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
            // set icon to the tab
            icon: Icon(Icons.directions_bus),
            title: Text(Strings.bus),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            title: Text(Strings.course),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            title: Text(Strings.score),
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      switch (_currentIndex) {
        case 0:
          break;
        case 1:
          Navigator.of(context).push(CoursePageRoute());
          break;
        case 2:
          break;
      }
    });
  }
}
