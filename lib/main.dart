import 'dart:async';
import 'dart:io';

import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/app.dart';
import 'package:nkust_ap/config/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isInDebugMode = Constants.isInDebugMode;
  await Preferences.init(key: Constants.key, iv: Constants.iv);
  _preferenceMigrate();
  ApIcon.code =
      Preferences.getString(Constants.PREF_ICON_STYLE_CODE, ApIcon.OUTLINED);
  _setTargetPlatformForDesktop();
  if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
    Crashlytics.instance.enableInDevMode = isInDebugMode;
    // Pass all uncaught errors from the framework to Crashlytics.
    FlutterError.onError = Crashlytics.instance.recordFlutterError;
    runZonedGuarded(() async {
      runApp(
        MyApp(),
      );
    }, Crashlytics.instance.recordError);
  } else {
    runApp(
      MyApp(),
    );
  }
}

void _preferenceMigrate() async {
  String themeCode = Preferences.getString(Constants.PREF_THEME_CODE, null);
  if (themeCode != null) {
    int index;
    switch (themeCode) {
      case ApTheme.DARK:
        index = 2;
        break;
      case ApTheme.LIGHT:
        index = 1;
        break;
      default:
        index = 0;
        break;
    }
    await Preferences.setInt(Constants.PREF_THEME_MODE_INDEX, index);
    Preferences.setString(Constants.PREF_THEME_CODE, null);
  }
}

void _setTargetPlatformForDesktop() {
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}
