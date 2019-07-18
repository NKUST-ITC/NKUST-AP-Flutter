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
  static const String drawerBackground = '$basePath/drawer-background.webp';
  static const String drawerIcon = '$basePath/drawer-icon.webp';
  static const String K = '$basePath/K.webp';
  static const String dashLineLight = '$basePath/dash_line.webp';
  static const String dashLineDarkTheme = '$basePath/dash_line_dark_theme.webp';
  static String get dashLine {
    switch (AppTheme.code) {
      case AppTheme.DARK:
        return dashLineDarkTheme;
      case AppTheme.LIGHT:
      default:
        return dashLineLight;
    }
  }
}
