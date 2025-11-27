import 'package:ap_common/ap_common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multiple_localization/multiple_localization.dart';
import 'package:nkust_ap/l10n/intl/messages_all_locales.dart'
    show initializeMessages;
import 'package:nkust_ap/l10n/l10n.dart';

export 'package:nkust_ap/l10n/l10n.dart';

const _AppLocalizationsDelegate appDelegate = _AppLocalizationsDelegate();
const ApLocalizationsDelegateWrapper apLocalizationsDelegateWrapper =
    ApLocalizationsDelegateWrapper();

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return true;
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return MultipleLocalizations.load(
      initializeMessages,
      locale,
      (String l) => AppLocalizations.load(locale),
      setDefaultLocale: true,
    );
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

class ApLocalizationsDelegateWrapper
    extends LocalizationsDelegate<ApLocalizations> {
  const ApLocalizationsDelegateWrapper();

  @override
  bool isSupported(Locale locale) {
    return true;
  }

  @override
  Future<ApLocalizations> load(Locale locale) async {
    if (locale.languageCode == 'ja') {
      final ApLocalizations base =
          await ApLocalizations.delegate.load(const Locale('en'));
      return JapaneseApLocalizations(base);
    }
    final Locale fallbackLocale = ApLocalizations.delegate.isSupported(locale)
        ? locale
        : const Locale('en');
    return ApLocalizations.delegate.load(fallbackLocale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<ApLocalizations> old) {
    return false;
  }
}

/// 日語翻譯包裝器 - 為 ap_common 的 ApLocalizations 提供日語翻譯
/// 使用 noSuchMethod 動態處理所有屬性存取
class JapaneseApLocalizations implements ApLocalizations {
  JapaneseApLocalizations(this._base);

  final ApLocalizations _base;

  /// 日語翻譯對照表
  static const Map<String, String> _translations = <String, String>{
    // 通用
    'about': '情報',
    'settings': '設定',
    'logout': 'ログアウト',
    'login': 'ログイン',
    'course': '時間割',
    'score': '成績',
    'leave': '休暇',
    'schedule': '学年暦',
    'notifications': 'お知らせ',
    'events': 'イベント',
    'news': 'ニュース',
    'home': 'ホーム',
    'more': 'もっと見る',

    // 設定
    'language': '言語',
    'theme': 'テーマ',
    'systemLanguage': 'システムに従う',
    'light': 'ライト',
    'dark': 'ダーク',
    'iconStyle': 'アイコンスタイル',
    'filled': '塗りつぶし',
    'outlined': 'アウトライン',
    'otherInfo': 'その他',
    'feedback': 'フィードバック',
    'feedbackViaFacebook': 'Facebookでフィードバック',
    'appVersion': 'バージョン',

    // 使用者資訊
    'userInfo': 'ユーザー情報',
    'id': '学籍番号',
    'name': '名前',
    'department': '学科',

    // 課表
    'courseInfo': 'コース情報',
    'courseNotify': 'コース通知',
    'courseVibrate': '振動',
    'courseVibrateHint': '授業開始時に振動',
    'courseNotifyHint': '授業開始前に通知',
    'showSectionTime': '時間を表示',
    'showInstructors': '教員を表示',
    'showClassroomLocation': '教室を表示',

    // 成績
    'conductScore': '操行成績',
    'average': '平均',
    'classRank': '順位',
    'percentage': '百分比',
    'credits': '単位',
    'units': '単位',
    'midtermScore': '中間',
    'finalScore': '期末',
    'semesterScore': '学期成績',

    // 請假
    'leaveApply': '休暇申請',
    'leaveRecords': '休暇記録',
    'leaveDateAndSection': '日時',
    'leaveType': 'タイプ',
    'leaveSubmit': '送信',
    'leaveProof': '証明書',
    'date': '日付',

    // 錯誤
    'noData': 'データなし',
    'noInternet': 'ネット接続なし',
    'unknownError': '不明なエラー',
    'clickToRetry': 'タップして再試行',
    'loading': '読み込み中...',

    // 按鈕
    'ok': 'OK',
    'cancel': 'キャンセル',
    'confirm': '確認',
    'delete': '削除',
    'share': '共有',
    'submit': '送信',

    // 學期
    'semester': '学期',

    // 更新
    'updateContent': '更新内容',
    'update': '更新',
    'skip': 'スキップ',

    // 關於
    'donateTitle': '寄付',
    'aboutAuthorTitle': '作成者',
    'aboutRecruitTitle': '募集中',
    'aboutRecruitContent': '開発参加歓迎',

    // 其他
    'offlineMode': 'オフラインモード',
    'loginFirst': 'ログインしてください',
    'functionNotOpen': '準備中',
    'somethingError': 'エラー発生',
    'noOfflineData': 'オフラインデータなし',
    'followSystem': 'システムに従う',

    // 驗證
    'loginFail': 'ログイン失敗',
    'autoLogin': '自動ログイン',
    'password': 'パスワード',
    'captcha': 'キャプチャ',

    // 其他 ap_common 屬性
    'announcementReviewSystem': 'お知らせ管理',
    'bus': 'バス',
    'midtermAlerts': '中間警告',
    'rewardAndPenalty': '賞罰記録',
    'roomList': '教室一覧',
    'schoolInfo': '学校情報',
  };

  /// 動態處理未實作的屬性 - 嘗試翻譯或轉發到基礎類
  dynamic _getProperty(String name) {
    if (_translations.containsKey(name)) {
      return _translations[name];
    }
    // 使用反射取得基礎類的屬性
    try {
      // ignore: avoid_dynamic_calls
      return ((_base as dynamic) as Map<String, dynamic>?)?[name] ??
          _forwardToBase(name);
    } catch (_) {
      return _forwardToBase(name);
    }
  }

  dynamic _forwardToBase(String name) {
    // 直接存取基礎類的屬性
    switch (name) {
      case 'announcementReviewSystem':
        return _base.announcementReviewSystem;
      case 'bus':
        return _base.bus;
      case 'midtermAlerts':
        return _base.midtermAlerts;
      case 'rewardAndPenalty':
        return _base.rewardAndPenalty;
      case 'roomList':
        return _base.roomList;
      case 'schoolInfo':
        return _base.schoolInfo;
      default:
        // 嘗試使用反射存取
        try {
          // ignore: avoid_dynamic_calls
          return (_base as dynamic).__getProperty(name);
        } catch (_) {
          return name; // 回退：返回屬性名稱本身
        }
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) {
      final String name = invocation.memberName
          .toString()
          .replaceAll('Symbol("', '')
          .replaceAll('")', '');
      return _getProperty(name);
    }
    // 對於方法調用，嘗試轉發到基礎類
    try {
      return Function.apply(
        _base.noSuchMethod,
        <dynamic>[invocation],
      );
    } catch (_) {
      return null;
    }
  }

  // 必須實作的屬性 - 使用翻譯或回退到基礎類
  @override
  String get about => _translations['about'] ?? _base.about;
  @override
  String get settings => _translations['settings'] ?? _base.settings;
  @override
  String get logout => _translations['logout'] ?? _base.logout;
  @override
  String get login => _translations['login'] ?? _base.login;
  @override
  String get course => _translations['course'] ?? _base.course;
  @override
  String get score => _translations['score'] ?? _base.score;
  @override
  String get leave => _translations['leave'] ?? _base.leave;
  @override
  String get schedule => _translations['schedule'] ?? _base.schedule;
  @override
  String get notifications =>
      _translations['notifications'] ?? _base.notifications;
  @override
  String get events => _translations['events'] ?? _base.events;
  @override
  String get news => _translations['news'] ?? _base.news;
  @override
  String get language => _translations['language'] ?? _base.language;
  @override
  String get theme => _translations['theme'] ?? _base.theme;
  @override
  String get systemLanguage =>
      _translations['systemLanguage'] ?? _base.systemLanguage;
  @override
  String get light => _translations['light'] ?? _base.light;
  @override
  String get dark => _translations['dark'] ?? _base.dark;
  @override
  String get iconStyle => _translations['iconStyle'] ?? _base.iconStyle;
  @override
  String get filled => _translations['filled'] ?? _base.filled;
  @override
  String get outlined => _translations['outlined'] ?? _base.outlined;
  @override
  String get otherInfo => _translations['otherInfo'] ?? _base.otherInfo;
  @override
  String get feedback => _translations['feedback'] ?? _base.feedback;
  @override
  String get feedbackViaFacebook =>
      _translations['feedbackViaFacebook'] ?? _base.feedbackViaFacebook;
  @override
  String get appVersion => _translations['appVersion'] ?? _base.appVersion;
  @override
  String get userInfo => _translations['userInfo'] ?? _base.userInfo;
  @override
  String get id => _translations['id'] ?? _base.id;
  @override
  String get name => _translations['name'] ?? _base.name;
  @override
  String get department => _translations['department'] ?? _base.department;
  @override
  String get courseInfo => _translations['courseInfo'] ?? _base.courseInfo;
  @override
  String get courseNotify =>
      _translations['courseNotify'] ?? _base.courseNotify;
  @override
  String get courseVibrate =>
      _translations['courseVibrate'] ?? _base.courseVibrate;
  @override
  String get courseVibrateHint =>
      _translations['courseVibrateHint'] ?? _base.courseVibrateHint;
  @override
  String get courseNotifyHint =>
      _translations['courseNotifyHint'] ?? _base.courseNotifyHint;
  @override
  String get showSectionTime =>
      _translations['showSectionTime'] ?? _base.showSectionTime;
  @override
  String get showInstructors =>
      _translations['showInstructors'] ?? _base.showInstructors;
  @override
  String get showClassroomLocation =>
      _translations['showClassroomLocation'] ?? _base.showClassroomLocation;
  @override
  String get conductScore =>
      _translations['conductScore'] ?? _base.conductScore;
  @override
  String get average => _translations['average'] ?? _base.average;
  @override
  String get classRank => _translations['classRank'] ?? _base.classRank;
  @override
  String get percentage => _translations['percentage'] ?? _base.percentage;
  @override
  String get credits => _translations['credits'] ?? _base.credits;
  @override
  String get units => _translations['units'] ?? _base.units;
  @override
  String get midtermScore =>
      _translations['midtermScore'] ?? _base.midtermScore;
  @override
  String get finalScore => _translations['finalScore'] ?? _base.finalScore;
  @override
  String get semesterScore =>
      _translations['semesterScore'] ?? _base.semesterScore;
  @override
  String get leaveApply => _translations['leaveApply'] ?? _base.leaveApply;
  @override
  String get leaveRecords =>
      _translations['leaveRecords'] ?? _base.leaveRecords;
  @override
  String get leaveDateAndSection =>
      _translations['leaveDateAndSection'] ?? _base.leaveDateAndSection;
  @override
  String get leaveType => _translations['leaveType'] ?? _base.leaveType;
  @override
  String get leaveSubmit => _translations['leaveSubmit'] ?? _base.leaveSubmit;
  @override
  String get leaveProof => _translations['leaveProof'] ?? _base.leaveProof;
  @override
  String get date => _translations['date'] ?? _base.date;
  @override
  String get noData => _translations['noData'] ?? _base.noData;
  @override
  String get noInternet => _translations['noInternet'] ?? _base.noInternet;
  @override
  String get unknownError =>
      _translations['unknownError'] ?? _base.unknownError;
  @override
  String get clickToRetry =>
      _translations['clickToRetry'] ?? _base.clickToRetry;
  @override
  String get loading => _translations['loading'] ?? _base.loading;
  @override
  String get ok => _translations['ok'] ?? _base.ok;
  @override
  String get cancel => _translations['cancel'] ?? _base.cancel;
  @override
  String get confirm => _translations['confirm'] ?? _base.confirm;
  @override
  String get delete => _translations['delete'] ?? _base.delete;
  @override
  String get share => _translations['share'] ?? _base.share;
  @override
  String get submit => _translations['submit'] ?? _base.submit;
  @override
  String get semester => _translations['semester'] ?? _base.semester;
  @override
  String get updateContent =>
      _translations['updateContent'] ?? _base.updateContent;
  @override
  String get update => _translations['update'] ?? _base.update;
  @override
  String get skip => _translations['skip'] ?? _base.skip;
  @override
  String get donateTitle => _translations['donateTitle'] ?? _base.donateTitle;
  @override
  String get aboutAuthorTitle =>
      _translations['aboutAuthorTitle'] ?? _base.aboutAuthorTitle;
  @override
  String get aboutRecruitTitle =>
      _translations['aboutRecruitTitle'] ?? _base.aboutRecruitTitle;
  @override
  String get aboutRecruitContent =>
      _translations['aboutRecruitContent'] ?? _base.aboutRecruitContent;
  @override
  String get offlineMode => _translations['offlineMode'] ?? _base.offlineMode;
  @override
  String get loginFirst => _translations['loginFirst'] ?? _base.loginFirst;
  @override
  String get functionNotOpen =>
      _translations['functionNotOpen'] ?? _base.functionNotOpen;
  @override
  String get somethingError =>
      _translations['somethingError'] ?? _base.somethingError;
  @override
  String get noOfflineData =>
      _translations['noOfflineData'] ?? _base.noOfflineData;
  @override
  String get loginFail => _translations['loginFail'] ?? _base.loginFail;
  @override
  String get autoLogin => _translations['autoLogin'] ?? _base.autoLogin;
  @override
  String get password => _translations['password'] ?? _base.password;
  @override
  String get captcha => _translations['captcha'] ?? _base.captcha;

  // 其他必要的 ap_common 屬性
  @override
  String get announcementReviewSystem =>
      _translations['announcementReviewSystem'] ??
      _base.announcementReviewSystem;
  @override
  String get bus => _translations['bus'] ?? _base.bus;
  @override
  String get midtermAlerts =>
      _translations['midtermAlerts'] ?? _base.midtermAlerts;
  @override
  String get rewardAndPenalty =>
      _translations['rewardAndPenalty'] ?? _base.rewardAndPenalty;
  @override
  String get roomList => _translations['roomList'] ?? _base.roomList;
  @override
  String get schoolInfo => _translations['schoolInfo'] ?? _base.schoolInfo;
  @override
  String get home => _translations['home'] ?? _base.home;
}

extension AppLocalizationsExtension on AppLocalizations {
  List<String> get busSegment => <String>[
        fromJiangong,
        fromYanchao,
      ];

  List<String> get campuses => <String>[
        jiangong,
        yanchao,
        first,
        nanzi,
        qijin,
      ];
}
