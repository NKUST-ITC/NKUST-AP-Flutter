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

	/// zh-Hant-TW: '選擇乘車時間：$date'
	String busPickDate({required Object date}) => '選擇乘車時間：${date}';

	/// zh-Hant-TW: '選擇乘車時間'
	String get busNotPickDate => '選擇乘車時間';

	/// zh-Hant-TW: '($current / $total)'
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

	/// zh-Hant-TW: '要預定從$from $time 的校車嗎？'
	String busReserveConfirmContent({required Object from, required Object time}) => '要預定從${from}\n${time} 的校車嗎？';

	/// zh-Hant-TW: '確定要<b>取消</b>本校車車次？'
	String get busCancelReserveConfirmTitle => '確定要<b>取消</b>本校車車次？';

	/// zh-Hant-TW: '要取消從$from $time 的校車嗎？'
	String busCancelReserveConfirmContent({required Object from, required Object time}) => '要取消從${from}\n${time} 的校車嗎？';

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

	/// zh-Hant-TW: 'Oops！本日校車沒上班喔～ 請選擇其他日期 😋'
	String get busEmpty => 'Oops！本日校車沒上班喔～\n請選擇其他日期 😋';

	/// zh-Hant-TW: '您尚未選擇日期！ 請先選擇日期 $hint'
	String busNotPick({required Object hint}) => '您尚未選擇日期！\n請先選擇日期 ${hint}';

	/// zh-Hant-TW: '校車預約將於發車前三十分鐘提醒！ 若在網頁預約或取消校車請重登入此App。'
	String get busNotifyHint => '校車預約將於發車前三十分鐘提醒！\n若在網頁預約或取消校車請重登入此App。';

	/// zh-Hant-TW: '您有一班 $start 從${end}出發的校車！'
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

	/// zh-Hant-TW: '取消中...'
	String get canceling => '取消中...';

	/// zh-Hant-TW: '學校校車系統或許壞掉惹～'
	String get busFailInfinity => '學校校車系統或許壞掉惹～';

	/// zh-Hant-TW: '預約截止時間'
	String get reserveDeadline => '預約截止時間';

	/// zh-Hant-TW: '校車搭乘規則'
	String get busRule => '校車搭乘規則';

	/// zh-Hant-TW: '姓名：$name 學號：$id '
	String searchStudentIdFormat({required Object name, required Object id}) => '姓名：${name}\n學號：${id}\n';

	/// zh-Hant-TW: '拍照打卡'
	String get punch => '拍照打卡';

	/// zh-Hant-TW: '打卡成功'
	String get punchSuccess => '打卡成功';

	/// zh-Hant-TW: '非上課時間'
	String get nonCourseTime => '非上課時間';

	/// zh-Hant-TW: '離線校車紀錄'
	String get offlineBusReservations => '離線校車紀錄';

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

	/// zh-Hant-TW: '預約中...'
	String get reserving => '預約中...';

	/// zh-Hant-TW: '未知'
	String get unknown => '未知';
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
			'busReserveConfirmContent' => ({required Object from, required Object time}) => '要預定從${from}\n${time} 的校車嗎？',
			'busCancelReserveConfirmTitle' => '確定要<b>取消</b>本校車車次？',
			'busCancelReserveConfirmContent' => ({required Object from, required Object time}) => '要取消從${from}\n${time} 的校車嗎？',
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
			'busEmpty' => 'Oops！本日校車沒上班喔～\n請選擇其他日期 😋',
			'busNotPick' => ({required Object hint}) => '您尚未選擇日期！\n請先選擇日期 ${hint}',
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
			'canceling' => '取消中...',
			'busFailInfinity' => '學校校車系統或許壞掉惹～',
			'reserveDeadline' => '預約截止時間',
			'busRule' => '校車搭乘規則',
			'searchStudentIdFormat' => ({required Object name, required Object id}) => '姓名：${name}\n學號：${id}\n',
			'punch' => '拍照打卡',
			'punchSuccess' => '打卡成功',
			'nonCourseTime' => '非上課時間',
			'offlineBusReservations' => '離線校車紀錄',
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
			'reserving' => '預約中...',
			'unknown' => '未知',
			_ => null,
		};
	}
}
