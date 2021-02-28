import 'package:ap_common/api/announcement_helper.dart';
import 'package:ap_common/config/analytics_constants.dart';
import 'package:ap_common/pages/about_us_page.dart';
import 'package:ap_common/pages/open_source_page.dart';
import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common_firebase/utils/firebase_analytics_utils.dart';
import 'package:ap_common_firebase/utils/firebase_utils.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/pages/bus/bus_rule_page.dart';
import 'package:nkust_ap/pages/page.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';

import 'api/helper.dart';
import 'models/login_response.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ThemeMode themeMode = ThemeMode.system;

  Locale locale;

  LoginResponse loginResponse;

  bool offlineLogin = false;
  bool hasBusViolationRecords = false;

  FirebaseAnalytics analytics;

  logout() {
    setState(() {
      this.offlineLogin = false;
      this.loginResponse = null;
      Helper.clearSetting();
    });
  }

  @override
  void initState() {
    analytics = FirebaseUtils.init(vapidKey: Constants.FCM_WEB_VAPID_KEY);
    themeMode = ThemeMode
        .values[Preferences.getInt(Constants.PREF_THEME_MODE_INDEX, 0)];
    FirebaseAnalyticsUtils.instance.logThemeEvent(themeMode);
    FirebaseAnalyticsUtils.instance
        .setUserProperty(AnalyticsConstants.ICON_STYLE, ApIcon.code);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
    FirebaseAnalyticsUtils.instance.logThemeEvent(themeMode);
    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return ShareDataWidget(
      data: this,
      child: ApTheme(
        themeMode,
        child: MaterialApp(
          localeResolutionCallback:
              (Locale locale, Iterable<Locale> supportedLocales) {
            String languageCode = Preferences.getString(
              Constants.PREF_LANGUAGE_CODE,
              ApSupportLanguageConstants.SYSTEM,
            );
            if (languageCode == ApSupportLanguageConstants.SYSTEM)
              this.locale = ApLocalizations.delegate.isSupported(locale)
                  ? locale
                  : Locale('en');
            else
              this.locale = Locale(
                languageCode,
                languageCode == ApSupportLanguageConstants.ZH ? 'TW' : null,
              );
            AnnouncementHelper.instance.setLocale(this.locale);
            return this.locale;
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
            AboutUsPage.routerName: (BuildContext context) =>
                HomePageState.aboutPage(context),
            OpenSourcePage.routerName: (BuildContext context) =>
                OpenSourcePage(),
            UserInfoPage.routerName: (BuildContext context) => UserInfoPage(),
            CalculateUnitsPage.routerName: (BuildContext context) =>
                CalculateUnitsPage(),
            LeavePage.routerName: (BuildContext context) => LeavePage(),
          },
          theme: ApTheme.light,
          darkTheme: ApTheme.dark,
          themeMode: themeMode,
          locale: locale,
          navigatorObservers: [
            if (FirebaseUtils.isSupportAnalytics)
              FirebaseAnalyticsObserver(analytics: analytics),
          ],
          localizationsDelegates: [
            const AppLocalizationsDelegate(),
            ApLocalizations.delegate,
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

  void update() {
    setState(() {});
  }

  void loadTheme(ThemeMode mode) {
    setState(() {
      themeMode = mode;
    });
  }

  void loadLocale(Locale locale) {
    this.locale = locale;
    AnnouncementHelper.instance.setLocale(this.locale);
    setState(() {
      AppLocalizationsDelegate().load(locale);
      ApLocalizations.load(locale);
    });
  }
}
