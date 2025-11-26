import 'package:ap_common/ap_common.dart';
import 'package:ap_common_firebase/ap_common_firebase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/config/app_theme.dart';
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
    FirebaseMessagingUtils.instance.init(vapidKey: Constants.fcmWebVapidKey);
    themeMode = ThemeMode.values[
        PreferenceUtil.instance.getInt(Constants.prefThemeModeIndex, 0)];
    AppTheme.currentColorIndex =
        PreferenceUtil.instance.getInt(Constants.prefThemeColorIndex, 0);
    final int customColorValue =
        PreferenceUtil.instance.getInt(Constants.prefCustomThemeColor, 0);
    if (AppTheme.currentColorIndex == AppTheme.customColorIndex &&
        customColorValue != 0) {
      AppTheme.customColor = Color(customColorValue);
    }
    (AnalyticsUtil.instance as FirebaseAnalyticsUtils).logThemeEvent(themeMode);
    AnalyticsUtil.instance
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
    (AnalyticsUtil.instance as FirebaseAnalyticsUtils).logThemeEvent(themeMode);
    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return ShareDataWidget(
      data: this,
      child: ApTheme(
        themeMode,
        child: MaterialApp(
          localeResolutionCallback: _resolveLocale,
          onGenerateTitle: (context) => AppLocalizations.of(context).appName,
          debugShowCheckedModeBanner: false,
          routes: {
            Navigator.defaultRouteName: (_) => kIsWeb
                ? const AnnouncementHomePage(
                    organizationDomain: Constants.mailDomain,
                  )
                : HomePage(),
            AnnouncementHomePage.routerName: (_) => const AnnouncementHomePage(
                  organizationDomain: Constants.mailDomain,
                ),
          },
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: const [
            apLocalizationsDelegate,
            appDelegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('zh', 'TW'),
          ],
        ),
      ),
    );
  }

  Locale? _resolveLocale(Locale? locale, Iterable<Locale> supportedLocales) {
    final languageCode = PreferenceUtil.instance.getString(
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
  }

  void update() => setState(() {});

  void loadTheme(ThemeMode mode) => setState(() => themeMode = mode);

  void loadLocale(Locale locale) {
    this.locale = locale;
    AnnouncementHelper.instance.setLocale(this.locale!);
    setState(() {
      appDelegate.load(locale);
      ApLocalizations.load(locale);
    });
  }
}
