///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class NkustLocalizationsJa extends NkustLocalizations with BaseTranslations<NkustLocale, NkustLocalizations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [NkustLocale.build] is preferred.
	NkustLocalizationsJa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<NkustLocale, NkustLocalizations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: NkustLocale.ja,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ja>.
	@override final TranslationMetadata<NkustLocale, NkustLocalizations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final NkustLocalizationsJa _root = this; // ignore: unused_field

	@override 
	NkustLocalizationsJa $copyWith({TranslationMetadata<NkustLocale, NkustLocalizations>? meta}) => NkustLocalizationsJa(meta: meta ?? this.$meta);

	// Translations
	@override String get appName => '高科校務通';
	@override String get updateNoteContent => '* 一部のデバイスでホームウィジェットが表示されない問題を修正';
	@override String get aboutOpenSourceContent => 'https://github.com/NKUST-ITC/NKUST-AP-Flutter\n\n本プロジェクトはMITオープンソースライセンスを採用しています：\nThe MIT License (MIT)\n\nCopyright © 2021 Rainvisitor';
	@override String busPickDate({required Object date}) => '乗車日時を選択：${date}';
	@override String get busNotPickDate => '乗車日時を選択';
	@override String busCount({required Object current, required Object total}) => '(${current} / ${total})';
	@override String get busJiangongReservations => '燕巣行き、発車日：';
	@override String get busYanchaoReservations => '建工行き、発車日：';
	@override String get busJiangong => '燕巣行き、発車：';
	@override String get busYanchao => '建工行き、発車：';
	@override String get busJiangongReserved => '√ 燕巣行き、発車：';
	@override String get busYanchaoReserved => '√ 建工行き、発車：';
	@override String get busReserve => 'シャトルバス予約';
	@override String get busReservations => 'バス予約履歴';
	@override String get busViolationRecords => 'バス違反記録';
	@override String get unpaid => '未払い';
	@override String get paid => '支払済み';
	@override String get busCancelReserve => '予約をキャンセル';
	@override String get busReserveConfirmTitle => 'このバスを予約しますか？';
	@override String busReserveConfirmContent({required Object location, required Object time}) => '${location}から${time}のバスを予約しますか？';
	@override String get busCancelReserveConfirmTitle => 'この予約を<b>キャンセル</b>しますか？';
	@override String busCancelReserveConfirmContent({required Object location, required Object time}) => '${location}から${time}のバスをキャンセルしますか？';
	@override String get busCancelReserveConfirmContent1 => '予約をキャンセル：';
	@override String get busCancelReserveConfirmContent2 => 'から';
	@override String get busCancelReserveConfirmContent3 => 'へ？';
	@override String get busFromJiangong => '建工から燕巣';
	@override String get busFromYanchao => '燕巣から建工';
	@override String get busReserveDate => '予約日';
	@override String get busReserveLocation => '乗車場所';
	@override String get busReserveTime => '予約便';
	@override String get jiangong => '建工';
	@override String get yanchao => '燕巣';
	@override String get first => '第一';
	@override String get nanzi => '楠梓';
	@override String get qijin => '旗津';
	@override String get unknown => '不明';
	@override String get campus => 'キャンパス';
	@override String get reserve => '予約';
	@override String get reserved => '予約済み';
	@override String get canNotReserve => '予約不可';
	@override String get specialBus => '特別便';
	@override String get trialBus => '試験運行';
	@override String get busReserveSuccess => '予約成功！';
	@override String get busReserveCancelDate => 'キャンセル日';
	@override String get busReserveCancelLocation => '乗車場所';
	@override String get busReserveCancelTime => 'キャンセル便';
	@override String get busCancelReserveSuccess => 'キャンセル成功！';
	@override String get busCancelReserveFail => 'キャンセル失敗';
	@override String get busReservationEmpty => 'まだバスを予約していません〜\n公共交通機関を利用して、地球を守りましょう 😋';
	@override String get busReserveFailTitle => '予約失敗';
	@override String get iKnow => '了解';
	@override String get busEmpty => '本日はバスがありません〜\n別の日を選択してください 😋';
	@override String busNotPick({required Object date}) => '日付が選択されていません！\n先に日付を選択してください ${date}';
	@override String get busNotifyHint => '発車30分前にリマインダーが届きます！';
	@override String busNotifyContent({required Object start, required Object end}) => '${start}に${end}から発車するバスがあります！';
	@override String get busNotifyJiangong => '建工';
	@override String get busNotifyYanchao => '燕巣';
	@override String get busNotify => 'バスリマインダー';
	@override String get busNotifySubTitle => '発車30分前に通知';
	@override String get bus => 'シャトルバス';
	@override String get fromJiangong => '建工から乗車';
	@override String get fromYanchao => '燕巣から乗車';
	@override String get fromFirst => '第一から乗車';
	@override String get destination => '目的地';
	@override String get reserving => '予約中...';
	@override String get canceling => 'キャンセル中...';
	@override String get busFailInfinity => 'バスシステムに問題が発生しました〜';
	@override String get reserveDeadline => '予約締め切り';
	@override String get busRule => 'バス乗車規則';
	@override String get firstLoginHint => '初回ログインのパスワードは身分証番号の下4桁です';
	@override String searchStudentIdFormat({required Object name, required Object id}) => '氏名：${name}\n学籍番号：${id}\n';
	@override String get noExpiration => '期限なし';
	@override String get punch => '打刻';
	@override String get punchSuccess => '打刻成功';
	@override String get nonCourseTime => '授業時間外';
	@override String get offlineScore => 'オフライン成績';
	@override String get offlineBusReservations => 'オフラインバス予約';
	@override String get offlineLeaveData => 'オフライン欠席データ';
	@override String get busViolationRecordEmpty => '素晴らしい！バス違反記録はありません～';
	@override String get schoolCloseCourseHint => '学校が時間割を閉鎖しています';
	@override String get loginAuth => 'ログイン認証';
	@override String get clickShowDescription => '説明を見る';
	@override String get mobileNkustLoginHint => 'ページの読み込みを待ちます';
	@override String get mobileNkustLoginDescription => 'モバイル版校務システムでログインする必要があります';
	@override String get leaveApplyRecord => '休暇申請履歴';
	@override String get reportNetProblem => 'ネットワーク問題を報告';
	@override String get reportNetProblemSubTitle => 'ネットワークの問題を報告';
	@override String get reportProblem => '問題を報告';
	@override String get enrollmentLetter => '在学証明書';
	@override String get themeColor => 'テーマカラー';
	@override String get traditionalChinese => '繁体字中国語';
	@override String get followSystem => 'システムに従う';
	@override String get reportOptions => '報告オプション';
	@override String get reportAppBug => 'アプリの問題を報告';
	@override String get reportAppBugSubtitle => '機能の異常、クラッシュなど';
	@override String get featureSuggestion => '機能提案';
	@override String get featureSuggestionSubtitle => '新機能や改善の提案';
	@override String get needHelp => 'お困りですか？';
	@override String get selectReportOption => '問題を報告または提案してください';
	@override String get searchStudentId => '学籍番号検索';
	@override String get studentIdBarcode => '学生証バーコード';
	@override String get useStudentIdInLibrary => '図書館でこの学籍番号を使用';
	@override String get tapToLogin => 'タップしてログイン';
	@override String get nkustBlue => '高科ブルー';
	@override String get oceanBlue => 'オーシャンブルー';
	@override String get emeraldGreen => 'エメラルドグリーン';
	@override String get coralOrange => 'コーラルオレンジ';
	@override String get elegantPurple => 'エレガントパープル';
	@override String get roseRed => 'ローズレッド';
	@override String get cyan => 'シアン';
	@override String get amber => 'アンバー';
	@override String get indigoBlue => 'インディゴブルー';
	@override String get brownTan => 'ブラウンタン';
	@override String get customColor => 'カスタム';
	@override String get selectThemeColor => 'テーマカラーを選択';
	@override String get cancel => 'キャンセル';
	@override String get confirm => '確定';
	@override String get hue => '色相';
	@override String get saturation => '彩度';
	@override String get brightness => '明度';
	@override String get monday => '月';
	@override String get tuesday => '火';
	@override String get wednesday => '水';
	@override String get thursday => '木';
	@override String get friday => '金';
	@override String get saturday => '土';
	@override String get sunday => '日';
	@override String get period => '限';
	@override String get instructor => '担当教員';
	@override String get classLocation => '教室';
	@override String get credits => '単位数';
	@override String get creditsUnit => '単位';
	@override String get classTime => '授業時間';
	@override String get className => 'クラス';
	@override String get close => '閉じる';
	@override String get weekDay => '週';
	@override String periodNumber({required Object number}) => '第${number}限';
	@override String get listMode => 'リストモード';
	@override String get tableMode => '表モード';
	@override String get loadingCourse => '時間割を読み込み中...';
	@override String get tapToRetry => 'タップして再試行';
	@override String get courseDetails => '科目詳細';
	@override String get scoreOverview => '成績概要';
	@override String get loadingScore => '成績を読み込み中...';
	@override String get estimatedPR => '推定PR値';
	@override String get prDisclaimer => '※ PR値は参考程度です';
	@override String get scoreStatistics => '成績統計';
	@override String get highestScore => '最高点';
	@override String get lowestScore => '最低点';
	@override String get standardDeviation => '標準偏差';
	@override String get subjectCount => '科目数';
	@override String get scoreDistribution => '成績分布';
	@override String get excellent => '優秀';
	@override String get good => '良好';
	@override String get average => '普通';
	@override String get pass => '合格';
	@override String get fail => '不合格';
	@override String subjectCountUnit({required Object count}) => '${count}科目';
	@override String get creditStatistics => '単位統計';
	@override String get enrolledCredits => '履修単位';
	@override String get passedCredits => '合格単位';
	@override String get failedCredits => '不合格単位';
	@override String midtermScore({required Object score}) => '中間: ${score}';
	@override String get prTop => 'トップ';
	@override String get prExcellent => '優秀';
	@override String get prAverage => '中程度';
	@override String get prNeedsImprovement => '要努力';
	@override String get prNeedsEffort => '頑張れ';
	@override String get firstSemester => '前期';
	@override String get secondSemester => '後期';
	@override String get winterSession => '冬期講習';
	@override String get summerSession => '夏期講習';
	@override String get preSemester => '先修';
	@override String get summerSessionOne => '夏期(1)';
	@override String get summerSessionSpecial => '夏期(特別)';
	@override String academicYear({required Object year}) => '${year}年度';
	@override String get loading => '読み込み中';
	@override String get noData => 'データなし';
	@override String get currentSemester => '現在';
	@override String get noEnrollmentData => '在学証明書のデータがありません';
	@override String get noEnrollmentAvailable => '在学証明書がダウンロードできません';
	@override String get invalidPdfFormat => '有効なPDFを取得できません';
	@override String networkError({required Object message}) => 'ネットワークエラー：${message}';
	@override String loadFailed({required Object message}) => '読み込み失敗：${message}';
	@override String get loginFailedFiveTimes => 'ログインに5回失敗しました！';
	@override String projectCount({required Object count}) => '${count}プロジェクト';
	@override String get openSourceLicense => 'オープンソースライセンス';
	@override String get nkustLocation => '高雄科技大学';
	@override String get busRuleReservationRuleTitle => 'バス予約\n';
	@override String get busRuleTravelBy => '• 下記サイトで予約してください ';
	@override String get busRuleFourteenDay => '• バス予約システムで予約\n• 14日以内のバスを予約可能\n• 総務処の配車需要に合わせた予約時間\n';
	@override String get busRuleReservationTime => '■ 9時前の便：発車15時間前までに予約\n■ 9時以降の便：発車5時間前までに予約\n';
	@override String get busRuleCancellingTitle => '• 予約キャンセル時間\n';
	@override String get busRuleCancelingTime => '■ 9時前の便：発車15時間前までにキャンセル\n■ 9時以降の便：発車5時間前までにキャンセル\n';
	@override String get busRuleFollow => '• 教職員・学生は規定に従ってバスを予約してください。予約なしで授業に遅刻した場合は自己責任となります\n';
	@override String get busRuleTakeOn => '乗車\n';
	@override String get busRuleTwentyDollars => '• 乗車毎に20元を支払う';
	@override String get busRulePrepareCoins => '（学生証未発行の場合はコイン投入、20元硬貨をご用意ください）\n';
	@override String get busRuleIdCard => '• 学生証または教職員証（未発行の場合は身分証）を持って乗車\n';
	@override String get busRuleNoIdCard => '• 証明書を持参していない場合は補欠エリアに並んでください\n';
	@override String get busRuleFollowingTime => '• 予約した便の時間に従って乗車してください（例：8:20と9:30は別便）、規定に従わない場合は乗車不可、違反1点\n';
	@override String get busRuleLateAndNoReservation => '• 遅刻または予約なしの乗客は補欠レーンで待機してください\n補欠乗車\n• 正規レーンで認証に通らなかった場合（例：該当便を予約していない）、補欠レーンで待機してください\n• 補欠者は予約者全員が乗車した後に順次乗車\n';
	@override String get busRuleStandbyTitle => '補欠乗車\n';
	@override String get busRuleStandbyRule => '• 予約した便以外に乗車した場合は違反となり、違反1点（例：8:20と9:30は別便）\n• 教師の急な休講や時間変更により早めまたは遅めの乗車が必要な場合、所属学科に申請し、管理者が違反記録を取り消すことができます\n';
	@override String get busRuleFineTitle => '罰金\n';
	@override String get busRuleFineRule => '• 違反罰金の計算：最初の3回は無点、4回目から違反点数を記録、各点は運賃相当の罰金\n• 違反点数は学期末まで統計（前期1/31、後期8/31）、新学期で再計算。罰金未払いの場合、翌学期は予約権限停止\n• 罰金は違反明細を印刷後、自動支払機または総務処出納組で支払い\n• 違反点数に疑問がある場合、違反発生日から10日以内に総務処事務組で確認してください\n';
	@override String get otherBuilding => 'その他';
}

/// The flat map containing all translations for locale <ja>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on NkustLocalizationsJa {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'appName' => '高科校務通',
			'updateNoteContent' => '* 一部のデバイスでホームウィジェットが表示されない問題を修正',
			'aboutOpenSourceContent' => 'https://github.com/NKUST-ITC/NKUST-AP-Flutter\n\n本プロジェクトはMITオープンソースライセンスを採用しています：\nThe MIT License (MIT)\n\nCopyright © 2021 Rainvisitor',
			'busPickDate' => ({required Object date}) => '乗車日時を選択：${date}',
			'busNotPickDate' => '乗車日時を選択',
			'busCount' => ({required Object current, required Object total}) => '(${current} / ${total})',
			'busJiangongReservations' => '燕巣行き、発車日：',
			'busYanchaoReservations' => '建工行き、発車日：',
			'busJiangong' => '燕巣行き、発車：',
			'busYanchao' => '建工行き、発車：',
			'busJiangongReserved' => '√ 燕巣行き、発車：',
			'busYanchaoReserved' => '√ 建工行き、発車：',
			'busReserve' => 'シャトルバス予約',
			'busReservations' => 'バス予約履歴',
			'busViolationRecords' => 'バス違反記録',
			'unpaid' => '未払い',
			'paid' => '支払済み',
			'busCancelReserve' => '予約をキャンセル',
			'busReserveConfirmTitle' => 'このバスを予約しますか？',
			'busReserveConfirmContent' => ({required Object location, required Object time}) => '${location}から${time}のバスを予約しますか？',
			'busCancelReserveConfirmTitle' => 'この予約を<b>キャンセル</b>しますか？',
			'busCancelReserveConfirmContent' => ({required Object location, required Object time}) => '${location}から${time}のバスをキャンセルしますか？',
			'busCancelReserveConfirmContent1' => '予約をキャンセル：',
			'busCancelReserveConfirmContent2' => 'から',
			'busCancelReserveConfirmContent3' => 'へ？',
			'busFromJiangong' => '建工から燕巣',
			'busFromYanchao' => '燕巣から建工',
			'busReserveDate' => '予約日',
			'busReserveLocation' => '乗車場所',
			'busReserveTime' => '予約便',
			'jiangong' => '建工',
			'yanchao' => '燕巣',
			'first' => '第一',
			'nanzi' => '楠梓',
			'qijin' => '旗津',
			'unknown' => '不明',
			'campus' => 'キャンパス',
			'reserve' => '予約',
			'reserved' => '予約済み',
			'canNotReserve' => '予約不可',
			'specialBus' => '特別便',
			'trialBus' => '試験運行',
			'busReserveSuccess' => '予約成功！',
			'busReserveCancelDate' => 'キャンセル日',
			'busReserveCancelLocation' => '乗車場所',
			'busReserveCancelTime' => 'キャンセル便',
			'busCancelReserveSuccess' => 'キャンセル成功！',
			'busCancelReserveFail' => 'キャンセル失敗',
			'busReservationEmpty' => 'まだバスを予約していません〜\n公共交通機関を利用して、地球を守りましょう 😋',
			'busReserveFailTitle' => '予約失敗',
			'iKnow' => '了解',
			'busEmpty' => '本日はバスがありません〜\n別の日を選択してください 😋',
			'busNotPick' => ({required Object date}) => '日付が選択されていません！\n先に日付を選択してください ${date}',
			'busNotifyHint' => '発車30分前にリマインダーが届きます！',
			'busNotifyContent' => ({required Object start, required Object end}) => '${start}に${end}から発車するバスがあります！',
			'busNotifyJiangong' => '建工',
			'busNotifyYanchao' => '燕巣',
			'busNotify' => 'バスリマインダー',
			'busNotifySubTitle' => '発車30分前に通知',
			'bus' => 'シャトルバス',
			'fromJiangong' => '建工から乗車',
			'fromYanchao' => '燕巣から乗車',
			'fromFirst' => '第一から乗車',
			'destination' => '目的地',
			'reserving' => '予約中...',
			'canceling' => 'キャンセル中...',
			'busFailInfinity' => 'バスシステムに問題が発生しました〜',
			'reserveDeadline' => '予約締め切り',
			'busRule' => 'バス乗車規則',
			'firstLoginHint' => '初回ログインのパスワードは身分証番号の下4桁です',
			'searchStudentIdFormat' => ({required Object name, required Object id}) => '氏名：${name}\n学籍番号：${id}\n',
			'noExpiration' => '期限なし',
			'punch' => '打刻',
			'punchSuccess' => '打刻成功',
			'nonCourseTime' => '授業時間外',
			'offlineScore' => 'オフライン成績',
			'offlineBusReservations' => 'オフラインバス予約',
			'offlineLeaveData' => 'オフライン欠席データ',
			'busViolationRecordEmpty' => '素晴らしい！バス違反記録はありません～',
			'schoolCloseCourseHint' => '学校が時間割を閉鎖しています',
			'loginAuth' => 'ログイン認証',
			'clickShowDescription' => '説明を見る',
			'mobileNkustLoginHint' => 'ページの読み込みを待ちます',
			'mobileNkustLoginDescription' => 'モバイル版校務システムでログインする必要があります',
			'leaveApplyRecord' => '休暇申請履歴',
			'reportNetProblem' => 'ネットワーク問題を報告',
			'reportNetProblemSubTitle' => 'ネットワークの問題を報告',
			'reportProblem' => '問題を報告',
			'enrollmentLetter' => '在学証明書',
			'themeColor' => 'テーマカラー',
			'traditionalChinese' => '繁体字中国語',
			'followSystem' => 'システムに従う',
			'reportOptions' => '報告オプション',
			'reportAppBug' => 'アプリの問題を報告',
			'reportAppBugSubtitle' => '機能の異常、クラッシュなど',
			'featureSuggestion' => '機能提案',
			'featureSuggestionSubtitle' => '新機能や改善の提案',
			'needHelp' => 'お困りですか？',
			'selectReportOption' => '問題を報告または提案してください',
			'searchStudentId' => '学籍番号検索',
			'studentIdBarcode' => '学生証バーコード',
			'useStudentIdInLibrary' => '図書館でこの学籍番号を使用',
			'tapToLogin' => 'タップしてログイン',
			'nkustBlue' => '高科ブルー',
			'oceanBlue' => 'オーシャンブルー',
			'emeraldGreen' => 'エメラルドグリーン',
			'coralOrange' => 'コーラルオレンジ',
			'elegantPurple' => 'エレガントパープル',
			'roseRed' => 'ローズレッド',
			'cyan' => 'シアン',
			'amber' => 'アンバー',
			'indigoBlue' => 'インディゴブルー',
			'brownTan' => 'ブラウンタン',
			'customColor' => 'カスタム',
			'selectThemeColor' => 'テーマカラーを選択',
			'cancel' => 'キャンセル',
			'confirm' => '確定',
			'hue' => '色相',
			'saturation' => '彩度',
			'brightness' => '明度',
			'monday' => '月',
			'tuesday' => '火',
			'wednesday' => '水',
			'thursday' => '木',
			'friday' => '金',
			'saturday' => '土',
			'sunday' => '日',
			'period' => '限',
			'instructor' => '担当教員',
			'classLocation' => '教室',
			'credits' => '単位数',
			'creditsUnit' => '単位',
			'classTime' => '授業時間',
			'className' => 'クラス',
			'close' => '閉じる',
			'weekDay' => '週',
			'periodNumber' => ({required Object number}) => '第${number}限',
			'listMode' => 'リストモード',
			'tableMode' => '表モード',
			'loadingCourse' => '時間割を読み込み中...',
			'tapToRetry' => 'タップして再試行',
			'courseDetails' => '科目詳細',
			'scoreOverview' => '成績概要',
			'loadingScore' => '成績を読み込み中...',
			'estimatedPR' => '推定PR値',
			'prDisclaimer' => '※ PR値は参考程度です',
			'scoreStatistics' => '成績統計',
			'highestScore' => '最高点',
			'lowestScore' => '最低点',
			'standardDeviation' => '標準偏差',
			'subjectCount' => '科目数',
			'scoreDistribution' => '成績分布',
			'excellent' => '優秀',
			'good' => '良好',
			'average' => '普通',
			'pass' => '合格',
			'fail' => '不合格',
			'subjectCountUnit' => ({required Object count}) => '${count}科目',
			'creditStatistics' => '単位統計',
			'enrolledCredits' => '履修単位',
			'passedCredits' => '合格単位',
			'failedCredits' => '不合格単位',
			'midtermScore' => ({required Object score}) => '中間: ${score}',
			'prTop' => 'トップ',
			'prExcellent' => '優秀',
			'prAverage' => '中程度',
			'prNeedsImprovement' => '要努力',
			'prNeedsEffort' => '頑張れ',
			'firstSemester' => '前期',
			'secondSemester' => '後期',
			'winterSession' => '冬期講習',
			'summerSession' => '夏期講習',
			'preSemester' => '先修',
			'summerSessionOne' => '夏期(1)',
			'summerSessionSpecial' => '夏期(特別)',
			'academicYear' => ({required Object year}) => '${year}年度',
			'loading' => '読み込み中',
			'noData' => 'データなし',
			'currentSemester' => '現在',
			'noEnrollmentData' => '在学証明書のデータがありません',
			'noEnrollmentAvailable' => '在学証明書がダウンロードできません',
			'invalidPdfFormat' => '有効なPDFを取得できません',
			'networkError' => ({required Object message}) => 'ネットワークエラー：${message}',
			'loadFailed' => ({required Object message}) => '読み込み失敗：${message}',
			'loginFailedFiveTimes' => 'ログインに5回失敗しました！',
			'projectCount' => ({required Object count}) => '${count}プロジェクト',
			'openSourceLicense' => 'オープンソースライセンス',
			'nkustLocation' => '高雄科技大学',
			'busRuleReservationRuleTitle' => 'バス予約\n',
			'busRuleTravelBy' => '• 下記サイトで予約してください ',
			'busRuleFourteenDay' => '• バス予約システムで予約\n• 14日以内のバスを予約可能\n• 総務処の配車需要に合わせた予約時間\n',
			'busRuleReservationTime' => '■ 9時前の便：発車15時間前までに予約\n■ 9時以降の便：発車5時間前までに予約\n',
			'busRuleCancellingTitle' => '• 予約キャンセル時間\n',
			'busRuleCancelingTime' => '■ 9時前の便：発車15時間前までにキャンセル\n■ 9時以降の便：発車5時間前までにキャンセル\n',
			'busRuleFollow' => '• 教職員・学生は規定に従ってバスを予約してください。予約なしで授業に遅刻した場合は自己責任となります\n',
			'busRuleTakeOn' => '乗車\n',
			'busRuleTwentyDollars' => '• 乗車毎に20元を支払う',
			'busRulePrepareCoins' => '（学生証未発行の場合はコイン投入、20元硬貨をご用意ください）\n',
			'busRuleIdCard' => '• 学生証または教職員証（未発行の場合は身分証）を持って乗車\n',
			'busRuleNoIdCard' => '• 証明書を持参していない場合は補欠エリアに並んでください\n',
			'busRuleFollowingTime' => '• 予約した便の時間に従って乗車してください（例：8:20と9:30は別便）、規定に従わない場合は乗車不可、違反1点\n',
			'busRuleLateAndNoReservation' => '• 遅刻または予約なしの乗客は補欠レーンで待機してください\n補欠乗車\n• 正規レーンで認証に通らなかった場合（例：該当便を予約していない）、補欠レーンで待機してください\n• 補欠者は予約者全員が乗車した後に順次乗車\n',
			'busRuleStandbyTitle' => '補欠乗車\n',
			'busRuleStandbyRule' => '• 予約した便以外に乗車した場合は違反となり、違反1点（例：8:20と9:30は別便）\n• 教師の急な休講や時間変更により早めまたは遅めの乗車が必要な場合、所属学科に申請し、管理者が違反記録を取り消すことができます\n',
			'busRuleFineTitle' => '罰金\n',
			'busRuleFineRule' => '• 違反罰金の計算：最初の3回は無点、4回目から違反点数を記録、各点は運賃相当の罰金\n• 違反点数は学期末まで統計（前期1/31、後期8/31）、新学期で再計算。罰金未払いの場合、翌学期は予約権限停止\n• 罰金は違反明細を印刷後、自動支払機または総務処出納組で支払い\n• 違反点数に疑問がある場合、違反発生日から10日以内に総務処事務組で確認してください\n',
			'otherBuilding' => 'その他',
			_ => null,
		};
	}
}
