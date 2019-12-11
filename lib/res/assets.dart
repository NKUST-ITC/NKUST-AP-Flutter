import 'app_theme.dart';

class ImageAssets {
  static const String basePath = 'assets/images';

  static const String kuasap1 = '$basePath/kuasap.webp';
  static const String kuasap2 = '$basePath/kuasap2.webp';
  static const String kuasap3 = '$basePath/kuasap3.webp';
  static const String kuasITC = '$basePath/kuas_itc.webp';
  static const String fb = '$basePath/ic_fb.webp';
  static const String github = '$basePath/ic_github.webp';
  static const String email = '$basePath/ic_email.webp';
  static const String drawerBackgroundLight =
      '$basePath/drawer-background.webp';
  static const String drawerBackgroundDarkTheme =
      '$basePath/drawer-background-dark-theme.webp';
  static const String drawerIconLight = '$basePath/drawer-icon.webp';
  static const String drawerIconDark = '$basePath/drawer-icon.webp';
  static const String K = '$basePath/K.webp';
  static const String dashLineLight = '$basePath/dash_line.webp';
  static const String dashLineDarkTheme = '$basePath/dash_line_dark_theme.webp';

  static String sectionJiangong = '$basePath/section_jiangong.webp';
  static String sectionYanchao = '$basePath/section_yanchao.webp';
  static String sectionFirst1 = '$basePath/section_first1.webp';
  static String sectionFirst2 = '$basePath/section_first2.webp';
  static String sectionNanzi = '$basePath/section_nanzi.webp';
  static String sectionQijin = '$basePath/section_qijin.webp';

  static String get dashLine {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return dashLineDarkTheme;
      case AppTheme.LIGHT:
      default:
        return dashLineLight;
    }
  }

  static String get drawerIcon {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return drawerIconDark;
      case AppTheme.LIGHT:
      default:
        return drawerIconLight;
    }
  }

  static String get drawerBackground {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return drawerBackgroundDarkTheme;
      case AppTheme.LIGHT:
      default:
        return drawerBackgroundLight;
    }
  }
}

class FileAssets {
  static const String basePath = 'assets/';

  static String leaveCampusData = '$basePath/leave_campus_data.json';
  static String scheduleData = '$basePath/schedule_data.json';
}