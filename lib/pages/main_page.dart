import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/login_page.dart';
import 'package:nkust_ap/pages/home_page.dart';

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => new MainPageState();
}

// SingleTickerProviderStateMixin is used for animation
class MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  var isLogin = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: isLogin ? new HomePage() : new LoginPage(),
    );
  }
}
