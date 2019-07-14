import 'package:flutter/material.dart';

import 'app_theme.dart';

class Colors {
  Colors._();

  static Color get blue {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return blue800;
      case AppTheme.LIGHT:
      default:
        return blue500;
    }
  }

  static Color get blueText {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return blue200;
      case AppTheme.LIGHT:
      default:
        return blue500;
    }
  }

  static get blueAccent {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return blue200;
      case AppTheme.LIGHT:
      default:
        return blue500;
    }
  }

  static Color get grey {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return grey200;
      case AppTheme.LIGHT:
      default:
        return grey500;
    }
  }

  static Color get greyText {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return grey200;
      case AppTheme.LIGHT:
      default:
        return grey500;
    }
  }

  static Color get yellow {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return yellow200;
      case AppTheme.LIGHT:
      default:
        return yellow500;
    }
  }

  static Color get red {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return red200;
      case AppTheme.LIGHT:
      default:
        return red500;
    }
  }

  static const Color blue200 = const Color(0xffa7c7ff);
  static const Color blue500 = const Color(0xff2574ff);
  static const Color blue800 = const Color(0xff0e2e66);

  static const Color grey200 = const Color(0xffbdbdbd);
  static const Color grey500 = const Color(0xff7c7c7c);
  static const Color grey800 = const Color(0xff313131);

  static const Color yellow200 = const Color(0xffffe399);
  static const Color yellow500 = const Color(0xffffba00);
  static const Color yellow800 = const Color(0xff664a00);

  static const Color red200 = const Color(0xffffb6bd);
  static const Color red500 = const Color(0xffff4a5a);
  static const Color red800 = const Color(0xff661d24);
}
