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
          'Beta Testing\n* New course table UI.\n* Course add to calendar app.\n* Dynamic change theme align system.\n* Fix token expire problem.\n*Course notify can pick particular section.\n*Update school schedule.\n*Classroom coursetalbe Search.',
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
      'bus_title' : 'Bus Reservation\n',
      'please'  : '• Go to ',
      'busRule1' : " Bus Reservation System can reserve bus in 14 days\n" + "in need to follow office of general affairs's time requirement\n",
      'busRule2' : '■ The classes before 9 A.M.：Please do resevation in 15 hours ago.\n' '■ The classes after 9 A.M.：Please do resevation in 5 hours ago\n',
      'busRule3' : '• Cancelation Time\n',
      'busRule4' : '■ The classes before 9 A.M.：Please do calcelation in 15 hours ago.\n' '■ The classes after 9 A.M.：Please do calcelation in 5 hours ago\n',
      'busRule5' : 'Take Bus\n',
      'busRule6' : '• Every time take bus need pay 20 NTD',
      'busRule7' : '（Use coin when you don\'t got Student ID，Please prepare 20 dollars coin first.）\n',
      'busRule8' : "• Please take your student or staff ID(Before you get student or staff ID, Please use your ID) take bus\n",
      'busRule9' : '• If you don\'t take any ID, please line up standby zone\n',
      'busRule10' : 'Please follow the bus schedule (ex. 8:20 and 9:30 is different class), People can\'t take bus and get violation point who don\t follow rule.\n',
      'busRule11' : "• Late or don't reserved passenger, please line up standby zone waiting.\n" +
          "Standby\n" +
          "• If you can't pass verification(ex. Don't reserved)，Please change to standby zone waiting.\n" +
          "• Standby passenger can get on the bus in order after waiting all reserved passangers got on the bus.\n" ,
      'busRule12' : "Standby\n",
      'busRule13' : "• If you don't take the bus but you reserved already，It's a violation，and you get a violation point(ex. 8:20 and 9:30 is different class\n" +
          "• If your class teacher take temporary leave、transfer cause you need take the bus early or lately，you need apply to class department then，deparment bus system administator will logout violation.\n",
      'busRule14' : "Fine\n",
      'busRule15' : "• Fine Calculation，violation times below 3 times don't get point, From 4th violation begin recording point，every point should be pay off fine equal to bus fare.\n" +
          "• Violation point recording until the end of the semester(1st Semester ended at 1/31，2nd Semester ended at 8/31)，violation point will restart recording. When you not paid off fine，next semester will stop your reservation right until you pay off fine.\n" +
          "• Go to the auto payment machine or Office of General Affairs cashier pay off fine after you print violation statement by yourself, After paid off, go to Office of General Affairs General Affairs Division write off payment by receipt(Write off payment need receipt on the day.)，After write off and the next day 4A.M. will be reserve class after 9.A.M..\n" +
          "• If you have any suspicion about violation point，please go to Office of General Affairs General Affairs Division check violation directly in 10 days(included holidays).\n",
    },
    'zh': {
      'app_name': '高科校務通',
      'update_note_content':
          'Beta 測試中\n* 全新課表介面\n* 課表可加入行事曆App\n* 可隨著系統調整主題\n* 修正憑證過期問題.\n*上課通知可單選特定課程\n*更新學校行事曆\n*教室課表查詢',
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
      'bus_title' : '預約校車\n',
      'please'  : '• 請上 ',
      'busRule1' : " 校車預約系統預約校車\n" + "• 可預約14天以內的校車班次\n" + "• 為配合總務處派車需求預約時間\n",
      'busRule2' : '■ 9點以前的班次：請於發車前15個小時預約\n' '■ 9點以後的班次：請於發車前5個小時預約\n',
      'busRule3' : '• 取消預約時間\n',
      'busRule4': '■ 9點以前的班次：請於發車前15個小時預約\n' '■ 9點以後的班次：請於發車前5個小時預約\n',
      'busRule5' : '上車\n',
      'busRule6' :  "• 每次上車繳款20元",
      'busRule7' : '（未發卡前先以投幣繳費，請自備20元銅板投幣）\n',
      'busRule8' : "• 請持學生證或教職員證(未發卡前先採用身分證識別)上車\n",
      'busRule9' : '• 未攜帶證件者請排後補區\n',
      'busRule10' : '• 請依預約的班次時間搭乘(例如：8:20與9:30視為不同班次），未依規定者不得上車，並計違規點數一點\n',
      'busRule11' :"• 逾時或未預約搭乘者請至候補車道排隊候補上車。\n" +
                   "候補上車\n" +
                   "• 在正常車道上車時未通過驗證者(ex.未預約該班次)，請改至候補車道排隊候補上車。\n" +
                   "• 候補者需等待預約該班次的人全部上車之後才依序遞補上車\n" ,
      'busRule12' : "候補上車\n",
      'busRule13' : "• 未依預約的班次搭乘者，視為違規，計違規點數一次(例如：8:20與9:30視為不同班次）\n" +
                    "• 因教師臨時請假、臨時調課致使需提前或延後搭車，得向開課系所提出申請，並由系所之交通車系統管理者註銷違規紀錄。\n",
      'busRule14' : "罰款\n",
      'busRule15' : "• 違規罰款金額計算，違規前三次不計點，從第四次開始違規記點，每點應繳納等同車資之罰款\n" +
          "• 違規點數統計至學期末為止(上學期學期末1/31，下學期8/31)，新學期違規點數重新計算。當學期罰款未繳清者，次學期停止預約權限至罰款繳清為止\n" +
          "• 罰款請自行列印違規明細後至自動繳費機或總務處出納組繳費，繳費後憑收據至總務處事務組銷帳(當天開列之收據須於當天銷帳)，銷帳完後隔天凌晨4點後才可預約當天9點後的校車。\n" +
          "• 罰款點數如有疑義，請於違規發生日起10日內(含星期例假日)逕向總務處事務組確認。\n",
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

  String get busTitle => _vocabularies['bus_title'];

  String get please => _vocabularies['please'];

  String get busRule1 => _vocabularies['busRule1'];

  String get busRule2 => _vocabularies['busRule2'];

  String get busRule3 => _vocabularies['busRule3'];

  String get busRule4 => _vocabularies['busRule4'];

  String get busRule5 => _vocabularies['busRule5'];

  String get busRule6 => _vocabularies['busRule6'];

  String get busRule7 => _vocabularies['busRule7'];

  String get busRule8 => _vocabularies['busRule8'];

  String get busRule9 => _vocabularies['busRule9'];

  String get busRule10 => _vocabularies['busRule10'];

  String get busRule11 => _vocabularies['busRule11'];

  String get busRule12 => _vocabularies['busRule12'];

  String get busRule13 => _vocabularies['busRule13'];

  String get busRule14 => _vocabularies['busRule14'];

  String get busRule15 => _vocabularies['busRule15'];
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
