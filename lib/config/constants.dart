import 'package:encrypt/encrypt.dart';

class Constants {
  static bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  static final key = Key.fromUtf8('l9r1W3wcsnJTayxCXwoFt62w1i4sQ5J9');
  static final iv = IV.fromUtf8('auc9OV5r0nLwjCAH');

  static const PREF_FIRST_ENTER_APP = "pref_first_enter_app";
  static const PREF_CURRENT_VERSION = "pref_current_version";
  static const PREF_REMEMBER_PASSWORD = "pref_remember_password";
  static const PREF_AUTO_LOGIN = "pref_auto_login";
  static const PREF_USERNAME = "pref_username";
  static const PREF_PASSWORD = "pref_password";
  static const PREF_NOTIFY_COURSE = "pref_notify_course";
  static const PREF_NOTIFY_BUS = "pref_notify_bus";
  static const PREF_DISPLAY_PICTURE = "pref_display_picture";
  static const PREF_VIBRATE_COURSE = "pref_vibrate_course";
  static const PREF_BUS_ENABLE = "pref_bus_enable";

  static const SCHEDULE_DATA = "schedule_data";
  static const ANDROID_APP_VERSION = "android_app_version";
  static const IOS_APP_VERSION = "ios_app_version";
  static const APP_VERSION = "app_version";

  static const TAG_STUDENT_PICTURE = "tag_student_picture";
  static const TAG_NEWS_PICTURE = "tag_news_picture";
  static const TAG_NEWS_ICON = "tag_news_icon";
  static const TAG_NEWS_TITLE = "tag_news_title";
}
