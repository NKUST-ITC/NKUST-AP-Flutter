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
      'about_detail': '',
      'about_author_title': 'Made by',
      'about_author_content':
          '呂紹榕(Louie Lu), 姜尚德(JohnThunder), \nregisterAutumn, 詹濬鍵(Evans), \n陳建霖(HearSilent)\n房志剛(Rainvisitor), 方毅恆(VN7)',
      'about_us':
          '“Ask not why nobody is doing this. You are \'nobody\'.”\n\nWe did this cause no one did it.\nWe created KUAS Wifi Login, KUASAP and KUAS Gourmet, Course Selection Sim, etc&#8230;\nTo bring convenience to everyone\'s on campus!',
      'about_recruit_title': 'We Need You !',
      'about_recruit_content':
          'If you\'re experienced in Objective-C, Swift, Java or you\'re interested in Coding!\n\nMessage us at our Facebook fanpage!\nYour code might one day be operating in everyone\'s hands~',
      'about_itc_content':
          'In year 2014,\nwe founded KUAS Information Technology Club!\n\nIf you\'re enthusiastic or drawn to our projects, join our classes and talks or come by to chat!',
      'about_itc_title': 'KUAS IT Club',
      'about_contact_us': 'Contact Us',
      'about_open_source_title': 'Open Source License',
      'about_open_source_content':
          'https://github.com/abc873693/NKUST-AP-Flutterl\n\nThis project is licensed under the terms of the MIT license:\nThe MIT License (MIT)\n\nCopyright &#169; 2018 Rainvisitor\n\nThis project is Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'
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
      'about_author_title': '作者群',
      'about_author_content':
          '呂紹榕(Louie Lu), 姜尚德(JohnThunder), \nregisterAutumn, 詹濬鍵(Evans), \n陳建霖(HearSilent)\n房志剛(Rainvisitor), 方毅恆(VN7)',
      'about_us':
          '「不要問為何沒有人做這個，\n先承認你就是『沒有人』」。\n因為，「沒有人」是萬能的。\n\n因為沒有人做這些，所以我們跳下來做。\n先後完成了高應無線通、高應校務通，到後來的高應美食通、模擬選課等等.......\n無非是希望帶給大家更便利的校園生活！',
      'about_recruit_title': 'We Need You !',
      'about_recruit_content':
          '如果你是 Objective-C、Swift 高手，或是 Java 神手，又或是對 Coding充滿著熱誠！\n\n歡迎私訊我們粉絲專頁！\n你的程式碼將有機會出現在周遭同學的手中～',
      'about_itc_content':
          '在103學年度，\n我們也成立了高應大資訊研習社！\n\n如果你對資訊有熱誠或是對我們作品有興趣，歡迎來社課或是講座，也可以來找我們聊聊天。',
      'about_itc_title': '高應資研社',
      'about_contact_us': '聯繫我們',
      'about_open_source_title': '開放原始碼授權',
      'about_open_source_content':
          'https://github.com/abc873693/NKUST-AP-Flutterl\n\n本專案採MIT 開放原始碼授權：\nThe MIT License (MIT)\n\nCopyright &#169; 2018 Rainvisitor\n\nThis project is Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'
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

  String get aboutAuthorTitle => _vocabularies['about_author_title'];

  String get aboutAuthorContent => _vocabularies['about_author_content'];

  String get aboutUsContent => _vocabularies['about_us'];

  String get aboutRecruitTitle => _vocabularies['about_recruit_title'];

  String get aboutRecruitContent => _vocabularies['about_recruit_content'];

  String get aboutItcTitle => _vocabularies['about_itc_title'];

  String get aboutItcContent => _vocabularies['about_itc_content'];

  String get aboutContactUsTitle => _vocabularies['about_contact_us'];

  String get aboutOpenSourceTitle => _vocabularies['about_open_source_title'];

  String get aboutOpenSourceContent =>
      _vocabularies['about_open_source_content'];
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
