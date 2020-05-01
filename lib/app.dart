import 'dart:io';
import 'dart:typed_data';

import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/pages/home/bus/bus_rule_page.dart';
import 'package:nkust_ap/pages/home/news/news_admin_page.dart';
import 'package:nkust_ap/pages/page.dart';
import 'package:nkust_ap/res/app_icon.dart';
import 'package:nkust_ap/res/app_theme.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/firebase_analytics_utils.dart';
import 'package:nkust_ap/utils/preferences.dart';
import 'package:nkust_ap/utils/utils.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';

import 'api/helper.dart';
import 'models/login_response.dart';
import 'models/user_info.dart';

class MyApp extends StatefulWidget {
  final ThemeData themeData;

  const MyApp({Key key, @required this.themeData}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  FirebaseAnalytics analytics;
  FirebaseMessaging firebaseMessaging;
  ThemeData themeData;
  UserInfo userInfo;
  LoginResponse loginResponse;
  Uint8List pictureBytes;
  bool isLogin = false, offlineLogin = false;

  ThemeMode themeMode = ThemeMode.system;

  logout() {
    setState(() {
      this.isLogin = false;
      this.offlineLogin = false;
      this.userInfo = null;
      this.loginResponse = null;
      this.pictureBytes = null;
      Helper.clearSetting();
    });
  }

  @override
  void initState() {
    themeData = widget.themeData;
    if (kIsWeb) {
    } else if (Platform.isAndroid || Platform.isIOS) {
      analytics = FirebaseAnalytics();
      firebaseMessaging = FirebaseMessaging();
      _initFCM();
      FA.analytics = analytics;
      FA.setUserProperty('theme', AppTheme.code);
      FA.setUserProperty('icon_style', AppIcon.code);
      Preferences.init();
    }
    themeMode = ThemeMode
        .values[Preferences.getInt(Constants.PREF_THEME_MODE_INDEX, 0)];
    //TODO old preference migrate
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(AppLocalizations.languageCode);
    return ShareDataWidget(
      data: this,
      child: ApTheme(
        themeMode,
        child: MaterialApp(
          localeResolutionCallback:
              (Locale locale, Iterable<Locale> supportedLocales) {
            return locale;
          },
          onGenerateTitle: (context) => AppLocalizations.of(context).appName,
          debugShowCheckedModeBanner: false,
          routes: <String, WidgetBuilder>{
            Navigator.defaultRouteName: (context) => HomePage(),
            LoginPage.routerName: (BuildContext context) => LoginPage(),
            HomePage.routerName: (BuildContext context) => HomePage(),
            CoursePage.routerName: (BuildContext context) => CoursePage(),
            BusPage.routerName: (BuildContext context) => BusPage(),
            BusRulePage.routerName: (BuildContext context) => BusRulePage(),
            ScorePage.routerName: (BuildContext context) => ScorePage(),
            SchoolInfoPage.routerName: (BuildContext context) =>
                SchoolInfoPage(),
            SettingPage.routerName: (BuildContext context) => SettingPage(),
            AboutUsPage.routerName: (BuildContext context) => AboutUsPage(),
            OpenSourcePage.routerName: (BuildContext context) =>
                OpenSourcePage(),
            UserInfoPage.routerName: (BuildContext context) => UserInfoPage(),
            NewsAdminPage.routerName: (BuildContext context) => NewsAdminPage(),
            CalculateUnitsPage.routerName: (BuildContext context) =>
                CalculateUnitsPage(),
            LeavePage.routerName: (BuildContext context) => LeavePage(),
          },
          theme: ApTheme.light,
          darkTheme: ApTheme.dark,
          themeMode: themeMode,
          navigatorObservers: (kIsWeb)
              ? []
              : (Platform.isIOS || Platform.isAndroid)
                  ? [
                      FirebaseAnalyticsObserver(analytics: analytics),
                    ]
                  : [],
          localizationsDelegates: [
            const AppLocalizationsDelegate(),
            const ApLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', 'US'), // English
            const Locale('zh', 'TW'), // Chinese
          ],
        ),
      ),
    );
  }

  void _initFCM() {
    firebaseMessaging.requestNotificationPermissions();
    firebaseMessaging.configure(
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
    firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
        sound: true,
        badge: true,
        alert: true,
      ),
    );
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    firebaseMessaging.getToken().then((String token) {
      if (token == null) return;
      if (Constants.isInDebugMode) {
        print("Push Messaging token: $token");
      }
      if (Platform.isAndroid)
        firebaseMessaging.subscribeToTopic("Android");
      else if (Platform.isIOS) firebaseMessaging.subscribeToTopic("IOS");
    });
  }

  void update(ThemeMode mode) {
    setState(() {
      themeMode = mode;
    });
  }
}
