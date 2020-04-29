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

  static const PREF_COURSE_NOTIFY = "pref_course_notify";
  static const PREF_BUS_NOTIFY = "pref_bus_notify";
  static const PREF_COURSE_NOTIFY_DATA = "pref_course_notify_data";
  static const PREF_BUS_NOTIFY_DATA = "pref_bus_notify_data";
  static const PREF_COURSE_VIBRATE = "pref_course_vibrate";
  static const PREF_COURSE_VIBRATE_DATA = "pref_course_vibrate_data";
  static const PREF_COURSE_VIBRATE_USER_SETTING =
      "pref_course_vibrate_user_setting";
  static const PREF_DISPLAY_PICTURE = "pref_display_picture";
  static const PREF_PICTURE_DATA = "pref_picture_data";
  static const PREF_SCORE_DATA = "pref_score_data";
  static const PREF_COURSE_DATA = "pref_course_data";
  static const PREF_LEAVE_DATA = "pref_leave_data";
  static const PREF_SEMESTER_DATA = "pref_semester_data";
  static const PREF_SCHEDULE_DATA = 'pref_schedule_datae';
  static const PREF_USER_INFO = "pref_user_info";
  static const PREF_BUS_RESERVATIONS_DATA = "pref_bus_reservevations_data";

  static const PREF_LANGUAGE_CODE = 'pref_language_code';
  static const PREF_THEME_CODE = 'pref_theme_code';
  static const PREF_ICON_STYLE_CODE = 'pref_icon_style_code';

  static const PREF_AP_ENABLE = "pref_ap_enable";
  static const PREF_BUS_ENABLE = "pref_bus_enable";
  static const PREF_LEAVE_ENABLE = "pref_leave_enable";

  static const PREF_IS_OFFLINE_LOGIN = "pref_is_offline_login";

  static const PREF_AUTO_SEND_EVENT = "pref_auto_send_event";

  static const SCHEDULE_DATA = "schedule_data";
  static const ANDROID_APP_VERSION = "android_app_version";
  static const IOS_APP_VERSION = "ios_app_version";
  static const APP_VERSION = "app_version";
  static const NEW_VERSION_CONTENT_ZH = "new_version_content_zh";
  static const NEW_VERSION_CONTENT_EN = "new_version_content_en";
  static const API_HOST = 'api_host';
  static const LEAVE_CAMPUS_DATA = 'leave_campus_data';

  static const TAG_STUDENT_PICTURE = "tag_student_picture";
  static const TAG_NEWS_PICTURE = "tag_news_picture";
  static const TAG_NEWS_ICON = "tag_news_icon";
  static const TAG_NEWS_TITLE = "tag_news_title";

  static const ANDROID_DEFAULT_NOTIFICATION_NAME = 'ic_stat_kuas_ap';

  // Notification ID
  static const int NOTIFICATION_BUS_ID = 100;
  static const int NOTIFICATION_COURSE_ID = 101;
  static const int NOTIFICATION_FCM_ID = 200;

  static const FANS_PAGE_ID = '954175941266264';
  static const FANS_PAGE_URL_SCHEME_ANDROID =
      'fb://messaging/${Constants.FANS_PAGE_ID}';
  static const FANS_PAGE_URL_SCHEME_IOS =
      'fb-messenger://user-thread/${Constants.FANS_PAGE_ID}';
  static const FANS_PAGE_URL = 'https://www.facebook.com/$FANS_PAGE_ID/';

  static const DONATE_URL =
      'https://payment.ecpay.com.tw/QuickCollect/PayData?mLM7iy8RpUGk%2fyBotSDMdvI0qGI5ToToqBW%2bOQbOE80%3d';

  static const MAX_IMAGE_SIZE = 1.0;
  static const IMAGE_RESIZE_RATE = 2.5;
}
