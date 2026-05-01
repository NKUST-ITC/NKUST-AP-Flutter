///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef NkustLocalizationsZhHantTw = NkustLocalizations; // ignore: unused_element
class NkustLocalizations with BaseTranslations<NkustLocale, NkustLocalizations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [NkustLocale.build] is preferred.
	NkustLocalizations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<NkustLocale, NkustLocalizations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: NkustLocale.zhHantTw,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh-Hant-TW>.
	@override final TranslationMetadata<NkustLocale, NkustLocalizations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final NkustLocalizations _root = this; // ignore: unused_field

	NkustLocalizations $copyWith({TranslationMetadata<NkustLocale, NkustLocalizations>? meta}) => NkustLocalizations(meta: meta ?? this.$meta);

	// Translations

	/// zh-Hant-TW: '高科校務通'
	String get appName => '高科校務通';

	/// zh-Hant-TW: '* 修正部分裝置桌面小工具無法顯示'
	String get updateNoteContent => '* 修正部分裝置桌面小工具無法顯示';

	/// zh-Hant-TW: 'https://github.com/NKUST-ITC/NKUST-AP-Flutter 本專案採MIT 開放原始碼授權： The MIT License (MIT) Copyright © 2021 Rainvisitor This project is Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'
	String get aboutOpenSourceContent => 'https://github.com/NKUST-ITC/NKUST-AP-Flutter\n\n本專案採MIT 開放原始碼授權：\nThe MIT License (MIT)\n\nCopyright © 2021 Rainvisitor\n\nThis project is Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.';

	/// zh-Hant-TW: '選擇乘車時間：${date}'
	String busPickDate({required Object date}) => '選擇乘車時間：${date}';

	/// zh-Hant-TW: '選擇乘車時間'
	String get busNotPickDate => '選擇乘車時間';

	/// zh-Hant-TW: '(${current} / ${total})'
	String busCount({required Object current, required Object total}) => '(${current} / ${total})';

	/// zh-Hant-TW: '到燕巢，發車日期：'
	String get busJiangongReservations => '到燕巢，發車日期：';

	/// zh-Hant-TW: '到建工，發車日期：'
	String get busYanchaoReservations => '到建工，發車日期：';

	/// zh-Hant-TW: '到燕巢，發車：'
	String get busJiangong => '到燕巢，發車：';

	/// zh-Hant-TW: '到建工，發車：'
	String get busYanchao => '到建工，發車：';

	/// zh-Hant-TW: '√ 到燕巢，發車：'
	String get busJiangongReserved => '√ 到燕巢，發車：';

	/// zh-Hant-TW: '√ 到建工，發車：'
	String get busYanchaoReserved => '√ 到建工，發車：';

	/// zh-Hant-TW: '預定校車'
	String get busReserve => '預定校車';

	/// zh-Hant-TW: '校車紀錄'
	String get busReservations => '校車紀錄';

	/// zh-Hant-TW: '校車罰緩'
	String get busViolationRecords => '校車罰緩';

	/// zh-Hant-TW: '未繳款'
	String get unpaid => '未繳款';

	/// zh-Hant-TW: '已繳款'
	String get paid => '已繳款';

	/// zh-Hant-TW: '取消預定校車'
	String get busCancelReserve => '取消預定校車';

	/// zh-Hant-TW: '確定要預定本次校車？'
	String get busReserveConfirmTitle => '確定要預定本次校車？';

	/// zh-Hant-TW: '要預定從${location} ${time} 的校車嗎？'
	String busReserveConfirmContent({required Object location, required Object time}) => '要預定從${location}\n${time} 的校車嗎？';

	/// zh-Hant-TW: '確定要<b>取消</b>本校車車次？'
	String get busCancelReserveConfirmTitle => '確定要<b>取消</b>本校車車次？';

	/// zh-Hant-TW: '要取消從${location} ${time} 的校車嗎？'
	String busCancelReserveConfirmContent({required Object location, required Object time}) => '要取消從${location}\n${time} 的校車嗎？';

	/// zh-Hant-TW: '要取消從'
	String get busCancelReserveConfirmContent1 => '要取消從';

	/// zh-Hant-TW: '到'
	String get busCancelReserveConfirmContent2 => '到';

	/// zh-Hant-TW: '的校車嗎？'
	String get busCancelReserveConfirmContent3 => '的校車嗎？';

	/// zh-Hant-TW: '建工到燕巢'
	String get busFromJiangong => '建工到燕巢';

	/// zh-Hant-TW: '燕巢到建工'
	String get busFromYanchao => '燕巢到建工';

	/// zh-Hant-TW: '預約'
	String get reserve => '預約';

	/// zh-Hant-TW: '預約日期'
	String get busReserveDate => '預約日期';

	/// zh-Hant-TW: '上車地點'
	String get busReserveLocation => '上車地點';

	/// zh-Hant-TW: '預約班次'
	String get busReserveTime => '預約班次';

	/// zh-Hant-TW: '建工'
	String get jiangong => '建工';

	/// zh-Hant-TW: '燕巢'
	String get yanchao => '燕巢';

	/// zh-Hant-TW: '第一'
	String get first => '第一';

	/// zh-Hant-TW: '楠梓'
	String get nanzi => '楠梓';

	/// zh-Hant-TW: '旗津'
	String get qijin => '旗津';

	/// zh-Hant-TW: '未知'
	String get unknown => '未知';

	/// zh-Hant-TW: '校區'
	String get campus => '校區';

	/// zh-Hant-TW: '已預約'
	String get reserved => '已預約';

	/// zh-Hant-TW: '無法預約'
	String get canNotReserve => '無法預約';

	/// zh-Hant-TW: '特殊班次'
	String get specialBus => '特殊班次';

	/// zh-Hant-TW: '試辦車次'
	String get trialBus => '試辦車次';

	/// zh-Hant-TW: '預約成功！'
	String get busReserveSuccess => '預約成功！';

	/// zh-Hant-TW: '取消日期'
	String get busReserveCancelDate => '取消日期';

	/// zh-Hant-TW: '上車地點'
	String get busReserveCancelLocation => '上車地點';

	/// zh-Hant-TW: '取消班次'
	String get busReserveCancelTime => '取消班次';

	/// zh-Hant-TW: '取消預約成功！'
	String get busCancelReserveSuccess => '取消預約成功！';

	/// zh-Hant-TW: '取消預約失敗'
	String get busCancelReserveFail => '取消預約失敗';

	/// zh-Hant-TW: 'Oops！您還沒有預約任何校車喔～ 多多搭乘大眾運輸，節能減碳救地球 😋'
	String get busReservationEmpty => 'Oops！您還沒有預約任何校車喔～\n多多搭乘大眾運輸，節能減碳救地球 😋';

	/// zh-Hant-TW: 'Oops 預約失敗'
	String get busReserveFailTitle => 'Oops 預約失敗';

	/// zh-Hant-TW: '我知道了'
	String get iKnow => '我知道了';

	/// zh-Hant-TW: 'Oops！本日校車沒上班喔～ 請選擇其他日期 😋'
	String get busEmpty => 'Oops！本日校車沒上班喔～\n請選擇其他日期 😋';

	/// zh-Hant-TW: '您尚未選擇日期！ 請先選擇日期 ${date}'
	String busNotPick({required Object date}) => '您尚未選擇日期！\n請先選擇日期 ${date}';

	/// zh-Hant-TW: '校車預約將於發車前三十分鐘提醒！ 若在網頁預約或取消校車請重登入此App。'
	String get busNotifyHint => '校車預約將於發車前三十分鐘提醒！\n若在網頁預約或取消校車請重登入此App。';

	/// zh-Hant-TW: '您有一班 ${start} 從${end}出發的校車！'
	String busNotifyContent({required Object start, required Object end}) => '您有一班 ${start} 從${end}出發的校車！';

	/// zh-Hant-TW: '建工'
	String get busNotifyJiangong => '建工';

	/// zh-Hant-TW: '燕巢'
	String get busNotifyYanchao => '燕巢';

	/// zh-Hant-TW: '校車提醒'
	String get busNotify => '校車提醒';

	/// zh-Hant-TW: '發車前三十分鐘提醒'
	String get busNotifySubTitle => '發車前三十分鐘提醒';

	/// zh-Hant-TW: '校車系統'
	String get bus => '校車系統';

	/// zh-Hant-TW: '建工上車'
	String get fromJiangong => '建工上車';

	/// zh-Hant-TW: '燕巢上車'
	String get fromYanchao => '燕巢上車';

	/// zh-Hant-TW: '第一上車'
	String get fromFirst => '第一上車';

	/// zh-Hant-TW: '目的地'
	String get destination => '目的地';

	/// zh-Hant-TW: '預約中...'
	String get reserving => '預約中...';

	/// zh-Hant-TW: '取消中...'
	String get canceling => '取消中...';

	/// zh-Hant-TW: '學校校車系統或許壞掉惹～'
	String get busFailInfinity => '學校校車系統或許壞掉惹～';

	/// zh-Hant-TW: '預約截止時間'
	String get reserveDeadline => '預約截止時間';

	/// zh-Hant-TW: '校車搭乘規則'
	String get busRule => '校車搭乘規則';

	/// zh-Hant-TW: '首次登入密碼預設為身分證末四碼'
	String get firstLoginHint => '首次登入密碼預設為身分證末四碼';

	/// zh-Hant-TW: '姓名：${name} 學號：${id} '
	String searchStudentIdFormat({required Object name, required Object id}) => '姓名：${name}\n學號：${id}\n';

	/// zh-Hant-TW: '無期限'
	String get noExpiration => '無期限';

	/// zh-Hant-TW: '拍照打卡'
	String get punch => '拍照打卡';

	/// zh-Hant-TW: '打卡成功'
	String get punchSuccess => '打卡成功';

	/// zh-Hant-TW: '非上課時間'
	String get nonCourseTime => '非上課時間';

	/// zh-Hant-TW: '離線成績'
	String get offlineScore => '離線成績';

	/// zh-Hant-TW: '離線校車紀錄'
	String get offlineBusReservations => '離線校車紀錄';

	/// zh-Hant-TW: '離線缺曠資料'
	String get offlineLeaveData => '離線缺曠資料';

	/// zh-Hant-TW: '預約校車 '
	String get busRuleReservationRuleTitle => '預約校車\n';

	/// zh-Hant-TW: '• 請上 '
	String get busRuleTravelBy => '• 請上 ';

	/// zh-Hant-TW: '• 校車預約系統預約校車 • 可預約14天以內的校車班次 • 為配合總務處派車需求預約時間 '
	String get busRuleFourteenDay => '• 校車預約系統預約校車\n• 可預約14天以內的校車班次\n• 為配合總務處派車需求預約時間\n';

	/// zh-Hant-TW: '■ 9點以前的班次：請於發車前15個小時預約 ■ 9點以後的班次：請於發車前5個小時預約 '
	String get busRuleReservationTime => '■ 9點以前的班次：請於發車前15個小時預約\n■ 9點以後的班次：請於發車前5個小時預約\n';

	/// zh-Hant-TW: '• 取消預約時間 '
	String get busRuleCancellingTitle => '• 取消預約時間\n';

	/// zh-Hant-TW: '■ 9點以前的班次：請於發車前15個小時預約 ■ 9點以後的班次：請於發車前5個小時預約 '
	String get busRuleCancelingTime => '■ 9點以前的班次：請於發車前15個小時預約\n■ 9點以後的班次：請於發車前5個小時預約\n';

	/// zh-Hant-TW: '• 請全校師生及職員依規定預約校車，若因未預約校車而無法到課或上班者，請自行負責 '
	String get busRuleFollow => '• 請全校師生及職員依規定預約校車，若因未預約校車而無法到課或上班者，請自行負責\n';

	/// zh-Hant-TW: '上車 '
	String get busRuleTakeOn => '上車\n';

	/// zh-Hant-TW: '• 每次上車繳款20元'
	String get busRuleTwentyDollars => '• 每次上車繳款20元';

	/// zh-Hant-TW: '（未發卡前先以投幣繳費，請自備20元銅板投幣） '
	String get busRulePrepareCoins => '（未發卡前先以投幣繳費，請自備20元銅板投幣）\n';

	/// zh-Hant-TW: '• 請持學生證或教職員證(未發卡前先採用身分證識別)上車 '
	String get busRuleIdCard => '• 請持學生證或教職員證(未發卡前先採用身分證識別)上車\n';

	/// zh-Hant-TW: '• 未攜帶證件者請排後補區 '
	String get busRuleNoIdCard => '• 未攜帶證件者請排後補區\n';

	/// zh-Hant-TW: '• 請依預約的班次時間搭乘(例如：8:20與9:30視為不同班次），未依規定者不得上車，並計違規點數一點 '
	String get busRuleFollowingTime => '• 請依預約的班次時間搭乘(例如：8:20與9:30視為不同班次），未依規定者不得上車，並計違規點數一點\n';

	/// zh-Hant-TW: '• 逾時或未預約搭乘者請至候補車道排隊候補上車。 候補上車 • 在正常車道上車時未通過驗證者(ex.未預約該班次)，請改至候補車道排隊候補上車。 • 候補者需等待預約該班次的人全部上車之後才依序遞補上車 '
	String get busRuleLateAndNoReservation => '• 逾時或未預約搭乘者請至候補車道排隊候補上車。\n候補上車\n• 在正常車道上車時未通過驗證者(ex.未預約該班次)，請改至候補車道排隊候補上車。\n• 候補者需等待預約該班次的人全部上車之後才依序遞補上車\n';

	/// zh-Hant-TW: '候補上車 '
	String get busRuleStandbyTitle => '候補上車\n';

	/// zh-Hant-TW: '• 未依預約的班次搭乘者，視為違規，計違規點數一次(例如：8:20與9:30視為不同班次） • 因教師臨時請假、臨時調課致使需提前或延後搭車，得向開課系所提出申請，並由系所之交通車系統管理者註銷違規紀錄。 候補上車 • 在正常車道上車時未通過驗證者(ex.未預約該班次)，請改至候補車道排隊候補上車。 • 候補者需等待預約該班次的人全部上車之後才依序遞補上車 '
	String get busRuleStandbyRule => '• 未依預約的班次搭乘者，視為違規，計違規點數一次(例如：8:20與9:30視為不同班次）\n• 因教師臨時請假、臨時調課致使需提前或延後搭車，得向開課系所提出申請，並由系所之交通車系統管理者註銷違規紀錄。\n候補上車\n• 在正常車道上車時未通過驗證者(ex.未預約該班次)，請改至候補車道排隊候補上車。\n• 候補者需等待預約該班次的人全部上車之後才依序遞補上車\n';

	/// zh-Hant-TW: '罰款 '
	String get busRuleFineTitle => '罰款\n';

	/// zh-Hant-TW: '• 違規罰款金額計算，違規前三次不計點，從第四次開始違規記點，每點應繳納等同車資之罰款 • 違規點數統計至學期末為止(上學期學期末1/31，下學期8/31)，新學期違規點數重新計算。當學期罰款未繳清者，次學期停止預約權限至罰款繳清為止 • 罰款請自行列印違規明細後至自動繳費機或總務處出納組繳費，繳費後憑收據至總務處事務組銷帳(當天開列之收據須於當天銷帳)，銷帳完後隔天凌晨4點後才可預約當天9點後的校車。 • 罰款點數如有疑義，請於違規發生日起10日內(含星期例假日)逕向總務處事務組確認。 '
	String get busRuleFineRule => '• 違規罰款金額計算，違規前三次不計點，從第四次開始違規記點，每點應繳納等同車資之罰款\n• 違規點數統計至學期末為止(上學期學期末1/31，下學期8/31)，新學期違規點數重新計算。當學期罰款未繳清者，次學期停止預約權限至罰款繳清為止\n• 罰款請自行列印違規明細後至自動繳費機或總務處出納組繳費，繳費後憑收據至總務處事務組銷帳(當天開列之收據須於當天銷帳)，銷帳完後隔天凌晨4點後才可預約當天9點後的校車。\n• 罰款點數如有疑義，請於違規發生日起10日內(含星期例假日)逕向總務處事務組確認。\n';

	/// zh-Hant-TW: '太好了！您沒有任何校車罰緩～'
	String get busViolationRecordEmpty => '太好了！您沒有任何校車罰緩～';

	/// zh-Hant-TW: '學校關閉課表 我們暫時無法解決 任何問題建議與校方反應'
	String get schoolCloseCourseHint => '學校關閉課表 我們暫時無法解決\n任何問題建議與校方反應';

	/// zh-Hant-TW: '登入驗證'
	String get loginAuth => '登入驗證';

	/// zh-Hant-TW: '點擊看說明'
	String get clickShowDescription => '點擊看說明';

	/// zh-Hant-TW: '等待網頁完成載入 將自動填寫學號密碼 完成機器人驗證後點擊登入 將自動跳轉'
	String get mobileNkustLoginHint => '等待網頁完成載入\n將自動填寫學號密碼\n完成機器人驗證後點擊登入\n將自動跳轉';

	/// zh-Hant-TW: '因應校方關閉原有爬蟲功能，此版本需透過新版手機版校務系統登入。成功登入後會自動跳轉，除非憑證過期，否則極少需要重複驗證，強烈建議將記住我勾選。'
	String get mobileNkustLoginDescription => '因應校方關閉原有爬蟲功能，此版本需透過新版手機版校務系統登入。成功登入後會自動跳轉，除非憑證過期，否則極少需要重複驗證，強烈建議將記住我勾選。';

	/// zh-Hant-TW: '請假查詢'
	String get leaveApplyRecord => '請假查詢';

	/// zh-Hant-TW: '網路問題通報'
	String get reportNetProblem => '網路問題通報';

	/// zh-Hant-TW: '通報遇到的網路問題(需使用校內信箱登入)'
	String get reportNetProblemSubTitle => '通報遇到的網路問題(需使用校內信箱登入)';

	/// zh-Hant-TW: '問題通報'
	String get reportProblem => '問題通報';

	/// zh-Hant-TW: '在學證明'
	String get enrollmentLetter => '在學證明';

	/// zh-Hant-TW: '主題色'
	String get themeColor => '主題色';

	/// zh-Hant-TW: '繁體中文'
	String get traditionalChinese => '繁體中文';

	/// zh-Hant-TW: '跟隨系統'
	String get followSystem => '跟隨系統';

	/// zh-Hant-TW: '回報選項'
	String get reportOptions => '回報選項';

	/// zh-Hant-TW: '回報 App 問題'
	String get reportAppBug => '回報 App 問題';

	/// zh-Hant-TW: '功能異常、閃退等問題'
	String get reportAppBugSubtitle => '功能異常、閃退等問題';

	/// zh-Hant-TW: '功能建議'
	String get featureSuggestion => '功能建議';

	/// zh-Hant-TW: '提供新功能或改善建議'
	String get featureSuggestionSubtitle => '提供新功能或改善建議';

	/// zh-Hant-TW: '需要幫助嗎？'
	String get needHelp => '需要幫助嗎？';

	/// zh-Hant-TW: '選擇下方選項來回報問題或提供建議'
	String get selectReportOption => '選擇下方選項來回報問題或提供建議';

	/// zh-Hant-TW: '查詢學號'
	String get searchStudentId => '查詢學號';

	/// zh-Hant-TW: '學生證條碼'
	String get studentIdBarcode => '學生證條碼';

	/// zh-Hant-TW: '請於圖書館使用此學號'
	String get useStudentIdInLibrary => '請於圖書館使用此學號';

	/// zh-Hant-TW: '點擊登入'
	String get tapToLogin => '點擊登入';

	/// zh-Hant-TW: '高科藍'
	String get nkustBlue => '高科藍';

	/// zh-Hant-TW: '海洋藍'
	String get oceanBlue => '海洋藍';

	/// zh-Hant-TW: '翠綠'
	String get emeraldGreen => '翠綠';

	/// zh-Hant-TW: '珊瑚橙'
	String get coralOrange => '珊瑚橙';

	/// zh-Hant-TW: '典雅紫'
	String get elegantPurple => '典雅紫';

	/// zh-Hant-TW: '玫瑰紅'
	String get roseRed => '玫瑰紅';

	/// zh-Hant-TW: '青色'
	String get cyan => '青色';

	/// zh-Hant-TW: '琥珀'
	String get amber => '琥珀';

	/// zh-Hant-TW: '靛藍'
	String get indigoBlue => '靛藍';

	/// zh-Hant-TW: '棕褐'
	String get brownTan => '棕褐';

	/// zh-Hant-TW: '自訂色'
	String get customColor => '自訂色';

	/// zh-Hant-TW: '選擇主題色'
	String get selectThemeColor => '選擇主題色';

	/// zh-Hant-TW: '取消'
	String get cancel => '取消';

	/// zh-Hant-TW: '確定'
	String get confirm => '確定';

	/// zh-Hant-TW: '色相'
	String get hue => '色相';

	/// zh-Hant-TW: '飽和度'
	String get saturation => '飽和度';

	/// zh-Hant-TW: '亮度'
	String get brightness => '亮度';

	/// zh-Hant-TW: '一'
	String get monday => '一';

	/// zh-Hant-TW: '二'
	String get tuesday => '二';

	/// zh-Hant-TW: '三'
	String get wednesday => '三';

	/// zh-Hant-TW: '四'
	String get thursday => '四';

	/// zh-Hant-TW: '五'
	String get friday => '五';

	/// zh-Hant-TW: '六'
	String get saturday => '六';

	/// zh-Hant-TW: '日'
	String get sunday => '日';

	/// zh-Hant-TW: '節'
	String get period => '節';

	/// zh-Hant-TW: '授課教師'
	String get instructor => '授課教師';

	/// zh-Hant-TW: '上課地點'
	String get classLocation => '上課地點';

	/// zh-Hant-TW: '學分數'
	String get credits => '學分數';

	/// zh-Hant-TW: '學分'
	String get creditsUnit => '學分';

	/// zh-Hant-TW: '上課時間'
	String get classTime => '上課時間';

	/// zh-Hant-TW: '班級'
	String get className => '班級';

	/// zh-Hant-TW: '關閉'
	String get close => '關閉';

	/// zh-Hant-TW: '週'
	String get weekDay => '週';

	/// zh-Hant-TW: '第${number}節'
	String periodNumber({required Object number}) => '第${number}節';

	/// zh-Hant-TW: '列表模式'
	String get listMode => '列表模式';

	/// zh-Hant-TW: '表格模式'
	String get tableMode => '表格模式';

	/// zh-Hant-TW: '載入課表中...'
	String get loadingCourse => '載入課表中...';

	/// zh-Hant-TW: '點擊重試'
	String get tapToRetry => '點擊重試';

	/// zh-Hant-TW: '科目詳情'
	String get courseDetails => '科目詳情';

	/// zh-Hant-TW: '成績總覽'
	String get scoreOverview => '成績總覽';

	/// zh-Hant-TW: '載入成績中...'
	String get loadingScore => '載入成績中...';

	/// zh-Hant-TW: '估計 PR 值'
	String get estimatedPR => '估計 PR 值';

	/// zh-Hant-TW: '※ PR 值為根據平均成績估算，僅供參考'
	String get prDisclaimer => '※ PR 值為根據平均成績估算，僅供參考';

	/// zh-Hant-TW: '成績統計'
	String get scoreStatistics => '成績統計';

	/// zh-Hant-TW: '最高分'
	String get highestScore => '最高分';

	/// zh-Hant-TW: '最低分'
	String get lowestScore => '最低分';

	/// zh-Hant-TW: '標準差'
	String get standardDeviation => '標準差';

	/// zh-Hant-TW: '科目數'
	String get subjectCount => '科目數';

	/// zh-Hant-TW: '成績分佈'
	String get scoreDistribution => '成績分佈';

	/// zh-Hant-TW: '優秀'
	String get excellent => '優秀';

	/// zh-Hant-TW: '良好'
	String get good => '良好';

	/// zh-Hant-TW: '普通'
	String get average => '普通';

	/// zh-Hant-TW: '及格'
	String get pass => '及格';

	/// zh-Hant-TW: '不及格'
	String get fail => '不及格';

	/// zh-Hant-TW: '${count} 科'
	String subjectCountUnit({required Object count}) => '${count} 科';

	/// zh-Hant-TW: '學分統計'
	String get creditStatistics => '學分統計';

	/// zh-Hant-TW: '修習學分'
	String get enrolledCredits => '修習學分';

	/// zh-Hant-TW: '及格學分'
	String get passedCredits => '及格學分';

	/// zh-Hant-TW: '不及格學分'
	String get failedCredits => '不及格學分';

	/// zh-Hant-TW: '期中: ${score}'
	String midtermScore({required Object score}) => '期中: ${score}';

	/// zh-Hant-TW: '頂尖'
	String get prTop => '頂尖';

	/// zh-Hant-TW: '優秀'
	String get prExcellent => '優秀';

	/// zh-Hant-TW: '中等'
	String get prAverage => '中等';

	/// zh-Hant-TW: '待加強'
	String get prNeedsImprovement => '待加強';

	/// zh-Hant-TW: '需努力'
	String get prNeedsEffort => '需努力';

	/// zh-Hant-TW: '上學期'
	String get firstSemester => '上學期';

	/// zh-Hant-TW: '下學期'
	String get secondSemester => '下學期';

	/// zh-Hant-TW: '寒修'
	String get winterSession => '寒修';

	/// zh-Hant-TW: '暑修'
	String get summerSession => '暑修';

	/// zh-Hant-TW: '先修'
	String get preSemester => '先修';

	/// zh-Hant-TW: '暑修(一)'
	String get summerSessionOne => '暑修(一)';

	/// zh-Hant-TW: '暑修(特)'
	String get summerSessionSpecial => '暑修(特)';

	/// zh-Hant-TW: '${year} 學年度'
	String academicYear({required Object year}) => '${year} 學年度';

	/// zh-Hant-TW: '載入中'
	String get loading => '載入中';

	/// zh-Hant-TW: '無資料'
	String get noData => '無資料';

	/// zh-Hant-TW: '目前'
	String get currentSemester => '目前';

	/// zh-Hant-TW: '查無在學證明資料'
	String get noEnrollmentData => '查無在學證明資料';

	/// zh-Hant-TW: '尚無在學證明可下載 請確認是否已申請在學證明'
	String get noEnrollmentAvailable => '尚無在學證明可下載\n請確認是否已申請在學證明';

	/// zh-Hant-TW: '無法取得有效的 PDF 文件'
	String get invalidPdfFormat => '無法取得有效的 PDF 文件';

	/// zh-Hant-TW: '網路錯誤：${message}'
	String networkError({required Object message}) => '網路錯誤：${message}';

	/// zh-Hant-TW: '載入失敗：${message}'
	String loadFailed({required Object message}) => '載入失敗：${message}';

	/// zh-Hant-TW: '您先前已登入失敗達5次!!請30分鐘後再嘗試登入!!'
	String get loginFailedFiveTimes => '您先前已登入失敗達5次!!請30分鐘後再嘗試登入!!';

	/// zh-Hant-TW: '${count} 個專案'
	String projectCount({required Object count}) => '${count} 個專案';

	/// zh-Hant-TW: '開源授權'
	String get openSourceLicense => '開源授權';

	/// zh-Hant-TW: '高雄科技大學'
	String get nkustLocation => '高雄科技大學';

	/// zh-Hant-TW: '其他'
	String get otherBuilding => '其他';
}

/// The flat map containing all translations for locale <zh-Hant-TW>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on NkustLocalizations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'appName' => '高科校務通',
			'updateNoteContent' => '* 修正部分裝置桌面小工具無法顯示',
			'aboutOpenSourceContent' => 'https://github.com/NKUST-ITC/NKUST-AP-Flutter\n\n本專案採MIT 開放原始碼授權：\nThe MIT License (MIT)\n\nCopyright © 2021 Rainvisitor\n\nThis project is Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.',
			'busPickDate' => ({required Object date}) => '選擇乘車時間：${date}',
			'busNotPickDate' => '選擇乘車時間',
			'busCount' => ({required Object current, required Object total}) => '(${current} / ${total})',
			'busJiangongReservations' => '到燕巢，發車日期：',
			'busYanchaoReservations' => '到建工，發車日期：',
			'busJiangong' => '到燕巢，發車：',
			'busYanchao' => '到建工，發車：',
			'busJiangongReserved' => '√ 到燕巢，發車：',
			'busYanchaoReserved' => '√ 到建工，發車：',
			'busReserve' => '預定校車',
			'busReservations' => '校車紀錄',
			'busViolationRecords' => '校車罰緩',
			'unpaid' => '未繳款',
			'paid' => '已繳款',
			'busCancelReserve' => '取消預定校車',
			'busReserveConfirmTitle' => '確定要預定本次校車？',
			'busReserveConfirmContent' => ({required Object location, required Object time}) => '要預定從${location}\n${time} 的校車嗎？',
			'busCancelReserveConfirmTitle' => '確定要<b>取消</b>本校車車次？',
			'busCancelReserveConfirmContent' => ({required Object location, required Object time}) => '要取消從${location}\n${time} 的校車嗎？',
			'busCancelReserveConfirmContent1' => '要取消從',
			'busCancelReserveConfirmContent2' => '到',
			'busCancelReserveConfirmContent3' => '的校車嗎？',
			'busFromJiangong' => '建工到燕巢',
			'busFromYanchao' => '燕巢到建工',
			'reserve' => '預約',
			'busReserveDate' => '預約日期',
			'busReserveLocation' => '上車地點',
			'busReserveTime' => '預約班次',
			'jiangong' => '建工',
			'yanchao' => '燕巢',
			'first' => '第一',
			'nanzi' => '楠梓',
			'qijin' => '旗津',
			'unknown' => '未知',
			'campus' => '校區',
			'reserved' => '已預約',
			'canNotReserve' => '無法預約',
			'specialBus' => '特殊班次',
			'trialBus' => '試辦車次',
			'busReserveSuccess' => '預約成功！',
			'busReserveCancelDate' => '取消日期',
			'busReserveCancelLocation' => '上車地點',
			'busReserveCancelTime' => '取消班次',
			'busCancelReserveSuccess' => '取消預約成功！',
			'busCancelReserveFail' => '取消預約失敗',
			'busReservationEmpty' => 'Oops！您還沒有預約任何校車喔～\n多多搭乘大眾運輸，節能減碳救地球 😋',
			'busReserveFailTitle' => 'Oops 預約失敗',
			'iKnow' => '我知道了',
			'busEmpty' => 'Oops！本日校車沒上班喔～\n請選擇其他日期 😋',
			'busNotPick' => ({required Object date}) => '您尚未選擇日期！\n請先選擇日期 ${date}',
			'busNotifyHint' => '校車預約將於發車前三十分鐘提醒！\n若在網頁預約或取消校車請重登入此App。',
			'busNotifyContent' => ({required Object start, required Object end}) => '您有一班 ${start} 從${end}出發的校車！',
			'busNotifyJiangong' => '建工',
			'busNotifyYanchao' => '燕巢',
			'busNotify' => '校車提醒',
			'busNotifySubTitle' => '發車前三十分鐘提醒',
			'bus' => '校車系統',
			'fromJiangong' => '建工上車',
			'fromYanchao' => '燕巢上車',
			'fromFirst' => '第一上車',
			'destination' => '目的地',
			'reserving' => '預約中...',
			'canceling' => '取消中...',
			'busFailInfinity' => '學校校車系統或許壞掉惹～',
			'reserveDeadline' => '預約截止時間',
			'busRule' => '校車搭乘規則',
			'firstLoginHint' => '首次登入密碼預設為身分證末四碼',
			'searchStudentIdFormat' => ({required Object name, required Object id}) => '姓名：${name}\n學號：${id}\n',
			'noExpiration' => '無期限',
			'punch' => '拍照打卡',
			'punchSuccess' => '打卡成功',
			'nonCourseTime' => '非上課時間',
			'offlineScore' => '離線成績',
			'offlineBusReservations' => '離線校車紀錄',
			'offlineLeaveData' => '離線缺曠資料',
			'busRuleReservationRuleTitle' => '預約校車\n',
			'busRuleTravelBy' => '• 請上 ',
			'busRuleFourteenDay' => '• 校車預約系統預約校車\n• 可預約14天以內的校車班次\n• 為配合總務處派車需求預約時間\n',
			'busRuleReservationTime' => '■ 9點以前的班次：請於發車前15個小時預約\n■ 9點以後的班次：請於發車前5個小時預約\n',
			'busRuleCancellingTitle' => '• 取消預約時間\n',
			'busRuleCancelingTime' => '■ 9點以前的班次：請於發車前15個小時預約\n■ 9點以後的班次：請於發車前5個小時預約\n',
			'busRuleFollow' => '• 請全校師生及職員依規定預約校車，若因未預約校車而無法到課或上班者，請自行負責\n',
			'busRuleTakeOn' => '上車\n',
			'busRuleTwentyDollars' => '• 每次上車繳款20元',
			'busRulePrepareCoins' => '（未發卡前先以投幣繳費，請自備20元銅板投幣）\n',
			'busRuleIdCard' => '• 請持學生證或教職員證(未發卡前先採用身分證識別)上車\n',
			'busRuleNoIdCard' => '• 未攜帶證件者請排後補區\n',
			'busRuleFollowingTime' => '• 請依預約的班次時間搭乘(例如：8:20與9:30視為不同班次），未依規定者不得上車，並計違規點數一點\n',
			'busRuleLateAndNoReservation' => '• 逾時或未預約搭乘者請至候補車道排隊候補上車。\n候補上車\n• 在正常車道上車時未通過驗證者(ex.未預約該班次)，請改至候補車道排隊候補上車。\n• 候補者需等待預約該班次的人全部上車之後才依序遞補上車\n',
			'busRuleStandbyTitle' => '候補上車\n',
			'busRuleStandbyRule' => '• 未依預約的班次搭乘者，視為違規，計違規點數一次(例如：8:20與9:30視為不同班次）\n• 因教師臨時請假、臨時調課致使需提前或延後搭車，得向開課系所提出申請，並由系所之交通車系統管理者註銷違規紀錄。\n候補上車\n• 在正常車道上車時未通過驗證者(ex.未預約該班次)，請改至候補車道排隊候補上車。\n• 候補者需等待預約該班次的人全部上車之後才依序遞補上車\n',
			'busRuleFineTitle' => '罰款\n',
			'busRuleFineRule' => '• 違規罰款金額計算，違規前三次不計點，從第四次開始違規記點，每點應繳納等同車資之罰款\n• 違規點數統計至學期末為止(上學期學期末1/31，下學期8/31)，新學期違規點數重新計算。當學期罰款未繳清者，次學期停止預約權限至罰款繳清為止\n• 罰款請自行列印違規明細後至自動繳費機或總務處出納組繳費，繳費後憑收據至總務處事務組銷帳(當天開列之收據須於當天銷帳)，銷帳完後隔天凌晨4點後才可預約當天9點後的校車。\n• 罰款點數如有疑義，請於違規發生日起10日內(含星期例假日)逕向總務處事務組確認。\n',
			'busViolationRecordEmpty' => '太好了！您沒有任何校車罰緩～',
			'schoolCloseCourseHint' => '學校關閉課表 我們暫時無法解決\n任何問題建議與校方反應',
			'loginAuth' => '登入驗證',
			'clickShowDescription' => '點擊看說明',
			'mobileNkustLoginHint' => '等待網頁完成載入\n將自動填寫學號密碼\n完成機器人驗證後點擊登入\n將自動跳轉',
			'mobileNkustLoginDescription' => '因應校方關閉原有爬蟲功能，此版本需透過新版手機版校務系統登入。成功登入後會自動跳轉，除非憑證過期，否則極少需要重複驗證，強烈建議將記住我勾選。',
			'leaveApplyRecord' => '請假查詢',
			'reportNetProblem' => '網路問題通報',
			'reportNetProblemSubTitle' => '通報遇到的網路問題(需使用校內信箱登入)',
			'reportProblem' => '問題通報',
			'enrollmentLetter' => '在學證明',
			'themeColor' => '主題色',
			'traditionalChinese' => '繁體中文',
			'followSystem' => '跟隨系統',
			'reportOptions' => '回報選項',
			'reportAppBug' => '回報 App 問題',
			'reportAppBugSubtitle' => '功能異常、閃退等問題',
			'featureSuggestion' => '功能建議',
			'featureSuggestionSubtitle' => '提供新功能或改善建議',
			'needHelp' => '需要幫助嗎？',
			'selectReportOption' => '選擇下方選項來回報問題或提供建議',
			'searchStudentId' => '查詢學號',
			'studentIdBarcode' => '學生證條碼',
			'useStudentIdInLibrary' => '請於圖書館使用此學號',
			'tapToLogin' => '點擊登入',
			'nkustBlue' => '高科藍',
			'oceanBlue' => '海洋藍',
			'emeraldGreen' => '翠綠',
			'coralOrange' => '珊瑚橙',
			'elegantPurple' => '典雅紫',
			'roseRed' => '玫瑰紅',
			'cyan' => '青色',
			'amber' => '琥珀',
			'indigoBlue' => '靛藍',
			'brownTan' => '棕褐',
			'customColor' => '自訂色',
			'selectThemeColor' => '選擇主題色',
			'cancel' => '取消',
			'confirm' => '確定',
			'hue' => '色相',
			'saturation' => '飽和度',
			'brightness' => '亮度',
			'monday' => '一',
			'tuesday' => '二',
			'wednesday' => '三',
			'thursday' => '四',
			'friday' => '五',
			'saturday' => '六',
			'sunday' => '日',
			'period' => '節',
			'instructor' => '授課教師',
			'classLocation' => '上課地點',
			'credits' => '學分數',
			'creditsUnit' => '學分',
			'classTime' => '上課時間',
			'className' => '班級',
			'close' => '關閉',
			'weekDay' => '週',
			'periodNumber' => ({required Object number}) => '第${number}節',
			'listMode' => '列表模式',
			'tableMode' => '表格模式',
			'loadingCourse' => '載入課表中...',
			'tapToRetry' => '點擊重試',
			'courseDetails' => '科目詳情',
			'scoreOverview' => '成績總覽',
			'loadingScore' => '載入成績中...',
			'estimatedPR' => '估計 PR 值',
			'prDisclaimer' => '※ PR 值為根據平均成績估算，僅供參考',
			'scoreStatistics' => '成績統計',
			'highestScore' => '最高分',
			'lowestScore' => '最低分',
			'standardDeviation' => '標準差',
			'subjectCount' => '科目數',
			'scoreDistribution' => '成績分佈',
			'excellent' => '優秀',
			'good' => '良好',
			'average' => '普通',
			'pass' => '及格',
			'fail' => '不及格',
			'subjectCountUnit' => ({required Object count}) => '${count} 科',
			'creditStatistics' => '學分統計',
			'enrolledCredits' => '修習學分',
			'passedCredits' => '及格學分',
			'failedCredits' => '不及格學分',
			'midtermScore' => ({required Object score}) => '期中: ${score}',
			'prTop' => '頂尖',
			'prExcellent' => '優秀',
			'prAverage' => '中等',
			'prNeedsImprovement' => '待加強',
			'prNeedsEffort' => '需努力',
			'firstSemester' => '上學期',
			'secondSemester' => '下學期',
			'winterSession' => '寒修',
			'summerSession' => '暑修',
			'preSemester' => '先修',
			'summerSessionOne' => '暑修(一)',
			'summerSessionSpecial' => '暑修(特)',
			'academicYear' => ({required Object year}) => '${year} 學年度',
			'loading' => '載入中',
			'noData' => '無資料',
			'currentSemester' => '目前',
			'noEnrollmentData' => '查無在學證明資料',
			'noEnrollmentAvailable' => '尚無在學證明可下載\n請確認是否已申請在學證明',
			'invalidPdfFormat' => '無法取得有效的 PDF 文件',
			'networkError' => ({required Object message}) => '網路錯誤：${message}',
			'loadFailed' => ({required Object message}) => '載入失敗：${message}',
			'loginFailedFiveTimes' => '您先前已登入失敗達5次!!請30分鐘後再嘗試登入!!',
			'projectCount' => ({required Object count}) => '${count} 個專案',
			'openSourceLicense' => '開源授權',
			'nkustLocation' => '高雄科技大學',
			'otherBuilding' => '其他',
			_ => null,
		};
	}
}
