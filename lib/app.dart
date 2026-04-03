import 'package:ap_common/ap_common.dart';
import 'package:ap_common_firebase/ap_common_firebase.dart';
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
  Uint8List? pictureBytes;

  int currentColorIndex = 0;
  Color? customColor;

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
    _initLocale();
    themeMode = ThemeMode.values[
        PreferenceUtil.instance.getInt(Constants.prefThemeModeIndex, 0)];
    currentColorIndex =
        PreferenceUtil.instance.getInt(ApTheme.PREF_COLOR_INDEX, 0);
    final int customColorValue =
        PreferenceUtil.instance.getInt(ApTheme.PREF_CUSTOM_COLOR, 0);
    if (currentColorIndex == ApTheme.customColorIndex &&
        customColorValue != 0) {
      customColor = Color(customColorValue);
    }
    (AnalyticsUtil.instance as FirebaseAnalyticsUtils).logThemeEvent(themeMode);
    AnalyticsUtil.instance
        .setUserProperty(AnalyticsConstants.iconStyle, ApIcon.code);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  Future<void> _initLocale() async {
    final String languageCode = PreferenceUtil.instance.getString(
      Constants.prefLanguageCode,
      ApSupportLanguageConstants.system,
    );
    if (languageCode == ApSupportLanguageConstants.system) {
      await useApDeviceLocale();
    } else {
      final Locale locale = Locale(
        languageCode,
        languageCode == ApSupportLanguageConstants.zh ? 'TW' : null,
      );
      await setApLocaleFromFlutter(locale);
    }
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
    return TranslationProvider(
      child: ShareDataWidget(
        data: this,
        child: ApTheme(
        themeMode: themeMode,
        currentColorIndex: currentColorIndex,
        customColor: customColor,
        preferences: PreferenceUtil.instance as ApPreferenceUtil,
        child: Builder(
          builder: (BuildContext context) {
            final Color seedColor = ApTheme.of(context).seedColor;
            return MaterialApp(
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
              theme: ApTheme.light(seedColor),
              darkTheme: ApTheme.dark(seedColor),
              themeMode: themeMode,
              locale: TranslationProvider.of(context).flutterLocale,
              localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
                appDelegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const <Locale>[
                Locale('en', 'US'), // English
                Locale('zh', 'TW'), // Traditional Chinese TW
              ],
            );
          },
        ),
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

  void loadThemeColor(int index, Color? custom) {
    setState(() {
      currentColorIndex = index;
      customColor = custom;
    });
  }

  void loadLocale(Locale locale) {
    this.locale = locale;
    AnnouncementHelper.instance.setLocale(this.locale!);
    appDelegate.load(locale);
    setApLocaleFromFlutter(locale);
  }
}
