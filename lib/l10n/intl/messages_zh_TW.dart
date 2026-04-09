// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_TW locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh_TW';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aboutOpenSourceContent": MessageLookupByLibrary.simpleMessage(
      "https://github.com/NKUST-ITC/NKUST-AP-Flutter\n\n本專案採MIT 開放原始碼授權：\nThe MIT License (MIT)\n\nCopyright © 2021 Rainvisitor\n\nThis project is Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("高科校務通"),
    "bus": MessageLookupByLibrary.simpleMessage("校車系統"),
    "busCancelReserve": MessageLookupByLibrary.simpleMessage("取消預定校車"),
    "busCancelReserveConfirmContent": MessageLookupByLibrary.simpleMessage(
      "要取消從%s\n%s 的校車嗎？",
    ),
    "busCancelReserveConfirmContent1": MessageLookupByLibrary.simpleMessage(
      "要取消從",
    ),
    "busCancelReserveConfirmContent2": MessageLookupByLibrary.simpleMessage(
      "到",
    ),
    "busCancelReserveConfirmContent3": MessageLookupByLibrary.simpleMessage(
      "的校車嗎？",
    ),
    "busCancelReserveConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "確定要<b>取消</b>本校車車次？",
    ),
    "busCancelReserveFail": MessageLookupByLibrary.simpleMessage("取消預約失敗"),
    "busCancelReserveSuccess": MessageLookupByLibrary.simpleMessage("取消預約成功！"),
    "busCount": MessageLookupByLibrary.simpleMessage("(%s / %s)"),
    "busEmpty": MessageLookupByLibrary.simpleMessage(
      "Oops！本日校車沒上班喔～\n請選擇其他日期 😋",
    ),
    "busFailInfinity": MessageLookupByLibrary.simpleMessage("學校校車系統或許壞掉惹～"),
    "busFromJiangong": MessageLookupByLibrary.simpleMessage("建工到燕巢"),
    "busFromYanchao": MessageLookupByLibrary.simpleMessage("燕巢到建工"),
    "busJiangong": MessageLookupByLibrary.simpleMessage("到燕巢，發車："),
    "busJiangongReservations": MessageLookupByLibrary.simpleMessage(
      "到燕巢，發車日期：",
    ),
    "busJiangongReserved": MessageLookupByLibrary.simpleMessage("√ 到燕巢，發車："),
    "busNotPick": MessageLookupByLibrary.simpleMessage("您尚未選擇日期！\n請先選擇日期 %s"),
    "busNotPickDate": MessageLookupByLibrary.simpleMessage("選擇乘車時間"),
    "busNotify": MessageLookupByLibrary.simpleMessage("校車提醒"),
    "busNotifyContent": MessageLookupByLibrary.simpleMessage(
      "您有一班 %s 從%s出發的校車！",
    ),
    "busNotifyHint": MessageLookupByLibrary.simpleMessage(
      "校車預約將於發車前三十分鐘提醒！\n若在網頁預約或取消校車請重登入此App。",
    ),
    "busNotifyJiangong": MessageLookupByLibrary.simpleMessage("建工"),
    "busNotifySubTitle": MessageLookupByLibrary.simpleMessage("發車前三十分鐘提醒"),
    "busNotifyYanchao": MessageLookupByLibrary.simpleMessage("燕巢"),
    "busPickDate": MessageLookupByLibrary.simpleMessage("選擇乘車時間：%s"),
    "busReservationEmpty": MessageLookupByLibrary.simpleMessage(
      "Oops！您還沒有預約任何校車喔～\n多多搭乘大眾運輸，節能減碳救地球 😋",
    ),
    "busReservations": MessageLookupByLibrary.simpleMessage("校車紀錄"),
    "busReserve": MessageLookupByLibrary.simpleMessage("預定校車"),
    "busReserveCancelDate": MessageLookupByLibrary.simpleMessage("取消日期"),
    "busReserveCancelLocation": MessageLookupByLibrary.simpleMessage("上車地點"),
    "busReserveCancelTime": MessageLookupByLibrary.simpleMessage("取消班次"),
    "busReserveConfirmContent": MessageLookupByLibrary.simpleMessage(
      "要預定從%s\n%s 的校車嗎？",
    ),
    "busReserveConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "確定要預定本次校車？",
    ),
    "busReserveDate": MessageLookupByLibrary.simpleMessage("預約日期"),
    "busReserveFailTitle": MessageLookupByLibrary.simpleMessage("Oops 預約失敗"),
    "busReserveLocation": MessageLookupByLibrary.simpleMessage("上車地點"),
    "busReserveSuccess": MessageLookupByLibrary.simpleMessage("預約成功！"),
    "busReserveTime": MessageLookupByLibrary.simpleMessage("預約班次"),
    "busRule": MessageLookupByLibrary.simpleMessage("校車搭乘規則"),
    "busRuleCancelingTime": MessageLookupByLibrary.simpleMessage(
      "■ 9點以前的班次：請於發車前15個小時預約\n■ 9點以後的班次：請於發車前5個小時預約\n",
    ),
    "busRuleCancellingTitle": MessageLookupByLibrary.simpleMessage(
      "• 取消預約時間\n",
    ),
    "busRuleFineRule": MessageLookupByLibrary.simpleMessage(
      "• 違規罰款金額計算，違規前三次不計點，從第四次開始違規記點，每點應繳納等同車資之罰款\n• 違規點數統計至學期末為止(上學期學期末1/31，下學期8/31)，新學期違規點數重新計算。當學期罰款未繳清者，次學期停止預約權限至罰款繳清為止\n• 罰款請自行列印違規明細後至自動繳費機或總務處出納組繳費，繳費後憑收據至總務處事務組銷帳(當天開列之收據須於當天銷帳)，銷帳完後隔天凌晨4點後才可預約當天9點後的校車。\n• 罰款點數如有疑義，請於違規發生日起10日內(含星期例假日)逕向總務處事務組確認。\n",
    ),
    "busRuleFineTitle": MessageLookupByLibrary.simpleMessage("罰款\n"),
    "busRuleFollow": MessageLookupByLibrary.simpleMessage(
      "• 請全校師生及職員依規定預約校車，若因未預約校車而無法到課或上班者，請自行負責\n",
    ),
    "busRuleFollowingTime": MessageLookupByLibrary.simpleMessage(
      "• 請依預約的班次時間搭乘(例如：8:20與9:30視為不同班次），未依規定者不得上車，並計違規點數一點\n",
    ),
    "busRuleFourteenDay": MessageLookupByLibrary.simpleMessage(
      "• 校車預約系統預約校車\n• 可預約14天以內的校車班次\n• 為配合總務處派車需求預約時間\n",
    ),
    "busRuleIdCard": MessageLookupByLibrary.simpleMessage(
      "• 請持學生證或教職員證(未發卡前先採用身分證識別)上車\n",
    ),
    "busRuleLateAndNoReservation": MessageLookupByLibrary.simpleMessage(
      "• 逾時或未預約搭乘者請至候補車道排隊候補上車。\n候補上車\n• 在正常車道上車時未通過驗證者(ex.未預約該班次)，請改至候補車道排隊候補上車。\n• 候補者需等待預約該班次的人全部上車之後才依序遞補上車\n",
    ),
    "busRuleNoIdCard": MessageLookupByLibrary.simpleMessage("• 未攜帶證件者請排後補區\n"),
    "busRulePrepareCoins": MessageLookupByLibrary.simpleMessage(
      "（未發卡前先以投幣繳費，請自備20元銅板投幣）\n",
    ),
    "busRuleReservationRuleTitle": MessageLookupByLibrary.simpleMessage(
      "預約校車\n",
    ),
    "busRuleReservationTime": MessageLookupByLibrary.simpleMessage(
      "■ 9點以前的班次：請於發車前15個小時預約\n■ 9點以後的班次：請於發車前5個小時預約\n",
    ),
    "busRuleStandbyRule": MessageLookupByLibrary.simpleMessage(
      "• 未依預約的班次搭乘者，視為違規，計違規點數一次(例如：8:20與9:30視為不同班次）\n• 因教師臨時請假、臨時調課致使需提前或延後搭車，得向開課系所提出申請，並由系所之交通車系統管理者註銷違規紀錄。\n候補上車\n• 在正常車道上車時未通過驗證者(ex.未預約該班次)，請改至候補車道排隊候補上車。\n• 候補者需等待預約該班次的人全部上車之後才依序遞補上車\n",
    ),
    "busRuleStandbyTitle": MessageLookupByLibrary.simpleMessage("候補上車\n"),
    "busRuleTakeOn": MessageLookupByLibrary.simpleMessage("上車\n"),
    "busRuleTravelBy": MessageLookupByLibrary.simpleMessage("• 請上 "),
    "busRuleTwentyDollars": MessageLookupByLibrary.simpleMessage("• 每次上車繳款20元"),
    "busViolationRecordEmpty": MessageLookupByLibrary.simpleMessage(
      "太好了！您沒有任何校車罰緩～",
    ),
    "busViolationRecords": MessageLookupByLibrary.simpleMessage("校車罰緩"),
    "busYanchao": MessageLookupByLibrary.simpleMessage("到建工，發車："),
    "busYanchaoReservations": MessageLookupByLibrary.simpleMessage("到建工，發車日期："),
    "busYanchaoReserved": MessageLookupByLibrary.simpleMessage("√ 到建工，發車："),
    "campus": MessageLookupByLibrary.simpleMessage("校區"),
    "canNotReserve": MessageLookupByLibrary.simpleMessage("無法預約"),
    "canceling": MessageLookupByLibrary.simpleMessage("取消中..."),
    "clickShowDescription": MessageLookupByLibrary.simpleMessage("點擊看說明"),
    "destination": MessageLookupByLibrary.simpleMessage("目的地"),
    "enrollmentLetter": MessageLookupByLibrary.simpleMessage("在學證明"),
    "first": MessageLookupByLibrary.simpleMessage("第一"),
    "firstLoginHint": MessageLookupByLibrary.simpleMessage("首次登入密碼預設為身分證末四碼"),
    "fromFirst": MessageLookupByLibrary.simpleMessage("第一上車"),
    "fromJiangong": MessageLookupByLibrary.simpleMessage("建工上車"),
    "fromYanchao": MessageLookupByLibrary.simpleMessage("燕巢上車"),
    "iKnow": MessageLookupByLibrary.simpleMessage("我知道了"),
    "jiangong": MessageLookupByLibrary.simpleMessage("建工"),
    "leaveApplyRecord": MessageLookupByLibrary.simpleMessage("請假查詢"),
    "loginAuth": MessageLookupByLibrary.simpleMessage("登入驗證"),
    "mobileNkustLoginDescription": MessageLookupByLibrary.simpleMessage(
      "因應校方關閉原有爬蟲功能，此版本需透過新版手機版校務系統登入。成功登入後會自動跳轉，除非憑證過期，否則極少需要重複驗證，強烈建議將記住我勾選。",
    ),
    "mobileNkustLoginHint": MessageLookupByLibrary.simpleMessage(
      "等待網頁完成載入\n將自動填寫學號密碼\n完成機器人驗證後點擊登入\n將自動跳轉",
    ),
    "nanzi": MessageLookupByLibrary.simpleMessage("楠梓"),
    "nonCourseTime": MessageLookupByLibrary.simpleMessage("非上課時間"),
    "offlineBusReservations": MessageLookupByLibrary.simpleMessage("離線校車紀錄"),
    "offlineLeaveData": MessageLookupByLibrary.simpleMessage("離線缺曠資料"),
    "offlineScore": MessageLookupByLibrary.simpleMessage("離線成績"),
    "paid": MessageLookupByLibrary.simpleMessage("已繳款"),
    "punch": MessageLookupByLibrary.simpleMessage("拍照打卡"),
    "punchSuccess": MessageLookupByLibrary.simpleMessage("打卡成功"),
    "qijin": MessageLookupByLibrary.simpleMessage("旗津"),
    "reportNetProblem": MessageLookupByLibrary.simpleMessage("網路問題通報"),
    "reportNetProblemSubTitle": MessageLookupByLibrary.simpleMessage(
      "通報遇到的網路問題(需使用校內信箱登入)",
    ),
    "reportProblem": MessageLookupByLibrary.simpleMessage("問題通報"),
    "reserve": MessageLookupByLibrary.simpleMessage("預約"),
    "reserveDeadline": MessageLookupByLibrary.simpleMessage("預約截止時間"),
    "reserved": MessageLookupByLibrary.simpleMessage("已預約"),
    "reserving": MessageLookupByLibrary.simpleMessage("預約中..."),
    "schoolCloseCourseHint": MessageLookupByLibrary.simpleMessage(
      "學校關閉課表 我們暫時無法解決\n任何問題建議與校方反應",
    ),
    "searchStudentIdFormat": MessageLookupByLibrary.simpleMessage(
      "姓名：%s\n學號：%s\n",
    ),
    "specialBus": MessageLookupByLibrary.simpleMessage("特殊班次"),
    "trialBus": MessageLookupByLibrary.simpleMessage("試辦車次"),
    "unknown": MessageLookupByLibrary.simpleMessage("未知"),
    "unpaid": MessageLookupByLibrary.simpleMessage("未繳款"),
    "updateNoteContent": MessageLookupByLibrary.simpleMessage(
      "* 修正部分裝置桌面小工具無法顯示",
    ),
    "yanchao": MessageLookupByLibrary.simpleMessage("燕巢"),
  };
}
