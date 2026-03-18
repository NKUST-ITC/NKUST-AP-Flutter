// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

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
    assert(
      _current != null,
      'No instance of AppLocalizations was loaded. Try to initialize the AppLocalizations delegate before accessing AppLocalizations.current.',
    );
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
    assert(
      instance != null,
      'No instance of AppLocalizations present in the widget tree. Did you add AppLocalizations.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// `高科校務通`
  String get appName {
    return Intl.message('高科校務通', name: 'appName', desc: '', args: []);
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
    return Intl.message('選擇乘車時間：%s', name: 'busPickDate', desc: '', args: []);
  }

  /// `選擇乘車時間`
  String get busNotPickDate {
    return Intl.message('選擇乘車時間', name: 'busNotPickDate', desc: '', args: []);
  }

  /// `(%s / %s)`
  String get busCount {
    return Intl.message('(%s / %s)', name: 'busCount', desc: '', args: []);
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
    return Intl.message('到燕巢，發車：', name: 'busJiangong', desc: '', args: []);
  }

  /// `到建工，發車：`
  String get busYanchao {
    return Intl.message('到建工，發車：', name: 'busYanchao', desc: '', args: []);
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
    return Intl.message('預定校車', name: 'busReserve', desc: '', args: []);
  }

  /// `校車紀錄`
  String get busReservations {
    return Intl.message('校車紀錄', name: 'busReservations', desc: '', args: []);
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
    return Intl.message('未繳款', name: 'unpaid', desc: '', args: []);
  }

  /// `已繳款`
  String get paid {
    return Intl.message('已繳款', name: 'paid', desc: '', args: []);
  }

  /// `取消預定校車`
  String get busCancelReserve {
    return Intl.message('取消預定校車', name: 'busCancelReserve', desc: '', args: []);
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
    return Intl.message('建工到燕巢', name: 'busFromJiangong', desc: '', args: []);
  }

  /// `燕巢到建工`
  String get busFromYanchao {
    return Intl.message('燕巢到建工', name: 'busFromYanchao', desc: '', args: []);
  }

  /// `預約`
  String get reserve {
    return Intl.message('預約', name: 'reserve', desc: '', args: []);
  }

  /// `預約日期`
  String get busReserveDate {
    return Intl.message('預約日期', name: 'busReserveDate', desc: '', args: []);
  }

  /// `上車地點`
  String get busReserveLocation {
    return Intl.message('上車地點', name: 'busReserveLocation', desc: '', args: []);
  }

  /// `預約班次`
  String get busReserveTime {
    return Intl.message('預約班次', name: 'busReserveTime', desc: '', args: []);
  }

  /// `建工`
  String get jiangong {
    return Intl.message('建工', name: 'jiangong', desc: '', args: []);
  }

  /// `燕巢`
  String get yanchao {
    return Intl.message('燕巢', name: 'yanchao', desc: '', args: []);
  }

  /// `第一`
  String get first {
    return Intl.message('第一', name: 'first', desc: '', args: []);
  }

  /// `楠梓`
  String get nanzi {
    return Intl.message('楠梓', name: 'nanzi', desc: '', args: []);
  }

  /// `旗津`
  String get qijin {
    return Intl.message('旗津', name: 'qijin', desc: '', args: []);
  }

  /// `未知`
  String get unknown {
    return Intl.message('未知', name: 'unknown', desc: '', args: []);
  }

  /// `校區`
  String get campus {
    return Intl.message('校區', name: 'campus', desc: '', args: []);
  }

  /// `已預約`
  String get reserved {
    return Intl.message('已預約', name: 'reserved', desc: '', args: []);
  }

  /// `無法預約`
  String get canNotReserve {
    return Intl.message('無法預約', name: 'canNotReserve', desc: '', args: []);
  }

  /// `特殊班次`
  String get specialBus {
    return Intl.message('特殊班次', name: 'specialBus', desc: '', args: []);
  }

  /// `試辦車次`
  String get trialBus {
    return Intl.message('試辦車次', name: 'trialBus', desc: '', args: []);
  }

  /// `預約成功！`
  String get busReserveSuccess {
    return Intl.message('預約成功！', name: 'busReserveSuccess', desc: '', args: []);
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
    return Intl.message('我知道了', name: 'iKnow', desc: '', args: []);
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
    return Intl.message('建工', name: 'busNotifyJiangong', desc: '', args: []);
  }

  /// `燕巢`
  String get busNotifyYanchao {
    return Intl.message('燕巢', name: 'busNotifyYanchao', desc: '', args: []);
  }

  /// `校車提醒`
  String get busNotify {
    return Intl.message('校車提醒', name: 'busNotify', desc: '', args: []);
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
    return Intl.message('校車系統', name: 'bus', desc: '', args: []);
  }

  /// `建工上車`
  String get fromJiangong {
    return Intl.message('建工上車', name: 'fromJiangong', desc: '', args: []);
  }

  /// `燕巢上車`
  String get fromYanchao {
    return Intl.message('燕巢上車', name: 'fromYanchao', desc: '', args: []);
  }

  /// `第一上車`
  String get fromFirst {
    return Intl.message('第一上車', name: 'fromFirst', desc: '', args: []);
  }

  /// `目的地`
  String get destination {
    return Intl.message('目的地', name: 'destination', desc: '', args: []);
  }

  /// `預約中...`
  String get reserving {
    return Intl.message('預約中...', name: 'reserving', desc: '', args: []);
  }

  /// `取消中...`
  String get canceling {
    return Intl.message('取消中...', name: 'canceling', desc: '', args: []);
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
    return Intl.message('預約截止時間', name: 'reserveDeadline', desc: '', args: []);
  }

  /// `校車搭乘規則`
  String get busRule {
    return Intl.message('校車搭乘規則', name: 'busRule', desc: '', args: []);
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

  /// `拍照打卡`
  String get punch {
    return Intl.message('拍照打卡', name: 'punch', desc: '', args: []);
  }

  /// `打卡成功`
  String get punchSuccess {
    return Intl.message('打卡成功', name: 'punchSuccess', desc: '', args: []);
  }

  /// `非上課時間`
  String get nonCourseTime {
    return Intl.message('非上課時間', name: 'nonCourseTime', desc: '', args: []);
  }

  /// `離線成績`
  String get offlineScore {
    return Intl.message('離線成績', name: 'offlineScore', desc: '', args: []);
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
    return Intl.message('離線缺曠資料', name: 'offlineLeaveData', desc: '', args: []);
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
    return Intl.message('• 請上 ', name: 'busRuleTravelBy', desc: '', args: []);
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
    return Intl.message('上車\n', name: 'busRuleTakeOn', desc: '', args: []);
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
    return Intl.message('罰款\n', name: 'busRuleFineTitle', desc: '', args: []);
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
    return Intl.message('登入驗證', name: 'loginAuth', desc: '', args: []);
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
    return Intl.message('請假查詢', name: 'leaveApplyRecord', desc: '', args: []);
  }

  /// `網路問題通報`
  String get reportNetProblem {
    return Intl.message('網路問題通報', name: 'reportNetProblem', desc: '', args: []);
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
    return Intl.message('問題通報', name: 'reportProblem', desc: '', args: []);
  }

  /// `在學證明`
  String get enrollmentLetter {
    return Intl.message('在學證明', name: 'enrollmentLetter', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'),
      Locale.fromSubtags(languageCode: 'en'),
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
