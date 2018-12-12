import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/pages/page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';

void main() async {
  bool isInDebugMode = Constants.isInDebugMode;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (isInDebugMode) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // Crashlytics.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  await FlutterCrashlytics().initialize();

  runZoned<Future<Null>>(() async {
    runApp(MyApp());
  }, onError: (error, stackTrace) async {
    // Whenever an error occurs, call the `reportCrash` function. This will send
    // Dart errors to our dev console or Crashlytics depending on the environment.
    await FlutterCrashlytics()
        .reportCrash(error, stackTrace, forceCrash: false);
  });
}

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics = new FirebaseAnalytics();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //_firebaseMessaging.requestNotificationPermissions();
    return new MaterialApp(
      localeResolutionCallback:
          (Locale locale, Iterable<Locale> supportedLocales) {
        return locale;
      },
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
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
        OpenSourcePage.routerName: (BuildContext context) => OpenSourcePage(),
        UserInfoPage.routerName: (BuildContext context) => UserInfoPage(),
      },
      theme: new ThemeData(
        hintColor: Colors.white,
        accentColor: Resource.Colors.blue,
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
