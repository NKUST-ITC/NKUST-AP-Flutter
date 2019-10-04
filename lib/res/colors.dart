import 'package:flutter/material.dart';

import 'app_theme.dart';

class Colors {
  Colors._();

  static Color get blue {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return blueDark;
      case AppTheme.LIGHT:
      default:
        return blue500;
    }
  }

  static Color get blueText {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return grey100;
      case AppTheme.LIGHT:
      default:
        return blue500;
    }
  }

  static get blueAccent {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return blue300;
      case AppTheme.LIGHT:
      default:
        return blue500;
    }
  }

  static get semesterText {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return Color(0xffffffff);
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

  static get disabled {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return Color(0xFF424242);
      case AppTheme.LIGHT:
      default:
        return Color(0xFFBDBDBD);
    }
  }

  static Color get calendarTileSelect {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return Color(0xff000000);
      case AppTheme.LIGHT:
      default:
        return Color(0xffffffff);
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

  static Color get bottomNavigationSelect {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return grey100;
      case AppTheme.LIGHT:
      default:
        return Color(0xff737373);
    }
  }

  static Color get segmentControlUnSelect {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return onyx;
      case AppTheme.LIGHT:
      default:
        return Color(0xffffffff);
    }
  }

  static get snackBarActionTextColor {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return yellow500;
      case AppTheme.LIGHT:
      default:
        return yellow500;
    }
  }

  static const Color blueDark = const Color(0xff141e2f);
  static const Color onyx = const Color(0xff121212);
  static const Color grayChateau = const Color(0xffa5a5a5);

  static const Color blue200 = const Color(0xffa7c7ff);
  static const Color blue300 = const Color(0xff7cabff);
  static const Color blue400 = const Color(0xff508fff);
  static const Color blue500 = const Color(0xff2574ff);
  static const Color blue800 = const Color(0xff0e2e66);

  static const Color grey100 = const Color(0xffd7d7d7);
  static const Color grey150 = const Color(0xffcacaca);
  static const Color grey200 = const Color(0xffbdbdbd);
  static const Color grey500 = const Color(0xff7c7c7c);
  static const Color grey800 = const Color(0xff313131);

  static const Color yellow200 = const Color(0xffffe399);
  static const Color yellow500 = const Color(0xffffba00);
  static const Color yellow800 = const Color(0xff664a00);

  static const Color red100 = const Color(0xffffdade);
  static const Color red200 = const Color(0xffffb6bd);
  static const Color red500 = const Color(0xffff4a5a);
  static const Color red800 = const Color(0xff661d24);
}
