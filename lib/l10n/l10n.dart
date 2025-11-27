// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'intl/messages_all_locales.dart' show initializeMessages;

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class AppLocalizations {
  AppLocalizations();

  static AppLocalizations? _current;

  static AppLocalizations get current {
    assert(_current != null,
        'No instance of AppLocalizations was loaded. Try to initialize the AppLocalizations delegate before accessing AppLocalizations.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<AppLocalizations> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = AppLocalizations();
      AppLocalizations._current = instance;

      return instance;
    });
  }

  static AppLocalizations of(BuildContext context) {
    final instance = AppLocalizations.maybeOf(context);
    assert(instance != null,
        'No instance of AppLocalizations present in the widget tree. Did you add AppLocalizations.delegate in localizationsDelegates?');
    return instance!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// `高科校務通`
  String get appName {
    return Intl.message(
      '高科校務通',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `* 修正部分裝置桌面小工具無法顯示`
  String get updateNoteContent {
    return Intl.message(
      '* 修正部分裝置桌面小工具無法顯示',
      name: 'updateNoteContent',
      desc: '',
      args: [],
    );
  }

  /// `https://github.com/NKUST-ITC/NKUST-AP-Flutter\n\n本專案採MIT 開放原始碼授權：\nThe MIT License (MIT)\n\nCopyright © 2021 Rainvisitor\n\nThis project is Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.`
  String get aboutOpenSourceContent {
    return Intl.message(
      'https://github.com/NKUST-ITC/NKUST-AP-Flutter\n\n本專案採MIT 開放原始碼授權：\nThe MIT License (MIT)\n\nCopyright © 2021 Rainvisitor\n\nThis project is Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.',
      name: 'aboutOpenSourceContent',
      desc: '',
      args: [],
    );
  }

  /// `選擇乘車時間：%s`
  String get busPickDate {
    return Intl.message(
      '選擇乘車時間：%s',
      name: 'busPickDate',
      desc: '',
      args: [],
    );
  }

  /// `選擇乘車時間`
  String get busNotPickDate {
    return Intl.message(
      '選擇乘車時間',
      name: 'busNotPickDate',
      desc: '',
      args: [],
    );
  }

  /// `(%s / %s)`
  String get busCount {
    return Intl.message(
      '(%s / %s)',
      name: 'busCount',
      desc: '',
      args: [],
    );
  }

  /// `到燕巢，發車日期：`
  String get busJiangongReservations {
    return Intl.message(
      '到燕巢，發車日期：',
      name: 'busJiangongReservations',
      desc: '',
      args: [],
    );
  }

  /// `到建工，發車日期：`
  String get busYanchaoReservations {
    return Intl.message(
      '到建工，發車日期：',
      name: 'busYanchaoReservations',
      desc: '',
      args: [],
    );
  }

  /// `到燕巢，發車：`
  String get busJiangong {
    return Intl.message(
      '到燕巢，發車：',
      name: 'busJiangong',
      desc: '',
      args: [],
    );
  }

  /// `到建工，發車：`
  String get busYanchao {
    return Intl.message(
      '到建工，發車：',
      name: 'busYanchao',
      desc: '',
      args: [],
    );
  }

  /// `√ 到燕巢，發車：`
  String get busJiangongReserved {
    return Intl.message(
      '√ 到燕巢，發車：',
      name: 'busJiangongReserved',
      desc: '',
      args: [],
    );
  }

  /// `√ 到建工，發車：`
  String get busYanchaoReserved {
    return Intl.message(
      '√ 到建工，發車：',
      name: 'busYanchaoReserved',
      desc: '',
      args: [],
    );
  }

  /// `預定校車`
  String get busReserve {
    return Intl.message(
      '預定校車',
      name: 'busReserve',
      desc: '',
      args: [],
    );
  }

  /// `校車紀錄`
  String get busReservations {
    return Intl.message(
      '校車紀錄',
      name: 'busReservations',
      desc: '',
      args: [],
    );
  }

  /// `校車罰緩`
  String get busViolationRecords {
    return Intl.message(
      '校車罰緩',
      name: 'busViolationRecords',
      desc: '',
      args: [],
    );
  }

  /// `未繳款`
  String get unpaid {
    return Intl.message(
      '未繳款',
      name: 'unpaid',
      desc: '',
      args: [],
    );
  }

  /// `已繳款`
  String get paid {
    return Intl.message(
      '已繳款',
      name: 'paid',
      desc: '',
      args: [],
    );
  }

  /// `取消預定校車`
  String get busCancelReserve {
    return Intl.message(
      '取消預定校車',
      name: 'busCancelReserve',
      desc: '',
      args: [],
    );
  }

  /// `確定要預定本次校車？`
  String get busReserveConfirmTitle {
    return Intl.message(
      '確定要預定本次校車？',
      name: 'busReserveConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `要預定從%s\n%s 的校車嗎？`
  String get busReserveConfirmContent {
    return Intl.message(
      '要預定從%s\n%s 的校車嗎？',
      name: 'busReserveConfirmContent',
      desc: '',
      args: [],
    );
  }

  /// `確定要<b>取消</b>本校車車次？`
  String get busCancelReserveConfirmTitle {
    return Intl.message(
      '確定要<b>取消</b>本校車車次？',
      name: 'busCancelReserveConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `要取消從%s\n%s 的校車嗎？`
  String get busCancelReserveConfirmContent {
    return Intl.message(
      '要取消從%s\n%s 的校車嗎？',
      name: 'busCancelReserveConfirmContent',
      desc: '',
      args: [],
    );
  }

  /// `要取消從`
  String get busCancelReserveConfirmContent1 {
    return Intl.message(
      '要取消從',
      name: 'busCancelReserveConfirmContent1',
      desc: '',
      args: [],
    );
  }

  /// `到`
  String get busCancelReserveConfirmContent2 {
    return Intl.message(
      '到',
      name: 'busCancelReserveConfirmContent2',
      desc: '',
      args: [],
    );
  }

  /// `的校車嗎？`
  String get busCancelReserveConfirmContent3 {
    return Intl.message(
      '的校車嗎？',
      name: 'busCancelReserveConfirmContent3',
      desc: '',
      args: [],
    );
  }

  /// `建工到燕巢`
  String get busFromJiangong {
    return Intl.message(
      '建工到燕巢',
      name: 'busFromJiangong',
      desc: '',
      args: [],
    );
  }

  /// `燕巢到建工`
  String get busFromYanchao {
    return Intl.message(
      '燕巢到建工',
      name: 'busFromYanchao',
      desc: '',
      args: [],
    );
  }

  /// `預約`
  String get reserve {
    return Intl.message(
      '預約',
      name: 'reserve',
      desc: '',
      args: [],
    );
  }

  /// `預約日期`
  String get busReserveDate {
    return Intl.message(
      '預約日期',
      name: 'busReserveDate',
      desc: '',
      args: [],
    );
  }

  /// `上車地點`
  String get busReserveLocation {
    return Intl.message(
      '上車地點',
      name: 'busReserveLocation',
      desc: '',
      args: [],
    );
  }

  /// `預約班次`
  String get busReserveTime {
    return Intl.message(
      '預約班次',
      name: 'busReserveTime',
      desc: '',
      args: [],
    );
  }

  /// `建工`
  String get jiangong {
    return Intl.message(
      '建工',
      name: 'jiangong',
      desc: '',
      args: [],
    );
  }

  /// `燕巢`
  String get yanchao {
    return Intl.message(
      '燕巢',
      name: 'yanchao',
      desc: '',
      args: [],
    );
  }

  /// `第一`
  String get first {
    return Intl.message(
      '第一',
      name: 'first',
      desc: '',
      args: [],
    );
  }

  /// `楠梓`
  String get nanzi {
    return Intl.message(
      '楠梓',
      name: 'nanzi',
      desc: '',
      args: [],
    );
  }

  /// `旗津`
  String get qijin {
    return Intl.message(
      '旗津',
      name: 'qijin',
      desc: '',
      args: [],
    );
  }

  /// `未知`
  String get unknown {
    return Intl.message(
      '未知',
      name: 'unknown',
      desc: '',
      args: [],
    );
  }

  /// `校區`
  String get campus {
    return Intl.message(
      '校區',
      name: 'campus',
      desc: '',
      args: [],
    );
  }

  /// `已預約`
  String get reserved {
    return Intl.message(
      '已預約',
      name: 'reserved',
      desc: '',
      args: [],
    );
  }

  /// `無法預約`
  String get canNotReserve {
    return Intl.message(
      '無法預約',
      name: 'canNotReserve',
      desc: '',
      args: [],
    );
  }

  /// `特殊班次`
  String get specialBus {
    return Intl.message(
      '特殊班次',
      name: 'specialBus',
      desc: '',
      args: [],
    );
  }

  /// `試辦車次`
  String get trialBus {
    return Intl.message(
      '試辦車次',
      name: 'trialBus',
      desc: '',
      args: [],
    );
  }

  /// `預約成功！`
  String get busReserveSuccess {
    return Intl.message(
      '預約成功！',
      name: 'busReserveSuccess',
      desc: '',
      args: [],
    );
  }

  /// `取消日期`
  String get busReserveCancelDate {
    return Intl.message(
      '取消日期',
      name: 'busReserveCancelDate',
      desc: '',
      args: [],
    );
  }

  /// `上車地點`
  String get busReserveCancelLocation {
    return Intl.message(
      '上車地點',
      name: 'busReserveCancelLocation',
      desc: '',
      args: [],
    );
  }

  /// `取消班次`
  String get busReserveCancelTime {
    return Intl.message(
      '取消班次',
      name: 'busReserveCancelTime',
      desc: '',
      args: [],
    );
  }

  /// `取消預約成功！`
  String get busCancelReserveSuccess {
    return Intl.message(
      '取消預約成功！',
      name: 'busCancelReserveSuccess',
      desc: '',
      args: [],
    );
  }

  /// `取消預約失敗`
  String get busCancelReserveFail {
    return Intl.message(
      '取消預約失敗',
      name: 'busCancelReserveFail',
      desc: '',
      args: [],
    );
  }

  /// `Oops！您還沒有預約任何校車喔～\n多多搭乘大眾運輸，節能減碳救地球 😋`
  String get busReservationEmpty {
    return Intl.message(
      'Oops！您還沒有預約任何校車喔～\n多多搭乘大眾運輸，節能減碳救地球 😋',
      name: 'busReservationEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Oops 預約失敗`
  String get busReserveFailTitle {
    return Intl.message(
      'Oops 預約失敗',
      name: 'busReserveFailTitle',
      desc: '',
      args: [],
    );
  }

  /// `我知道了`
  String get iKnow {
    return Intl.message(
      '我知道了',
      name: 'iKnow',
      desc: '',
      args: [],
    );
  }

  /// `Oops！本日校車沒上班喔～\n請選擇其他日期 😋`
  String get busEmpty {
    return Intl.message(
      'Oops！本日校車沒上班喔～\n請選擇其他日期 😋',
      name: 'busEmpty',
      desc: '',
      args: [],
    );
  }

  /// `您尚未選擇日期！\n請先選擇日期 %s`
  String get busNotPick {
    return Intl.message(
      '您尚未選擇日期！\n請先選擇日期 %s',
      name: 'busNotPick',
      desc: '',
      args: [],
    );
  }

  /// `校車預約將於發車前三十分鐘提醒！\n若在網頁預約或取消校車請重登入此App。`
  String get busNotifyHint {
    return Intl.message(
      '校車預約將於發車前三十分鐘提醒！\n若在網頁預約或取消校車請重登入此App。',
      name: 'busNotifyHint',
      desc: '',
      args: [],
    );
  }

  /// `您有一班 %s 從%s出發的校車！`
  String get busNotifyContent {
    return Intl.message(
      '您有一班 %s 從%s出發的校車！',
      name: 'busNotifyContent',
      desc: '',
      args: [],
    );
  }

  /// `建工`
  String get busNotifyJiangong {
    return Intl.message(
      '建工',
      name: 'busNotifyJiangong',
      desc: '',
      args: [],
    );
  }

  /// `燕巢`
  String get busNotifyYanchao {
    return Intl.message(
      '燕巢',
      name: 'busNotifyYanchao',
      desc: '',
      args: [],
    );
  }

  /// `校車提醒`
  String get busNotify {
    return Intl.message(
      '校車提醒',
      name: 'busNotify',
      desc: '',
      args: [],
    );
  }

  /// `發車前三十分鐘提醒`
  String get busNotifySubTitle {
    return Intl.message(
      '發車前三十分鐘提醒',
      name: 'busNotifySubTitle',
      desc: '',
      args: [],
    );
  }

  /// `校車系統`
  String get bus {
    return Intl.message(
      '校車系統',
      name: 'bus',
      desc: '',
      args: [],
    );
  }

  /// `建工上車`
  String get fromJiangong {
    return Intl.message(
      '建工上車',
      name: 'fromJiangong',
      desc: '',
      args: [],
    );
  }

  /// `燕巢上車`
  String get fromYanchao {
    return Intl.message(
      '燕巢上車',
      name: 'fromYanchao',
      desc: '',
      args: [],
    );
  }

  /// `第一上車`
  String get fromFirst {
    return Intl.message(
      '第一上車',
      name: 'fromFirst',
      desc: '',
      args: [],
    );
  }

  /// `目的地`
  String get destination {
    return Intl.message(
      '目的地',
      name: 'destination',
      desc: '',
      args: [],
    );
  }

  /// `預約中...`
  String get reserving {
    return Intl.message(
      '預約中...',
      name: 'reserving',
      desc: '',
      args: [],
    );
  }

  /// `取消中...`
  String get canceling {
    return Intl.message(
      '取消中...',
      name: 'canceling',
      desc: '',
      args: [],
    );
  }

  /// `學校校車系統或許壞掉惹～`
  String get busFailInfinity {
    return Intl.message(
      '學校校車系統或許壞掉惹～',
      name: 'busFailInfinity',
      desc: '',
      args: [],
    );
  }

  /// `預約截止時間`
  String get reserveDeadline {
    return Intl.message(
      '預約截止時間',
      name: 'reserveDeadline',
      desc: '',
      args: [],
    );
  }

  /// `校車搭乘規則`
  String get busRule {
    return Intl.message(
      '校車搭乘規則',
      name: 'busRule',
      desc: '',
      args: [],
    );
  }

  /// `首次登入密碼預設為身分證末四碼`
  String get firstLoginHint {
    return Intl.message(
      '首次登入密碼預設為身分證末四碼',
      name: 'firstLoginHint',
      desc: '',
      args: [],
    );
  }

  /// `姓名：%s\n學號：%s\n`
  String get searchStudentIdFormat {
    return Intl.message(
      '姓名：%s\n學號：%s\n',
      name: 'searchStudentIdFormat',
      desc: '',
      args: [],
    );
  }

  /// `無期限`
  String get noExpiration {
    return Intl.message(
      '無期限',
      name: 'noExpiration',
      desc: '',
      args: [],
    );
  }

  /// `拍照打卡`
  String get punch {
    return Intl.message(
      '拍照打卡',
      name: 'punch',
      desc: '',
      args: [],
    );
  }

  /// `打卡成功`
  String get punchSuccess {
    return Intl.message(
      '打卡成功',
      name: 'punchSuccess',
      desc: '',
      args: [],
    );
  }

  /// `非上課時間`
  String get nonCourseTime {
    return Intl.message(
      '非上課時間',
      name: 'nonCourseTime',
      desc: '',
      args: [],
    );
  }

  /// `離線成績`
  String get offlineScore {
    return Intl.message(
      '離線成績',
      name: 'offlineScore',
      desc: '',
      args: [],
    );
  }

  /// `離線校車紀錄`
  String get offlineBusReservations {
    return Intl.message(
      '離線校車紀錄',
      name: 'offlineBusReservations',
      desc: '',
      args: [],
    );
  }

  /// `離線缺曠資料`
  String get offlineLeaveData {
    return Intl.message(
      '離線缺曠資料',
      name: 'offlineLeaveData',
      desc: '',
      args: [],
    );
  }

  /// `預約校車\n`
  String get busRuleReservationRuleTitle {
    return Intl.message(
      '預約校車\n',
      name: 'busRuleReservationRuleTitle',
      desc: '',
      args: [],
    );
  }

  /// `• 請上 `
  String get busRuleTravelBy {
    return Intl.message(
      '• 請上 ',
      name: 'busRuleTravelBy',
      desc: '',
      args: [],
    );
  }

  /// `• 校車預約系統預約校車\n• 可預約14天以內的校車班次\n• 為配合總務處派車需求預約時間\n`
  String get busRuleFourteenDay {
    return Intl.message(
      '• 校車預約系統預約校車\n• 可預約14天以內的校車班次\n• 為配合總務處派車需求預約時間\n',
      name: 'busRuleFourteenDay',
      desc: '',
      args: [],
    );
  }

  /// `■ 9點以前的班次：請於發車前15個小時預約\n■ 9點以後的班次：請於發車前5個小時預約\n`
  String get busRuleReservationTime {
    return Intl.message(
      '■ 9點以前的班次：請於發車前15個小時預約\n■ 9點以後的班次：請於發車前5個小時預約\n',
      name: 'busRuleReservationTime',
      desc: '',
      args: [],
    );
  }

  /// `• 取消預約時間\n`
  String get busRuleCancellingTitle {
    return Intl.message(
      '• 取消預約時間\n',
      name: 'busRuleCancellingTitle',
      desc: '',
      args: [],
    );
  }

  /// `■ 9點以前的班次：請於發車前15個小時預約\n■ 9點以後的班次：請於發車前5個小時預約\n`
  String get busRuleCancelingTime {
    return Intl.message(
      '■ 9點以前的班次：請於發車前15個小時預約\n■ 9點以後的班次：請於發車前5個小時預約\n',
      name: 'busRuleCancelingTime',
      desc: '',
      args: [],
    );
  }

  /// `• 請全校師生及職員依規定預約校車，若因未預約校車而無法到課或上班者，請自行負責\n`
  String get busRuleFollow {
    return Intl.message(
      '• 請全校師生及職員依規定預約校車，若因未預約校車而無法到課或上班者，請自行負責\n',
      name: 'busRuleFollow',
      desc: '',
      args: [],
    );
  }

  /// `上車\n`
  String get busRuleTakeOn {
    return Intl.message(
      '上車\n',
      name: 'busRuleTakeOn',
      desc: '',
      args: [],
    );
  }

  /// `• 每次上車繳款20元`
  String get busRuleTwentyDollars {
    return Intl.message(
      '• 每次上車繳款20元',
      name: 'busRuleTwentyDollars',
      desc: '',
      args: [],
    );
  }

  /// `（未發卡前先以投幣繳費，請自備20元銅板投幣）\n`
  String get busRulePrepareCoins {
    return Intl.message(
      '（未發卡前先以投幣繳費，請自備20元銅板投幣）\n',
      name: 'busRulePrepareCoins',
      desc: '',
      args: [],
    );
  }

  /// `• 請持學生證或教職員證(未發卡前先採用身分證識別)上車\n`
  String get busRuleIdCard {
    return Intl.message(
      '• 請持學生證或教職員證(未發卡前先採用身分證識別)上車\n',
      name: 'busRuleIdCard',
      desc: '',
      args: [],
    );
  }

  /// `• 未攜帶證件者請排後補區\n`
  String get busRuleNoIdCard {
    return Intl.message(
      '• 未攜帶證件者請排後補區\n',
      name: 'busRuleNoIdCard',
      desc: '',
      args: [],
    );
  }

  /// `• 請依預約的班次時間搭乘(例如：8:20與9:30視為不同班次），未依規定者不得上車，並計違規點數一點\n`
  String get busRuleFollowingTime {
    return Intl.message(
      '• 請依預約的班次時間搭乘(例如：8:20與9:30視為不同班次），未依規定者不得上車，並計違規點數一點\n',
      name: 'busRuleFollowingTime',
      desc: '',
      args: [],
    );
  }

  /// `• 逾時或未預約搭乘者請至候補車道排隊候補上車。\n候補上車\n• 在正常車道上車時未通過驗證者(ex.未預約該班次)，請改至候補車道排隊候補上車。\n• 候補者需等待預約該班次的人全部上車之後才依序遞補上車\n`
  String get busRuleLateAndNoReservation {
    return Intl.message(
      '• 逾時或未預約搭乘者請至候補車道排隊候補上車。\n候補上車\n• 在正常車道上車時未通過驗證者(ex.未預約該班次)，請改至候補車道排隊候補上車。\n• 候補者需等待預約該班次的人全部上車之後才依序遞補上車\n',
      name: 'busRuleLateAndNoReservation',
      desc: '',
      args: [],
    );
  }

  /// `候補上車\n`
  String get busRuleStandbyTitle {
    return Intl.message(
      '候補上車\n',
      name: 'busRuleStandbyTitle',
      desc: '',
      args: [],
    );
  }

  /// `• 未依預約的班次搭乘者，視為違規，計違規點數一次(例如：8:20與9:30視為不同班次）\n• 因教師臨時請假、臨時調課致使需提前或延後搭車，得向開課系所提出申請，並由系所之交通車系統管理者註銷違規紀錄。\n候補上車\n• 在正常車道上車時未通過驗證者(ex.未預約該班次)，請改至候補車道排隊候補上車。\n• 候補者需等待預約該班次的人全部上車之後才依序遞補上車\n`
  String get busRuleStandbyRule {
    return Intl.message(
      '• 未依預約的班次搭乘者，視為違規，計違規點數一次(例如：8:20與9:30視為不同班次）\n• 因教師臨時請假、臨時調課致使需提前或延後搭車，得向開課系所提出申請，並由系所之交通車系統管理者註銷違規紀錄。\n候補上車\n• 在正常車道上車時未通過驗證者(ex.未預約該班次)，請改至候補車道排隊候補上車。\n• 候補者需等待預約該班次的人全部上車之後才依序遞補上車\n',
      name: 'busRuleStandbyRule',
      desc: '',
      args: [],
    );
  }

  /// `罰款\n`
  String get busRuleFineTitle {
    return Intl.message(
      '罰款\n',
      name: 'busRuleFineTitle',
      desc: '',
      args: [],
    );
  }

  /// `• 違規罰款金額計算，違規前三次不計點，從第四次開始違規記點，每點應繳納等同車資之罰款\n• 違規點數統計至學期末為止(上學期學期末1/31，下學期8/31)，新學期違規點數重新計算。當學期罰款未繳清者，次學期停止預約權限至罰款繳清為止\n• 罰款請自行列印違規明細後至自動繳費機或總務處出納組繳費，繳費後憑收據至總務處事務組銷帳(當天開列之收據須於當天銷帳)，銷帳完後隔天凌晨4點後才可預約當天9點後的校車。\n• 罰款點數如有疑義，請於違規發生日起10日內(含星期例假日)逕向總務處事務組確認。\n`
  String get busRuleFineRule {
    return Intl.message(
      '• 違規罰款金額計算，違規前三次不計點，從第四次開始違規記點，每點應繳納等同車資之罰款\n• 違規點數統計至學期末為止(上學期學期末1/31，下學期8/31)，新學期違規點數重新計算。當學期罰款未繳清者，次學期停止預約權限至罰款繳清為止\n• 罰款請自行列印違規明細後至自動繳費機或總務處出納組繳費，繳費後憑收據至總務處事務組銷帳(當天開列之收據須於當天銷帳)，銷帳完後隔天凌晨4點後才可預約當天9點後的校車。\n• 罰款點數如有疑義，請於違規發生日起10日內(含星期例假日)逕向總務處事務組確認。\n',
      name: 'busRuleFineRule',
      desc: '',
      args: [],
    );
  }

  /// `太好了！您沒有任何校車罰緩～`
  String get busViolationRecordEmpty {
    return Intl.message(
      '太好了！您沒有任何校車罰緩～',
      name: 'busViolationRecordEmpty',
      desc: '',
      args: [],
    );
  }

  /// `學校關閉課表 我們暫時無法解決\n任何問題建議與校方反應`
  String get schoolCloseCourseHint {
    return Intl.message(
      '學校關閉課表 我們暫時無法解決\n任何問題建議與校方反應',
      name: 'schoolCloseCourseHint',
      desc: '',
      args: [],
    );
  }

  /// `登入驗證`
  String get loginAuth {
    return Intl.message(
      '登入驗證',
      name: 'loginAuth',
      desc: '',
      args: [],
    );
  }

  /// `點擊看說明`
  String get clickShowDescription {
    return Intl.message(
      '點擊看說明',
      name: 'clickShowDescription',
      desc: '',
      args: [],
    );
  }

  /// `等待網頁完成載入\n將自動填寫學號密碼\n完成機器人驗證後點擊登入\n將自動跳轉`
  String get mobileNkustLoginHint {
    return Intl.message(
      '等待網頁完成載入\n將自動填寫學號密碼\n完成機器人驗證後點擊登入\n將自動跳轉',
      name: 'mobileNkustLoginHint',
      desc: '',
      args: [],
    );
  }

  /// `因應校方關閉原有爬蟲功能，此版本需透過新版手機版校務系統登入。成功登入後會自動跳轉，除非憑證過期，否則極少需要重複驗證，強烈建議將記住我勾選。`
  String get mobileNkustLoginDescription {
    return Intl.message(
      '因應校方關閉原有爬蟲功能，此版本需透過新版手機版校務系統登入。成功登入後會自動跳轉，除非憑證過期，否則極少需要重複驗證，強烈建議將記住我勾選。',
      name: 'mobileNkustLoginDescription',
      desc: '',
      args: [],
    );
  }

  /// `請假查詢`
  String get leaveApplyRecord {
    return Intl.message(
      '請假查詢',
      name: 'leaveApplyRecord',
      desc: '',
      args: [],
    );
  }

  /// `網路問題通報`
  String get reportNetProblem {
    return Intl.message(
      '網路問題通報',
      name: 'reportNetProblem',
      desc: '',
      args: [],
    );
  }

  /// `通報遇到的網路問題(需使用校內信箱登入)`
  String get reportNetProblemSubTitle {
    return Intl.message(
      '通報遇到的網路問題(需使用校內信箱登入)',
      name: 'reportNetProblemSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `問題通報`
  String get reportProblem {
    return Intl.message(
      '問題通報',
      name: 'reportProblem',
      desc: '',
      args: [],
    );
  }

  /// `在學證明`
  String get enrollmentLetter {
    return Intl.message(
      '在學證明',
      name: 'enrollmentLetter',
      desc: '',
      args: [],
    );
  }

  /// `主題色`
  String get themeColor {
    return Intl.message(
      '主題色',
      name: 'themeColor',
      desc: '',
      args: [],
    );
  }

  /// `繁體中文`
  String get traditionalChinese {
    return Intl.message(
      '繁體中文',
      name: 'traditionalChinese',
      desc: '',
      args: [],
    );
  }

  /// `跟隨系統`
  String get followSystem {
    return Intl.message(
      '跟隨系統',
      name: 'followSystem',
      desc: '',
      args: [],
    );
  }

  /// `回報選項`
  String get reportOptions {
    return Intl.message(
      '回報選項',
      name: 'reportOptions',
      desc: '',
      args: [],
    );
  }

  /// `回報 App 問題`
  String get reportAppBug {
    return Intl.message(
      '回報 App 問題',
      name: 'reportAppBug',
      desc: '',
      args: [],
    );
  }

  /// `功能異常、閃退等問題`
  String get reportAppBugSubtitle {
    return Intl.message(
      '功能異常、閃退等問題',
      name: 'reportAppBugSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `功能建議`
  String get featureSuggestion {
    return Intl.message(
      '功能建議',
      name: 'featureSuggestion',
      desc: '',
      args: [],
    );
  }

  /// `提供新功能或改善建議`
  String get featureSuggestionSubtitle {
    return Intl.message(
      '提供新功能或改善建議',
      name: 'featureSuggestionSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `需要幫助嗎？`
  String get needHelp {
    return Intl.message(
      '需要幫助嗎？',
      name: 'needHelp',
      desc: '',
      args: [],
    );
  }

  /// `選擇下方選項來回報問題或提供建議`
  String get selectReportOption {
    return Intl.message(
      '選擇下方選項來回報問題或提供建議',
      name: 'selectReportOption',
      desc: '',
      args: [],
    );
  }

  /// `查詢學號`
  String get searchStudentId {
    return Intl.message(
      '查詢學號',
      name: 'searchStudentId',
      desc: '',
      args: [],
    );
  }

  /// `學生證條碼`
  String get studentIdBarcode {
    return Intl.message(
      '學生證條碼',
      name: 'studentIdBarcode',
      desc: '',
      args: [],
    );
  }

  /// `請於圖書館使用此學號`
  String get useStudentIdInLibrary {
    return Intl.message(
      '請於圖書館使用此學號',
      name: 'useStudentIdInLibrary',
      desc: '',
      args: [],
    );
  }

  /// `點擊登入`
  String get tapToLogin {
    return Intl.message(
      '點擊登入',
      name: 'tapToLogin',
      desc: '',
      args: [],
    );
  }

  /// `高科藍`
  String get nkustBlue {
    return Intl.message(
      '高科藍',
      name: 'nkustBlue',
      desc: '',
      args: [],
    );
  }

  /// `海洋藍`
  String get oceanBlue {
    return Intl.message(
      '海洋藍',
      name: 'oceanBlue',
      desc: '',
      args: [],
    );
  }

  /// `翠綠`
  String get emeraldGreen {
    return Intl.message(
      '翠綠',
      name: 'emeraldGreen',
      desc: '',
      args: [],
    );
  }

  /// `珊瑚橙`
  String get coralOrange {
    return Intl.message(
      '珊瑚橙',
      name: 'coralOrange',
      desc: '',
      args: [],
    );
  }

  /// `典雅紫`
  String get elegantPurple {
    return Intl.message(
      '典雅紫',
      name: 'elegantPurple',
      desc: '',
      args: [],
    );
  }

  /// `玫瑰紅`
  String get roseRed {
    return Intl.message(
      '玫瑰紅',
      name: 'roseRed',
      desc: '',
      args: [],
    );
  }

  /// `青色`
  String get cyan {
    return Intl.message(
      '青色',
      name: 'cyan',
      desc: '',
      args: [],
    );
  }

  /// `琥珀`
  String get amber {
    return Intl.message(
      '琥珀',
      name: 'amber',
      desc: '',
      args: [],
    );
  }

  /// `靛藍`
  String get indigoBlue {
    return Intl.message(
      '靛藍',
      name: 'indigoBlue',
      desc: '',
      args: [],
    );
  }

  /// `棕褐`
  String get brownTan {
    return Intl.message(
      '棕褐',
      name: 'brownTan',
      desc: '',
      args: [],
    );
  }

  /// `自訂色`
  String get customColor {
    return Intl.message(
      '自訂色',
      name: 'customColor',
      desc: '',
      args: [],
    );
  }

  /// `選擇主題色`
  String get selectThemeColor {
    return Intl.message(
      '選擇主題色',
      name: 'selectThemeColor',
      desc: '',
      args: [],
    );
  }

  /// `取消`
  String get cancel {
    return Intl.message(
      '取消',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `確定`
  String get confirm {
    return Intl.message(
      '確定',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `色相`
  String get hue {
    return Intl.message(
      '色相',
      name: 'hue',
      desc: '',
      args: [],
    );
  }

  /// `飽和度`
  String get saturation {
    return Intl.message(
      '飽和度',
      name: 'saturation',
      desc: '',
      args: [],
    );
  }

  /// `亮度`
  String get brightness {
    return Intl.message(
      '亮度',
      name: 'brightness',
      desc: '',
      args: [],
    );
  }

  /// `一`
  String get monday {
    return Intl.message(
      '一',
      name: 'monday',
      desc: '',
      args: [],
    );
  }

  /// `二`
  String get tuesday {
    return Intl.message(
      '二',
      name: 'tuesday',
      desc: '',
      args: [],
    );
  }

  /// `三`
  String get wednesday {
    return Intl.message(
      '三',
      name: 'wednesday',
      desc: '',
      args: [],
    );
  }

  /// `四`
  String get thursday {
    return Intl.message(
      '四',
      name: 'thursday',
      desc: '',
      args: [],
    );
  }

  /// `五`
  String get friday {
    return Intl.message(
      '五',
      name: 'friday',
      desc: '',
      args: [],
    );
  }

  /// `六`
  String get saturday {
    return Intl.message(
      '六',
      name: 'saturday',
      desc: '',
      args: [],
    );
  }

  /// `日`
  String get sunday {
    return Intl.message(
      '日',
      name: 'sunday',
      desc: '',
      args: [],
    );
  }

  /// `節`
  String get period {
    return Intl.message(
      '節',
      name: 'period',
      desc: '',
      args: [],
    );
  }

  /// `授課教師`
  String get instructor {
    return Intl.message(
      '授課教師',
      name: 'instructor',
      desc: '',
      args: [],
    );
  }

  /// `上課地點`
  String get classLocation {
    return Intl.message(
      '上課地點',
      name: 'classLocation',
      desc: '',
      args: [],
    );
  }

  /// `學分數`
  String get credits {
    return Intl.message(
      '學分數',
      name: 'credits',
      desc: '',
      args: [],
    );
  }

  /// `學分`
  String get creditsUnit {
    return Intl.message(
      '學分',
      name: 'creditsUnit',
      desc: '',
      args: [],
    );
  }

  /// `上課時間`
  String get classTime {
    return Intl.message(
      '上課時間',
      name: 'classTime',
      desc: '',
      args: [],
    );
  }

  /// `班級`
  String get className {
    return Intl.message(
      '班級',
      name: 'className',
      desc: '',
      args: [],
    );
  }

  /// `關閉`
  String get close {
    return Intl.message(
      '關閉',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `週`
  String get weekDay {
    return Intl.message(
      '週',
      name: 'weekDay',
      desc: '',
      args: [],
    );
  }

  /// `第%s節`
  String get periodNumber {
    return Intl.message(
      '第%s節',
      name: 'periodNumber',
      desc: '',
      args: [],
    );
  }

  /// `列表模式`
  String get listMode {
    return Intl.message(
      '列表模式',
      name: 'listMode',
      desc: '',
      args: [],
    );
  }

  /// `表格模式`
  String get tableMode {
    return Intl.message(
      '表格模式',
      name: 'tableMode',
      desc: '',
      args: [],
    );
  }

  /// `載入課表中...`
  String get loadingCourse {
    return Intl.message(
      '載入課表中...',
      name: 'loadingCourse',
      desc: '',
      args: [],
    );
  }

  /// `點擊重試`
  String get tapToRetry {
    return Intl.message(
      '點擊重試',
      name: 'tapToRetry',
      desc: '',
      args: [],
    );
  }

  /// `科目詳情`
  String get courseDetails {
    return Intl.message(
      '科目詳情',
      name: 'courseDetails',
      desc: '',
      args: [],
    );
  }

  /// `成績總覽`
  String get scoreOverview {
    return Intl.message(
      '成績總覽',
      name: 'scoreOverview',
      desc: '',
      args: [],
    );
  }

  /// `載入成績中...`
  String get loadingScore {
    return Intl.message(
      '載入成績中...',
      name: 'loadingScore',
      desc: '',
      args: [],
    );
  }

  /// `估計 PR 值`
  String get estimatedPR {
    return Intl.message(
      '估計 PR 值',
      name: 'estimatedPR',
      desc: '',
      args: [],
    );
  }

  /// `※ PR 值為根據平均成績估算，僅供參考`
  String get prDisclaimer {
    return Intl.message(
      '※ PR 值為根據平均成績估算，僅供參考',
      name: 'prDisclaimer',
      desc: '',
      args: [],
    );
  }

  /// `成績統計`
  String get scoreStatistics {
    return Intl.message(
      '成績統計',
      name: 'scoreStatistics',
      desc: '',
      args: [],
    );
  }

  /// `最高分`
  String get highestScore {
    return Intl.message(
      '最高分',
      name: 'highestScore',
      desc: '',
      args: [],
    );
  }

  /// `最低分`
  String get lowestScore {
    return Intl.message(
      '最低分',
      name: 'lowestScore',
      desc: '',
      args: [],
    );
  }

  /// `標準差`
  String get standardDeviation {
    return Intl.message(
      '標準差',
      name: 'standardDeviation',
      desc: '',
      args: [],
    );
  }

  /// `科目數`
  String get subjectCount {
    return Intl.message(
      '科目數',
      name: 'subjectCount',
      desc: '',
      args: [],
    );
  }

  /// `成績分佈`
  String get scoreDistribution {
    return Intl.message(
      '成績分佈',
      name: 'scoreDistribution',
      desc: '',
      args: [],
    );
  }

  /// `優秀`
  String get excellent {
    return Intl.message(
      '優秀',
      name: 'excellent',
      desc: '',
      args: [],
    );
  }

  /// `良好`
  String get good {
    return Intl.message(
      '良好',
      name: 'good',
      desc: '',
      args: [],
    );
  }

  /// `普通`
  String get average {
    return Intl.message(
      '普通',
      name: 'average',
      desc: '',
      args: [],
    );
  }

  /// `及格`
  String get pass {
    return Intl.message(
      '及格',
      name: 'pass',
      desc: '',
      args: [],
    );
  }

  /// `不及格`
  String get fail {
    return Intl.message(
      '不及格',
      name: 'fail',
      desc: '',
      args: [],
    );
  }

  /// `%s 科`
  String get subjectCountUnit {
    return Intl.message(
      '%s 科',
      name: 'subjectCountUnit',
      desc: '',
      args: [],
    );
  }

  /// `學分統計`
  String get creditStatistics {
    return Intl.message(
      '學分統計',
      name: 'creditStatistics',
      desc: '',
      args: [],
    );
  }

  /// `修習學分`
  String get enrolledCredits {
    return Intl.message(
      '修習學分',
      name: 'enrolledCredits',
      desc: '',
      args: [],
    );
  }

  /// `及格學分`
  String get passedCredits {
    return Intl.message(
      '及格學分',
      name: 'passedCredits',
      desc: '',
      args: [],
    );
  }

  /// `不及格學分`
  String get failedCredits {
    return Intl.message(
      '不及格學分',
      name: 'failedCredits',
      desc: '',
      args: [],
    );
  }

  /// `期中: %s`
  String get midtermScore {
    return Intl.message(
      '期中: %s',
      name: 'midtermScore',
      desc: '',
      args: [],
    );
  }

  /// `頂尖`
  String get prTop {
    return Intl.message(
      '頂尖',
      name: 'prTop',
      desc: '',
      args: [],
    );
  }

  /// `優秀`
  String get prExcellent {
    return Intl.message(
      '優秀',
      name: 'prExcellent',
      desc: '',
      args: [],
    );
  }

  /// `中等`
  String get prAverage {
    return Intl.message(
      '中等',
      name: 'prAverage',
      desc: '',
      args: [],
    );
  }

  /// `待加強`
  String get prNeedsImprovement {
    return Intl.message(
      '待加強',
      name: 'prNeedsImprovement',
      desc: '',
      args: [],
    );
  }

  /// `需努力`
  String get prNeedsEffort {
    return Intl.message(
      '需努力',
      name: 'prNeedsEffort',
      desc: '',
      args: [],
    );
  }

  /// `上學期`
  String get firstSemester {
    return Intl.message(
      '上學期',
      name: 'firstSemester',
      desc: '',
      args: [],
    );
  }

  /// `下學期`
  String get secondSemester {
    return Intl.message(
      '下學期',
      name: 'secondSemester',
      desc: '',
      args: [],
    );
  }

  /// `寒修`
  String get winterSession {
    return Intl.message(
      '寒修',
      name: 'winterSession',
      desc: '',
      args: [],
    );
  }

  /// `暑修`
  String get summerSession {
    return Intl.message(
      '暑修',
      name: 'summerSession',
      desc: '',
      args: [],
    );
  }

  /// `先修`
  String get preSemester {
    return Intl.message(
      '先修',
      name: 'preSemester',
      desc: '',
      args: [],
    );
  }

  /// `暑修(一)`
  String get summerSessionOne {
    return Intl.message(
      '暑修(一)',
      name: 'summerSessionOne',
      desc: '',
      args: [],
    );
  }

  /// `暑修(特)`
  String get summerSessionSpecial {
    return Intl.message(
      '暑修(特)',
      name: 'summerSessionSpecial',
      desc: '',
      args: [],
    );
  }

  /// `%s 學年度`
  String get academicYear {
    return Intl.message(
      '%s 學年度',
      name: 'academicYear',
      desc: '',
      args: [],
    );
  }

  /// `載入中`
  String get loading {
    return Intl.message(
      '載入中',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `無資料`
  String get noData {
    return Intl.message(
      '無資料',
      name: 'noData',
      desc: '',
      args: [],
    );
  }

  /// `目前`
  String get currentSemester {
    return Intl.message(
      '目前',
      name: 'currentSemester',
      desc: '',
      args: [],
    );
  }

  /// `查無在學證明資料`
  String get noEnrollmentData {
    return Intl.message(
      '查無在學證明資料',
      name: 'noEnrollmentData',
      desc: '',
      args: [],
    );
  }

  /// `尚無在學證明可下載\n請確認是否已申請在學證明`
  String get noEnrollmentAvailable {
    return Intl.message(
      '尚無在學證明可下載\n請確認是否已申請在學證明',
      name: 'noEnrollmentAvailable',
      desc: '',
      args: [],
    );
  }

  /// `無法取得有效的 PDF 文件`
  String get invalidPdfFormat {
    return Intl.message(
      '無法取得有效的 PDF 文件',
      name: 'invalidPdfFormat',
      desc: '',
      args: [],
    );
  }

  /// `網路錯誤：%s`
  String get networkError {
    return Intl.message(
      '網路錯誤：%s',
      name: 'networkError',
      desc: '',
      args: [],
    );
  }

  /// `載入失敗：%s`
  String get loadFailed {
    return Intl.message(
      '載入失敗：%s',
      name: 'loadFailed',
      desc: '',
      args: [],
    );
  }

  /// `您先前已登入失敗達5次!!請30分鐘後再嘗試登入!!`
  String get loginFailedFiveTimes {
    return Intl.message(
      '您先前已登入失敗達5次!!請30分鐘後再嘗試登入!!',
      name: 'loginFailedFiveTimes',
      desc: '',
      args: [],
    );
  }

  /// `%s 個專案`
  String get projectCount {
    return Intl.message(
      '%s 個專案',
      name: 'projectCount',
      desc: '',
      args: [],
    );
  }

  /// `開源授權`
  String get openSourceLicense {
    return Intl.message(
      '開源授權',
      name: 'openSourceLicense',
      desc: '',
      args: [],
    );
  }

  /// `高雄科技大學`
  String get nkustLocation {
    return Intl.message(
      '高雄科技大學',
      name: 'nkustLocation',
      desc: '',
      args: [],
    );
  }

  /// `其他`
  String get otherBuilding {
    return Intl.message(
      '其他',
      name: 'otherBuilding',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'),
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ja'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
