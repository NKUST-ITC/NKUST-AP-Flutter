import 'package:flutter/material.dart';

import 'colors.dart' as Resource;

class AppTheme {
  static const String DARK = 'dark';
  static const String LIGHT = 'light';

  static String code = AppTheme.LIGHT;

  static ThemeData get data {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return dark;
      case AppTheme.LIGHT:
      default:
        return light;
    }
  }

  static double get drawerIconOpacity {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return 0.75;
      case AppTheme.LIGHT:
      default:
        return 1.0;
    }
  }

  static ThemeData get light => ThemeData(
        //platform: TargetPlatform.iOS,
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          color: Resource.Colors.blue,
        ),
        accentColor: Resource.Colors.blueText,
        unselectedWidgetColor: Resource.Colors.grey,
        backgroundColor: Colors.black12,
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        //platform: TargetPlatform.iOS,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Resource.Colors.onyx,
        accentColor: Resource.Colors.blueAccent,
        unselectedWidgetColor: Resource.Colors.grey,
        backgroundColor: Colors.black12,
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      );
}
