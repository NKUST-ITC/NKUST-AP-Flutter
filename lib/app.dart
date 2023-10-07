import 'package:ap_common/api/announcement_helper.dart';
import 'package:ap_common/config/analytics_constants.dart';
import 'package:ap_common/pages/announcement/home_page.dart';
import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common_firebase/utils/firebase_analytics_utils.dart';
import 'package:ap_common_firebase/utils/firebase_message_utils.dart';
import 'package:ap_common_firebase/utils/firebase_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/pages/page.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ThemeMode themeMode = ThemeMode.system;

  Locale? locale;

  LoginResponse? loginResponse;

  bool offlineLogin = false;
  bool hasBusViolationRecords = false;

  FirebaseAnalytics? analytics;

  void logout() {
    setState(() {
      offlineLogin = false;
      loginResponse = null;
      Helper.clearSetting();
    });
  }

  @override
  void initState() {
    analytics = FirebaseUtils.init();
    FirebaseMessagingUtils.instance.init(
      vapidKey: Constants.fcmWebVapidKey,
    );
    themeMode =
        ThemeMode.values[Preferences.getInt(Constants.prefThemeModeIndex, 0)];
    FirebaseAnalyticsUtils.instance.logThemeEvent(themeMode);
    FirebaseAnalyticsUtils.instance
        .setUserProperty(AnalyticsConstants.iconStyle, ApIcon.code);
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
              (Locale? locale, Iterable<Locale> supportedLocales) {
            final String languageCode = Preferences.getString(
              Constants.prefLanguageCode,
              ApSupportLanguageConstants.system,
            );
            if (languageCode == ApSupportLanguageConstants.system) {
              this.locale = ApLocalizations.delegate.isSupported(locale!)
                  ? locale
                  : const Locale('en');
            } else {
              this.locale = Locale(
                languageCode,
                languageCode == ApSupportLanguageConstants.zh ? 'TW' : null,
              );
            }
            AnnouncementHelper.instance.setLocale(this.locale!);
            return this.locale;
          },
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context).appName,
          debugShowCheckedModeBanner: false,
          routes: <String, WidgetBuilder>{
            Navigator.defaultRouteName: (BuildContext context) => kIsWeb
                ? const AnnouncementHomePage(
                    organizationDomain: Constants.mailDomain,
                  )
                : HomePage(),
            AnnouncementHomePage.routerName: (BuildContext context) =>
                const AnnouncementHomePage(
                  organizationDomain: Constants.mailDomain,
                ),
          },
          theme: ApTheme.light,
          darkTheme: ApTheme.dark,
          themeMode: themeMode,
          locale: locale,
          navigatorObservers: <NavigatorObserver>[
            if (FirebaseAnalyticsUtils.isSupported)
              FirebaseAnalyticsObserver(analytics: analytics!),
          ],
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            apLocalizationsDelegate,
            appDelegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const <Locale>[
            Locale('en', 'US'), // English
            Locale('zh', 'TW'), // Chinese
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
    AnnouncementHelper.instance.setLocale(this.locale!);
    setState(() {
      appDelegate.load(locale);
      ApLocalizations.load(locale);
    });
  }
}
