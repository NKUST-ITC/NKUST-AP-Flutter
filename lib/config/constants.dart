import 'package:encrypt/encrypt.dart';

class Constants {
  static final Key key = Key.fromUtf8('l9r1W3wcsnJTayxCXwoFt62w1i4sQ5J9');
  static final IV iv = IV.fromUtf8('auc9OV5r0nLwjCAH');

  static const String fcmWebVapidKey =
      //ignore: lines_longer_than_80_chars
      'BK0jGtEEyOeBv3H0Q95PtNtYFYNpleRPEKAPP5YLIQIARrNn_X20CFffSrrFarbmsMF3aMVEqjePw5z6GwBWbao';

  static const String prefFirstEnterApp = 'pref_first_enter_app';
  static const String prefCurrentVersion = 'pref_current_version';
  static const String prefRememberPassword = 'pref_remember_password';
  static const String prefAutoLogin = 'pref_auto_login';
  static const String prefUsername = 'pref_username';
  static const String prefPassword = 'pref_password';

  static const String prefCourseNotify = 'pref_course_notify';
  static const String prefBusNotify = 'pref_bus_notify';
  static const String prefCourseNotifyData = 'pref_course_notify_data';
  static const String prefBusNotifyData = 'pref_bus_notify_data';
  static const String prefCourseVibrate = 'pref_course_vibrate';
  static const String prefCourseVibrateData = 'pref_course_vibrate_data';
  static const String prefCourseVibrateUserSetting =
      'pref_course_vibrate_user_setting';
  static const String prefDisplayPicture = 'pref_display_picture';
  static const String prefPictureData = 'pref_picture_data';
  static const String prefScoreData = 'pref_score_data';
  static const String prefCourseData = 'pref_course_data';
  static const String prefLeaveData = 'pref_leave_data';
  static const String prefSemesterData = 'pref_semester_data';
  static const String prefScheduleData = 'pref_schedule_datae';
  static const String prefUserInfo = 'pref_user_info';
  static const String prefBusReservationsData = 'pref_bus_reservevations_data';

  static const String prefLanguageCode = 'pref_language_code';
  static const String prefThemeCode = 'pref_theme_code';
  static const String prefIconStyleCode = 'pref_icon_style_code';
  static const String prefThemeModeIndex = 'pref_theme_mode_index';

  static const String prefApEnable = 'pref_ap_enable';
  static const String prefBusEnable = 'pref_bus_enable';
  static const String prefLeaveEnable = 'pref_leave_enable';

  static const String notificationBusIndexOffset =
      'notification_bus_index_offset';

  static const String prefIsOfflineLogin = 'pref_is_offline_login';

  static const String mobileCookiesData = 'mobile_cookies_data';
  static const String mobileCookiesLastTime = 'mobile_cookies_last_time';

  static const String scheduleData = 'schedule_data';
  static const String schedulePdfUrl = 'schedule_pdf_url';
  static const String androidAppVersion = 'android_app_version';
  static const String iosAppVersion = 'ios_app_version';
  static const String appVersion = 'app_version';
  static const String newVersionContentZh = 'new_version_content_zh';
  static const String newVersionContentEn = 'new_version_content_en';
  static const String apiHost = 'api_host';
  static const String leaveCampusData = 'leave_campus_data';
  static const String leavesTimeCode = 'leaves_time_code';
  static const String crawlerSelector = 'crawler_selector';
  static const String semesterData = 'semester_data';
  static const String mobileNkustUserAgent = 'mobile_nksut_user_agent';
  static const String versionCode = 'version_code';

  static const String tagStudentPicture = 'tag_student_picture';
  static const String tagNewsPicture = 'tag_news_picture';
  static const String tagNewsIcon = 'tag_news_icon';
  static const String tagNewsTitle = 'tag_news_title';

  static const String androidDefaultNotificationName = '@drawable/ic_stat_name';

  // Notification ID
  static const int notificationBusId = 100;
  static const int notificationCourseId = 101;
  static const int notificationFcmId = 200;

  static const String fansPageId = '954175941266264';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.kuas.ap&hl=zh_TW';

  static const String donateUrl =
      'https://payment.ecpay.com.tw/QuickCollect/PayData?mLM7iy8RpUGk%2fyBotSDMdvI0qGI5ToToqBW%2bOQbOE80%3d';

  static const double maxImageSize = 1.0;
  static const double imageResizeRate = 2.5;

  // Crawler config
  static const int timeoutMs = 5000;

  static const String canUseBus = 'can_use_bus';
  static const String hasBusViolation = 'has_bus_violation';

  static const String mailDomain = '@nkust.edu.tw';

  static const String busEnable = 'bus_enable';
  static const String leaveEnable = 'leave_enable';
}
