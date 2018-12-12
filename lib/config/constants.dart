class Constants {
  static bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  static const PREF_FIRST_ENTER_APP = "pref_first_enter_app";
  static const PREF_REMEMBER_PASSWORD = "pref_remember_password";
  static const PREF_USERNAME = "pref_username";
  static const PREF_PASSWORD = "pref_password";
  static const PREF_NOTIFY_COURSE = "pref_notify_course";
  static const PREF_NOTIFY_BUS = "pref_notify_bus";
  static const PREF_DISPLAY_PICTURE = "pref_display_picture";
  static const PREF_VIBRATE_COURSE = "pref_vibrate_course";

  static const SCHEDULE_DATA = "schedule_data";

  static const TAG_STUDENT_PICTURE = "student_picture";
}
