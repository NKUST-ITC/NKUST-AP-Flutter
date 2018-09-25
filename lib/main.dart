import 'package:flutter/material.dart';
import 'package:nkust_ap/res/string.dart';
import 'package:nkust_ap/pages/home_page.dart';
import 'package:nkust_ap/pages/login_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  final Map<String, WidgetBuilder> _routes = <String, WidgetBuilder>{
    Navigator.defaultRouteName: (context) => new LoginPage()
  };
  FirebaseAnalytics analytics = new FirebaseAnalytics();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: Strings.app_name,
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        Navigator.defaultRouteName: (context) => LoginPage(),
        LoginPage.routerName: (BuildContext context) => LoginPage(),
        HomePage.routerName: (BuildContext context) => HomePage(),
      },
      theme: new ThemeData(
        hintColor: Colors.white,
        accentColor: Colors.blue,
        inputDecorationTheme: new InputDecorationTheme(
          labelStyle: new TextStyle(color: Colors.white),
          border: new UnderlineInputBorder(
              borderSide: new BorderSide(color: Colors.white)),
        ),
      ),
      navigatorObservers: [
        new FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}
