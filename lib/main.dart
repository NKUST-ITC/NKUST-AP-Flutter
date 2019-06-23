import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/pages/home/bus/bus_rule_page.dart';
import 'package:nkust_ap/pages/page.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/firebase_analytics_utils.dart';
import 'package:nkust_ap/utils/utils.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';

void main() async {
  bool isInDebugMode = Constants.isInDebugMode;
  if (Platform.isIOS || Platform.isAndroid) {
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
  } else {
    // See https://github.com/flutter/flutter/wiki/Desktop-shells#target-platform-override
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
    runApp(MyApp());
    //TODO add other platform Crashlytics
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAnalytics analytics;
  FirebaseMessaging _firebaseMessaging;
  Brightness brightness = Brightness.light;

  @override
  void initState() {
    if (Platform.isAndroid || Platform.isIOS) {
      analytics = FirebaseAnalytics();
      _firebaseMessaging = FirebaseMessaging();
      _initFCM();
      FA.analytics = analytics;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ShareDataWidget(
      child: MaterialApp(
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
          BusRulePage.routerName: (BuildContext context) => BusRulePage(),
          ScorePage.routerName: (BuildContext context) => ScorePage(),
          SchoolInfoPage.routerName: (BuildContext context) => SchoolInfoPage(),
          SettingPage.routerName: (BuildContext context) => SettingPage(),
          AboutUsPage.routerName: (BuildContext context) => AboutUsPage(),
          OpenSourcePage.routerName: (BuildContext context) => OpenSourcePage(),
          UserInfoPage.routerName: (BuildContext context) => UserInfoPage(),
          CalculateUnitsPage.routerName: (BuildContext context) =>
              CalculateUnitsPage(),
          NewsContentPage.routerName: (BuildContext context) =>
              NewsContentPage(null),
          LeavePage.routerName: (BuildContext context) => LeavePage(),
        },
        theme: ThemeData(
          brightness: brightness,
          hintColor: Colors.white,
          accentColor: Resource.Colors.blue,
          unselectedWidgetColor: Resource.Colors.grey,
          backgroundColor: Colors.black12,
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.white),
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
          ),
        ),
        navigatorObservers: (Platform.isIOS || Platform.isAndroid)
            ? [
                FirebaseAnalyticsObserver(analytics: analytics),
              ]
            : [],
        localizationsDelegates: [
          const AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          CupertinoEnDefaultLocalizationsDelegate(),
        ],
        supportedLocales: [
          const Locale('en', 'US'), // English
          const Locale('zh', 'TW'), // Chinese
        ],
      ),
    );
  }

  void _initFCM() {
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        if (Constants.isInDebugMode) print("onMessage: $message");
        Utils.showFCMNotification(
            message['notification']['title'] ?? '',
            message['notification']['title'] ?? '',
            message['notification']['body'] ?? '');
      },
      onLaunch: (Map<String, dynamic> message) async {
        if (Constants.isInDebugMode) print("onLaunch: $message");
        //_navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        if (Constants.isInDebugMode) print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      if (token == null) return;
      if (Constants.isInDebugMode) {
        print("Push Messaging token: $token");
      }
      if (Platform.isAndroid)
        _firebaseMessaging.subscribeToTopic("Android");
      else if (Platform.isIOS) _firebaseMessaging.subscribeToTopic("IOS");
    });
  }
}
