import 'package:flutter/material.dart';

import 'colors.dart' as Resource;

class AppTheme {
  static const String DARK = 'dark';
  static const String LIGHT = 'light';

  static String code = AppTheme.LIGHT;

  static ThemeData get light => ThemeData(
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
