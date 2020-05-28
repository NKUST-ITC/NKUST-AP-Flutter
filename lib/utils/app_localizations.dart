import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(Locale locale) {
    init(locale);
  }

  String get aboutOpenSourceContent =>
      _vocabularies['about_open_source_content'];

  static init(Locale locale) {
    AppLocalizations.locale = locale;
  }

  static Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'NKUST AP',
      'update_note_content':
          '* New course table UI.\n* Course add to calendar app.\n* Dynamic change theme align system.\n* Fix token expire problem.\n*Course notify can pick particular section.\n*Update school schedule.\n*Classroom coursetalbe Search.\n*Bus Violation Records.',
      'about_open_source_content':
          'https://github.com/NKUST-ITC/NKUST-AP-Flutter\n\nThis project is licensed under the terms of the MIT license:\nThe MIT License (MIT)\n\nCopyright © 2018 Rainvisitor\n\nThis project is Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.',
      'bus_pick_date': 'Chosen Date: %s',
      'bus_not_pick_date': 'Chosen Date',
      'bus_count" formatted="false': '(%s / %s)',
      'bus_jiangong_reservations': 'To YanChao, Scheduled date：',
      'bus_yanchao_reservations': 'To JianGong, Scheduled date：',
      'bus_jiangong': 'To YanChao, Departure time：',
      'bus_yanchao': 'To JianGong, Departure time：',
      'bus_jiangong_reserved': '√ To YanChao, Departure time：',
      'bus_yanchao_reserved': '√ To JianGong, Departure time：',
      'bus_reserve': 'Bus Reservation',
      'bus_reservations': 'Bus Record',
      'bus_violation_records': 'Bus Penalty',
      'unpaid': 'Unpaid',
      'paid': 'Paid',
      'bus_cancel_reserve': 'Cancel Bus Reservation',
      'bus_reserve_confirm_title': 'Reserve this bus?',
      'bus_reserve_confirm_content" formatted="false':
          'Are you sure to reserve a seat from %s at %s ?',
      'bus_cancel_reserve_confirm_title': '<b>Cancel</b> this reservation?',
      'bus_cancel_reserve_confirm_content':
          'Are you sure to cancel a seat from %s at %s ?',
      'bus_cancel_reserve_confirm_content1':
          'Are you sure to cancel a seat from ',
      'bus_cancel_reserve_confirm_content2': ' to ',
      'bus_cancel_reserve_confirm_content3': ' ?',
      'bus_from_jiangong': 'JianGong to YanChao',
      'bus_from_yanchao': 'YanChao to JianGong',
      'bus_reserve_date': 'Date',
      'bus_reserve_location': 'Location',
      'bus_reserve_time': 'Time',
      'jiangong': 'JianGong',
      'yanchao': 'YanChao',
      'first': 'first',
      'nanzi': 'Nanzi',
      'qijin': 'Qijin',
      'reserve': 'Reserve',
      'reserved': 'Reserved',
      'can_not_reserve': 'Can\'t reserve',
      'special_bus': 'Special Bus',
      'trial_bus': 'Trial Bus',
      'bus_reserve_success': 'Successfully Reserved!',
      'bus_reserve_cancel_date': 'Date',
      'bus_reserve_cancel_location': 'Location',
      'bus_reserve_cancel_time': 'Time',
      'bus_cancel_reserve_success': 'Successfully Canceled!',
      'bus_cancel_reserve_fail': 'Fail Canceled',
      'bus_no_reservation':
          'Oops! You haven\'t reserved any bus~\n Ride public transport to save the Earth \uD83D\uDE0B',
      'bus_no_bus':
          'Oops! No bus today~\n Please choose another date \uD83D\uDE0B',
      'bus_not_pick':
          'You have not chosen a date!\n Please choose a date first %s',
      'bus_notify_hint':
          'Reminder will pop up 30 mins before reserved bus !\nIf you reserved or canceled the seat via website, please restart the app.',
      'bus_notify_content" formatted="false':
          'You\'ve got a bus departing at %s from %s!',
      'bus_notify_jiangong': 'JianGong',
      'bus_notify_yanchao': 'YanChao',
      'bus_notify': 'Bus Reservation Reminder',
      'bus_notify_sub_title': 'Reminder 30 mins before reserved bus',
      'bus': 'Bus Reservation',
      'from_jiangong': 'From JianGong',
      'from_yanchao': 'From YanChao',
      'reserving': 'Reserving...',
      'canceling': 'Canceling...',
      'bus_fail_infinity': 'Bus system perhaps broken!!!',
      'reserve_deadline': 'Reserve Deadline',
      'bus_rule': 'Bus Rule',
      'firstLoginHint':
          'For first-time login, please fill in the last four number of your ID as your password',
      'searchStudentIdFormat': 'Name：%s\nStudent ID：%s\n',
      'noExpiration': 'No Expiration',
      'punch': 'Punch',
      'punchSuccess': 'Punch Success',
      'nonCourseTime': 'Non Course Time',
      'offline_score': 'Offline Score',
      'offline_bus_reservations': 'Offline Bus Reservations',
      'offline_leave_data': 'Offline absent Report',
    },
    'zh': {
      'app_name': '高科校務通',
      'update_note_content':
          '* 全新課表介面\n* 課表可加入行事曆App\n* 可隨著系統調整主題\n* 修正憑證過期問題.\n* 上課通知可單選特定課程\n* 更新學校行事曆\n* 教室課表查詢\n* 校車罰緩',
      'about_open_source_content':
          'https://github.com/NKUST-ITC/NKUST-AP-Flutter\n\n本專案採MIT 開放原始碼授權：\nThe MIT License (MIT)\n\nCopyright © 2020 Rainvisitor\n\nThis project is Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.',
      'bus_pick_date': '選擇乘車時間：%s',
      'bus_not_pick_date': '選擇乘車時間',
      'bus_count': '(%s / %s)',
      'bus_jiangong_reservations': '到燕巢，發車日期：',
      'bus_yanchao_reservations': '到建工，發車日期：',
      'bus_jiangong': '到燕巢，發車：',
      'bus_yanchao': '到建工，發車：',
      'bus_jiangong_reserved': '√ 到燕巢，發車：',
      'bus_yanchao_reserved': '√ 到建工，發車：',
      'bus_reserve': '預定校車',
      'bus_reservations': '校車紀錄',
      'bus_violation_records': '校車罰緩',
      'unpaid': '未繳款',
      'paid': '已繳款',
      'bus_cancel_reserve': '取消預定校車',
      'bus_reserve_confirm_title': '確定要預定本次校車？',
      'bus_reserve_confirm_content': '要預定從%s\n%s 的校車嗎？',
      'bus_cancel_reserve_confirm_title': '確定要<b>取消</b>本校車車次？',
      'bus_cancel_reserve_confirm_content': '要取消從%s\n%s 的校車嗎？',
      'bus_cancel_reserve_confirm_content1': '要取消從',
      'bus_cancel_reserve_confirm_content2': '到',
      'bus_cancel_reserve_confirm_content3': '的校車嗎？',
      'bus_from_jiangong': '建工到燕巢',
      'bus_from_yanchao': '燕巢到建工',
      'reserve': '預約',
      'bus_reserve_date': '預約日期',
      'bus_reserve_location': '上車地點',
      'bus_reserve_time': '預約班次',
      'jiangong': '建工',
      'yanchao': '燕巢',
      'first': '第一',
      'nanzi': '楠梓',
      'qijin': '旗津',
      'unknown': '未知',
      'campus': '校區',
      'reserved': '已預約',
      'can_not_reserve': '無法預約',
      'special_bus': '特殊班次',
      'trial_bus': '試辦車次',
      'bus_reserve_success': '預約成功！',
      'bus_reserve_cancel_date': '取消日期',
      'bus_reserve_cancel_location': '上車地點',
      'bus_reserve_cancel_time': '取消班次',
      'bus_cancel_reserve_success': '取消預約成功！',
      'bus_cancel_reserve_fail': '取消預約失敗',
      'bus_no_reservation': 'Oops！您還沒有預約任何校車喔～\n多多搭乘大眾運輸，節能減碳救地球 \uD83D\uDE0B',
      'bus_reserve_fail_title': 'Oops 預約失敗',
      'i_know': '我知道了',
      'bus_no_bus': 'Oops！本日校車沒上班喔～\n請選擇其他日期 \uD83D\uDE0B',
      'bus_not_pick': '您尚未選擇日期！\n請先選擇日期 %s',
      'bus_notify_hint': '校車預約將於發車前三十分鐘提醒！\n若在網頁預約或取消校車請重登入此App。',
      'bus_notify_content': '親，您有一班 %s 從%s出發的校車！',
      'bus_notify_jiangong': '建工',
      'bus_notify_yanchao': '燕巢',
      'bus_notify': '校車提醒',
      'bus_notify_sub_title': '發車前三十分鐘提醒',
      'bus': '校車系統(建工/燕巢)',
      'from_jiangong': '建工上車',
      'from_yanchao': '燕巢上車',
      'reserving': '預約中...',
      'canceling': '取消中...',
      'bus_fail_infinity': '學校校車系統或許壞掉惹～',
      'reserve_deadline': '預約截止時間',
      'bus_rule': '校車搭乘規則',
      'firstLoginHint': '首次登入密碼預設為身分證末四碼',
      'searchStudentIdFormat': '姓名：%s\n學號：%s\n',
      'punch': '拍照打卡',
      'punchSuccess': '打卡成功',
      'nonCourseTime': '非上課時間',
      'offline_score': '離線成績',
      'offline_bus_reservations': '離線校車紀錄',
      'offline_leave_data': '離線缺曠資料',
    },
  };

  Map get _vocabularies {
    return _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  }

  List<String> get busSegment => [
        fromJiangong,
        fromYanchao,
      ];

  List<String> get campuses => [
        jiangong,
        yanchao,
        first,
        nanzi,
        qijin,
      ];

  String get appName => _vocabularies['app_name'];

  String get updateNoteContent => _vocabularies['update_note_content'];

  String get bus => _vocabularies['bus'];

  String get busReserve => _vocabularies['bus_reserve'];

  String get busReservations => _vocabularies['bus_reservations'];

  String get busViolationRecords => _vocabularies['bus_violation_records'];

  String get unpaid => _vocabularies['unpaid'];

  String get paid => _vocabularies['paid'];

  String get jiangong => _vocabularies['jiangong'];

  String get yanchao => _vocabularies['yanchao'];

  String get first => _vocabularies['first'];

  String get nanzi => _vocabularies['nanzi'];

  String get qijin => _vocabularies['qijin'];

  String get unknown => _vocabularies['unknown'];

  String get campus => _vocabularies['campus'];

  String get reserve => _vocabularies['reserve'];

  String get reserved => _vocabularies['reserved'];

  String get canNotReserve => _vocabularies['can_not_reserve'];

  String get specialBus => _vocabularies['special_bus'];

  String get trialBus => _vocabularies['trial_bus'];

  String get busReserveSuccess => _vocabularies['bus_reserve_success'];

  String get busCancelReserve => _vocabularies['bus_cancel_reserve'];

  String get busCancelReserveSuccess =>
      _vocabularies['bus_cancel_reserve_success'];

  String get busCancelReserveFail => _vocabularies['bus_cancel_reserve_fail'];

  String get busReservationEmpty => _vocabularies['bus_no_reservation'];

  String get busEmpty => _vocabularies['bus_no_bus'];

  String get busReserveConfirmTitle =>
      _vocabularies['bus_reserve_confirm_title'];

  String get busReserveFailTitle => _vocabularies['bus_reserve_fail_title'];

  String get busReserveDate => _vocabularies['bus_reserve_date'];

  String get busReserveLocation => _vocabularies['bus_reserve_location'];

  String get busReserveTime => _vocabularies['bus_reserve_time'];

  String get busCancelReserveConfirmContent1 =>
      _vocabularies['bus_cancel_reserve_confirm_content1'];

  String get busCancelReserveConfirmContent2 =>
      _vocabularies['bus_cancel_reserve_confirm_content2'];

  String get busCancelReserveConfirmContent3 =>
      _vocabularies['bus_cancel_reserve_confirm_content3'];

  String get busReserveCancelDate => _vocabularies['bus_reserve_cancel_date'];

  String get busReserveCancelLocation =>
      _vocabularies['bus_reserve_cancel_location'];

  String get busReserveCancelTime => _vocabularies['bus_reserve_cancel_time'];

  String get courseEmpty => _vocabularies['course_no_course'];

  String get picksSemester => _vocabularies['pick_semester'];

  String get fromJiangong => _vocabularies['from_jiangong'];

  String get fromYanchao => _vocabularies['from_yanchao'];

  String get busNotify => _vocabularies['bus_notify'];

  String get busNotifySubTitle => _vocabularies['bus_notify_sub_title'];

  String get busFailInfinity => _vocabularies['bus_fail_infinity'];

  String get reserving => _vocabularies['reserving'];

  String get canceling => _vocabularies['canceling'];

  String get busNotifyHint => _vocabularies['bus_notify_hint'];

  String get busNotifyContent => _vocabularies['bus_notify_content'];

  String get busNotifyJiangong => _vocabularies['bus_notify_jiangong'];

  String get busNotifyYanchao => _vocabularies['bus_notify_yanchao'];

  String get busRule => _vocabularies['bus_rule'];

  String get reserveDeadline => _vocabularies['reserve_deadline'];

  String get offlineScore => _vocabularies['offline_score'];

  String get offlineBusReservations =>
      _vocabularies['offline_bus_reservations'];

  String get offlineLeaveData => _vocabularies['offline_leave_data'];

  String get noData => _vocabularies['noData'];

  String get graduationCheckChecklistSummary =>
      _vocabularies['graduationCheckChecklistSummary'];

  String get firstLoginHint => _vocabularies['firstLoginHint'];

  String get searchStudentIdFormat => _vocabularies['searchStudentIdFormat'];

  String get punch => _vocabularies['punch'];

  String get punchSuccess => _vocabularies['punchSuccess'];

  String get nonCourseTime => _vocabularies['nonCourseTime'];
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

class CupertinoEnDefaultLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const CupertinoEnDefaultLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      DefaultCupertinoLocalizations.load(Locale('zh'));

  @override
  bool shouldReload(CupertinoEnDefaultLocalizationsDelegate old) => false;

  @override
  String toString() => 'DefaultCupertinoLocalizations.delegate(en_US)';
}
