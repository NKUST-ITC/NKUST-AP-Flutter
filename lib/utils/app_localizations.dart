import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(Locale locale) {
    init(locale);
  }

  static init(Locale locale) {
    AppLocalizations.locale = locale;
  }

  static Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'NKUST AP',
      'username': 'Student ID',
      'password': 'Password',
      'remember_password': 'remember password',
      'login': 'Login',
      'do_not_empty': 'Don\'t Empty',
      'login_fail': 'student id or password error',
      'bus': 'Bus',
      'course': 'Class Schedule',
      'score': 'Report Card',
      'login_ing': 'logining...',
      'school_info': 'School Info',
      'about': 'About Us',
      'settings': 'Settings',
      'notifications': 'News',
      'phones': 'Tel no.',
      'events': 'Events',
      'click_to_retry': 'An error occurred, click to retry',
    },
    'zh': {
      'title': '高科校務通',
      'username': '學號',
      'password': '密碼',
      'remember_password': '記住密碼',
      'login': '登入',
      'do_not_empty': '請勿留空',
      'login_fail': '帳號或密碼錯誤',
      'bus': '校車系統',
      'course': '學期課表',
      'score': '學期成績',
      'login_ing': '登入中...',
      'school_info': '校園資訊',
      'about': '關於我們',
      'settings': '設定',
      'notifications': '最新消息',
      'phones': '常用電話',
      'events': '行事曆',
      'click_to_retry': '發生錯誤，點擊重試',
    },
  };

  Map get _vocabularies => _localizedValues[locale.languageCode];

  Map get messages => {
        0: notifications,
        1: phones,
        2: events,
      };

  String get title => _vocabularies['title'];

  String get username => _vocabularies['username'];

  String get password => _vocabularies['password'];

  String get remember => _vocabularies['remember_password'];

  String get login => _vocabularies['login'];

  String get doNotEmpty => _vocabularies['do_not_empty'];

  String get loginFail => _vocabularies['login_fail'];

  String get bus => _vocabularies['bus'];

  String get course => _vocabularies['course'];

  String get score => _vocabularies['score'];

  String get logining => _vocabularies['login_ing'];

  String get schoolInfo => _vocabularies['school_info'];

  String get about => _vocabularies['about'];

  String get settings => _vocabularies['settings'];

  String get notifications => _vocabularies['notifications'];

  String get phones => _vocabularies['phones'];

  String get events => _vocabularies['events'];

  String get clickToRetry => _vocabularies['click_to_retry'];
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = new AppLocalizations(locale);

    print("Load ${locale.languageCode}");

    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
