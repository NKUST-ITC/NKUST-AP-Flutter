import 'package:flutter/material.dart';
import 'package:nkust_ap/res/string.dart';
import 'package:nkust_ap/pages/page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics = new FirebaseAnalytics();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      localeResolutionCallback:
          (Locale locale, Iterable<Locale> supportedLocales) {
        return locale;
      },
      title: Strings.app_name,
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        Navigator.defaultRouteName: (context) => LoginPage(),
        LoginPage.routerName: (BuildContext context) => LoginPage(),
        HomePage.routerName: (BuildContext context) => HomePage(),
        CoursePage.routerName: (BuildContext context) => CoursePage(),
        BusPage.routerName: (BuildContext context) => BusPage(),
        ScorePage.routerName: (BuildContext context) => ScorePage(),
        SchoolInfoPage.routerName: (BuildContext context) => SchoolInfoPage(),
        SettingPage.routerName: (BuildContext context) => SettingPage(),
        AboutUsPage.routerName: (BuildContext context) => AboutUsPage(),
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
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // English
        const Locale('zh', 'TW'), // Hebrew
        // ... other locales the app supports
      ],
    );
  }
}
