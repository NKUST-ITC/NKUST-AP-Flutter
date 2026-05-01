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
class NkustLocalizationsEn extends NkustLocalizations with BaseTranslations<NkustLocale, NkustLocalizations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [NkustLocale.build] is preferred.
	NkustLocalizationsEn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<NkustLocale, NkustLocalizations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: NkustLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<NkustLocale, NkustLocalizations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final NkustLocalizationsEn _root = this; // ignore: unused_field

	@override 
	NkustLocalizationsEn $copyWith({TranslationMetadata<NkustLocale, NkustLocalizations>? meta}) => NkustLocalizationsEn(meta: meta ?? this.$meta);

	// Translations
	@override String get appName => 'NKUST AP';
	@override String get updateNoteContent => '* Fix part of device home widget error.';
	@override String get aboutOpenSourceContent => 'https://github.com/NKUST-ITC/NKUST-AP-Flutter\n\nThis project is licensed under the terms of the MIT license:\nThe MIT License (MIT)\n\nCopyright © 2021 Rainvisitor\n\nThis project is Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.';
	@override String busPickDate({required Object date}) => 'Chosen Date: ${date}';
	@override String get busNotPickDate => 'Chosen Date';
	@override String busCount({required Object current, required Object total}) => '(${current} / ${total})';
	@override String get busJiangongReservations => 'To YanChao, Scheduled date：';
	@override String get busYanchaoReservations => 'To JianGong, Scheduled date：';
	@override String get busJiangong => 'To YanChao, Departure time：';
	@override String get busYanchao => 'To JianGong, Departure time：';
	@override String get busJiangongReserved => '√ To YanChao, Departure time：';
	@override String get busYanchaoReserved => '√ To JianGong, Departure time：';
	@override String get busReserve => 'Bus Reservation';
	@override String get busReservations => 'Bus Record';
	@override String get busViolationRecords => 'Bus Penalty';
	@override String get unpaid => 'Unpaid';
	@override String get paid => 'Paid';
	@override String get busCancelReserve => 'Cancel Bus Reservation';
	@override String get busReserveConfirmTitle => 'Reserve this bus?';
	@override String busReserveConfirmContent({required Object location, required Object time}) => 'Are you sure to reserve a seat from ${location} at ${time} ?';
	@override String get busCancelReserveConfirmTitle => '<b>Cancel</b> this reservation?';
	@override String busCancelReserveConfirmContent({required Object location, required Object time}) => 'Are you sure to cancel a seat from ${location} at ${time} ?';
	@override String get busCancelReserveConfirmContent1 => 'Are you sure to cancel a seat from ';
	@override String get busCancelReserveConfirmContent2 => ' to ';
	@override String get busCancelReserveConfirmContent3 => ' ?';
	@override String get busFromJiangong => 'JianGong to YanChao';
	@override String get busFromYanchao => 'YanChao to JianGong';
	@override String get busReserveDate => 'Date';
	@override String get busReserveLocation => 'Location';
	@override String get busReserveTime => 'Time';
	@override String get jiangong => 'JianGong';
	@override String get yanchao => 'YanChao';
	@override String get first => 'First';
	@override String get nanzi => 'Nanzi';
	@override String get qijin => 'Qijin';
	@override String get unknown => 'Unknown';
	@override String get campus => 'Campus';
	@override String get reserve => 'Reserve';
	@override String get reserved => 'Reserved';
	@override String get canNotReserve => 'Can\'t reserve';
	@override String get specialBus => 'Special Bus';
	@override String get trialBus => 'Trial Bus';
	@override String get busReserveSuccess => 'Successfully Reserved!';
	@override String get busReserveCancelDate => 'Date';
	@override String get busReserveCancelLocation => 'Location';
	@override String get busReserveCancelTime => 'Time';
	@override String get busCancelReserveSuccess => 'Successfully Canceled!';
	@override String get busCancelReserveFail => 'Fail Canceled';
	@override String get busReservationEmpty => 'Oops! You haven\'t reserved any bus~\n Ride public transport to save the Earth 😋';
	@override String get busReserveFailTitle => 'Oops! Reserve Failed';
	@override String get iKnow => 'I know';
	@override String get busEmpty => 'Oops! No bus today~\n Please choose another date 😋';
	@override String busNotPick({required Object date}) => 'You have not chosen a date!\n Please choose a date first ${date}';
	@override String get busNotifyHint => 'Reminder will pop up 30 mins before reserved bus !\nIf you reserved or canceled the seat via website, please restart the app.';
	@override String busNotifyContent({required Object start, required Object end}) => 'You\'ve got a bus departing at ${start} from ${end}!';
	@override String get busNotifyJiangong => 'JianGong';
	@override String get busNotifyYanchao => 'YanChao';
	@override String get busNotify => 'Bus Reservation Reminder';
	@override String get busNotifySubTitle => 'Reminder 30 mins before reserved bus';
	@override String get bus => 'Bus Reservation';
	@override String get fromJiangong => 'From JianGong';
	@override String get fromYanchao => 'From YanChao';
	@override String get fromFirst => 'From First';
	@override String get destination => 'Destination';
	@override String get reserving => 'Reserving...';
	@override String get canceling => 'Canceling...';
	@override String get busFailInfinity => 'Bus system perhaps broken!!!';
	@override String get reserveDeadline => 'Reserve Deadline';
	@override String get busRule => 'Bus Rule';
	@override String get firstLoginHint => 'For first-time login, please fill in the last four number of your ID as your password';
	@override String searchStudentIdFormat({required Object name, required Object id}) => 'Name：${name}\nStudent ID：${id}\n';
	@override String get noExpiration => 'No Expiration';
	@override String get punch => 'Punch';
	@override String get punchSuccess => 'Punch Success';
	@override String get nonCourseTime => 'Non Course Time';
	@override String get offlineScore => 'Offline Score';
	@override String get offlineBusReservations => 'Offline Bus Reservations';
	@override String get offlineLeaveData => 'Offline Absent Report';
	@override String get busRuleReservationRuleTitle => 'Bus Reservation\n';
	@override String get busRuleTravelBy => '• Go to ';
	@override String get busRuleFourteenDay => ' Bus Reservation System can reserve bus in 14 days\nin need to follow office of general affairs\'s time requirement\n';
	@override String get busRuleReservationTime => '■ The classes before 9 A.M.：Please do reservation in 15 hours ago.\n■ The classes after 9 A.M.：Please do reservation in 5 hours ago\n';
	@override String get busRuleCancellingTitle => '• Cancellation Time\n';
	@override String get busRuleCancelingTime => '■ The classes before 9 A.M.：Please do cancellation in 15 hours ago.\n■ The classes after 9 A.M.：Please do cancellation in 5 hours ago\n';
	@override String get busRuleFollow => '• All students, teachers and staff reserve bus should be follow the rule，if you late or absent from class or work, please be responsible of whatever you do.\n';
	@override String get busRuleTakeOn => 'Take Bus\n';
	@override String get busRuleTwentyDollars => '• Every time take bus need pay 20 NTD';
	@override String get busRulePrepareCoins => '（Use coin when you don\'t got Student ID，Please prepare 20 dollars coin first.）\n';
	@override String get busRuleIdCard => '• Please take your student or staff ID(Before you get student or staff ID, Please use your ID) take bus\n';
	@override String get busRuleNoIdCard => '• If you don\'t take any ID, please line up standby zone\n';
	@override String get busRuleFollowingTime => 'Please follow the bus schedule (ex. 8:20 and 9:30 is different class), People can\'t take bus and get violation point who don\'t follow rule.\n';
	@override String get busRuleLateAndNoReservation => '• Late or don\'t reserved passenger, please line up standby zone waiting.\nStandby\n• If you can\'t pass verification(ex. Don\'t reserved)，Please change to standby zone waiting.\n"• Standby passenger can get on the bus in order after waiting all reserved passengers got on the bus.\n';
	@override String get busRuleStandbyTitle => 'Standby\n';
	@override String get busRuleStandbyRule => '• If you don\'t take the bus but you reserved already，It\'s a violation，and you get a violation point(ex. 8:20 and 9:30 is different class\n• If your class teacher take temporary leave、transfer cause you need take the bus early or lately，you need apply to class department then，department bus system administrator will logout violation.\n';
	@override String get busRuleFineTitle => 'Fine\n';
	@override String get busRuleFineRule => '• Fine Calculation，violation times below 3 times don\'t get point, From 4th violation begin recording point，every point should be pay off fine equal to bus fare.\n• Violation point recording until the end of the semester(1st Semester ended at 1/31，2nd Semester ended at 8/31)，violation point will restart recording. When you not paid off fine，next semester will stop your reservation right until you pay off fine.\n• Go to the auto payment machine or Office of General Affairs cashier pay off fine after you print violation statement by yourself, After paid off, go to Office of General Affairs General Affairs Division write off payment by receipt(Write off payment need receipt on the day.)，After write off and the next day 4A.M. will be reserve class after 9.A.M..\n• If you have any suspicion about violation point，please go to Office of General Affairs General Affairs Division check violation directly in 10 days(included holidays).\n';
	@override String get busViolationRecordEmpty => 'Good！No any bus violation record～';
	@override String get schoolCloseCourseHint => 'School close course system, we can\'t solve it temporarily.\nAny problems are recommended to the school.';
	@override String get loginAuth => 'Login Authentication';
	@override String get clickShowDescription => 'Description';
	@override String get mobileNkustLoginHint => 'Wait for the webpage to finish loading, the student ID and password will be filled in automatically.\nAfter completing the Google reCaptcha and clicking login, it will automatically redirected.';
	@override String get mobileNkustLoginDescription => 'Because the school has closed the original crawler function, this version needs to be logged in through the new version of the mobile school system. After successful login, it will be redirected automatically. Unless the certificate expires, repeated verification is rarely required. It is strongly recommended to check "Remember me".';
	@override String get leaveApplyRecord => 'Apply Records';
	@override String get reportNetProblem => 'Report Net Problem';
	@override String get reportNetProblemSubTitle => 'Report encountered network problems';
	@override String get reportProblem => 'Report Problem (Requires school email login)';
	@override String get enrollmentLetter => 'Enrollment Letter';
	@override String get themeColor => 'Theme Color';
	@override String get traditionalChinese => 'Traditional Chinese';
	@override String get followSystem => 'Follow System';
	@override String get reportOptions => 'Report Options';
	@override String get reportAppBug => 'Report App Bug';
	@override String get reportAppBugSubtitle => 'Crashes, bugs, and other issues';
	@override String get featureSuggestion => 'Feature Suggestion';
	@override String get featureSuggestionSubtitle => 'Suggest new features or improvements';
	@override String get needHelp => 'Need Help?';
	@override String get selectReportOption => 'Select an option below to report an issue or provide suggestions';
	@override String get searchStudentId => 'Search Student ID';
	@override String get studentIdBarcode => 'Student ID Barcode';
	@override String get useStudentIdInLibrary => 'Use this student ID in the library';
	@override String get tapToLogin => 'Tap to Login';
	@override String get nkustBlue => 'NKUST Blue';
	@override String get oceanBlue => 'Ocean Blue';
	@override String get emeraldGreen => 'Emerald Green';
	@override String get coralOrange => 'Coral Orange';
	@override String get elegantPurple => 'Elegant Purple';
	@override String get roseRed => 'Rose Red';
	@override String get cyan => 'Cyan';
	@override String get amber => 'Amber';
	@override String get indigoBlue => 'Indigo Blue';
	@override String get brownTan => 'Brown Tan';
	@override String get customColor => 'Custom';
	@override String get selectThemeColor => 'Select Theme Color';
	@override String get cancel => 'Cancel';
	@override String get confirm => 'Confirm';
	@override String get hue => 'Hue';
	@override String get saturation => 'Saturation';
	@override String get brightness => 'Brightness';
	@override String get monday => 'Mon';
	@override String get tuesday => 'Tue';
	@override String get wednesday => 'Wed';
	@override String get thursday => 'Thu';
	@override String get friday => 'Fri';
	@override String get saturday => 'Sat';
	@override String get sunday => 'Sun';
	@override String get period => 'Period';
	@override String get instructor => 'Instructor';
	@override String get classLocation => 'Location';
	@override String get credits => 'Credits';
	@override String get creditsUnit => 'credits';
	@override String get classTime => 'Class Time';
	@override String get className => 'Class';
	@override String get close => 'Close';
	@override String get weekDay => 'Week';
	@override String periodNumber({required Object number}) => 'Period ${number}';
	@override String get listMode => 'List Mode';
	@override String get tableMode => 'Table Mode';
	@override String get loadingCourse => 'Loading course...';
	@override String get tapToRetry => 'Tap to retry';
	@override String get courseDetails => 'Course Details';
	@override String get scoreOverview => 'Score Overview';
	@override String get loadingScore => 'Loading scores...';
	@override String get estimatedPR => 'Estimated PR';
	@override String get prDisclaimer => '※ PR value is estimated based on average score, for reference only';
	@override String get scoreStatistics => 'Score Statistics';
	@override String get highestScore => 'Highest';
	@override String get lowestScore => 'Lowest';
	@override String get standardDeviation => 'Std Dev';
	@override String get subjectCount => 'Subjects';
	@override String get scoreDistribution => 'Score Distribution';
	@override String get excellent => 'Excellent';
	@override String get good => 'Good';
	@override String get average => 'Average';
	@override String get pass => 'Pass';
	@override String get fail => 'Fail';
	@override String subjectCountUnit({required Object count}) => '${count} subjects';
	@override String get creditStatistics => 'Credit Statistics';
	@override String get enrolledCredits => 'Enrolled';
	@override String get passedCredits => 'Passed';
	@override String get failedCredits => 'Failed';
	@override String midtermScore({required Object score}) => 'Midterm: ${score}';
	@override String get prTop => 'Top';
	@override String get prExcellent => 'Excellent';
	@override String get prAverage => 'Average';
	@override String get prNeedsImprovement => 'Needs Work';
	@override String get prNeedsEffort => 'Needs Effort';
	@override String get firstSemester => '1st Semester';
	@override String get secondSemester => '2nd Semester';
	@override String get winterSession => 'Winter Session';
	@override String get summerSession => 'Summer Session';
	@override String get preSemester => 'Pre-Semester';
	@override String get summerSessionOne => 'Summer (1)';
	@override String get summerSessionSpecial => 'Summer (Special)';
	@override String academicYear({required Object year}) => 'Year ${year}';
	@override String get loading => 'Loading';
	@override String get noData => 'No Data';
	@override String get currentSemester => 'Current';
	@override String get noEnrollmentData => 'No enrollment data found';
	@override String get noEnrollmentAvailable => 'Enrollment letter not available\nPlease check if you have applied';
	@override String get invalidPdfFormat => 'Unable to get valid PDF document';
	@override String networkError({required Object message}) => 'Network error: ${message}';
	@override String loadFailed({required Object message}) => 'Load failed: ${message}';
	@override String get loginFailedFiveTimes => 'You have failed to login 5 times!! Please try again after 30 minutes!!';
	@override String projectCount({required Object count}) => '${count} projects';
	@override String get openSourceLicense => 'Open Source License';
	@override String get nkustLocation => 'NKUST';
	@override String get otherBuilding => 'Other';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on NkustLocalizationsEn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'appName' => 'NKUST AP',
			'updateNoteContent' => '* Fix part of device home widget error.',
			'aboutOpenSourceContent' => 'https://github.com/NKUST-ITC/NKUST-AP-Flutter\n\nThis project is licensed under the terms of the MIT license:\nThe MIT License (MIT)\n\nCopyright © 2021 Rainvisitor\n\nThis project is Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.',
			'busPickDate' => ({required Object date}) => 'Chosen Date: ${date}',
			'busNotPickDate' => 'Chosen Date',
			'busCount' => ({required Object current, required Object total}) => '(${current} / ${total})',
			'busJiangongReservations' => 'To YanChao, Scheduled date：',
			'busYanchaoReservations' => 'To JianGong, Scheduled date：',
			'busJiangong' => 'To YanChao, Departure time：',
			'busYanchao' => 'To JianGong, Departure time：',
			'busJiangongReserved' => '√ To YanChao, Departure time：',
			'busYanchaoReserved' => '√ To JianGong, Departure time：',
			'busReserve' => 'Bus Reservation',
			'busReservations' => 'Bus Record',
			'busViolationRecords' => 'Bus Penalty',
			'unpaid' => 'Unpaid',
			'paid' => 'Paid',
			'busCancelReserve' => 'Cancel Bus Reservation',
			'busReserveConfirmTitle' => 'Reserve this bus?',
			'busReserveConfirmContent' => ({required Object location, required Object time}) => 'Are you sure to reserve a seat from ${location} at ${time} ?',
			'busCancelReserveConfirmTitle' => '<b>Cancel</b> this reservation?',
			'busCancelReserveConfirmContent' => ({required Object location, required Object time}) => 'Are you sure to cancel a seat from ${location} at ${time} ?',
			'busCancelReserveConfirmContent1' => 'Are you sure to cancel a seat from ',
			'busCancelReserveConfirmContent2' => ' to ',
			'busCancelReserveConfirmContent3' => ' ?',
			'busFromJiangong' => 'JianGong to YanChao',
			'busFromYanchao' => 'YanChao to JianGong',
			'busReserveDate' => 'Date',
			'busReserveLocation' => 'Location',
			'busReserveTime' => 'Time',
			'jiangong' => 'JianGong',
			'yanchao' => 'YanChao',
			'first' => 'First',
			'nanzi' => 'Nanzi',
			'qijin' => 'Qijin',
			'unknown' => 'Unknown',
			'campus' => 'Campus',
			'reserve' => 'Reserve',
			'reserved' => 'Reserved',
			'canNotReserve' => 'Can\'t reserve',
			'specialBus' => 'Special Bus',
			'trialBus' => 'Trial Bus',
			'busReserveSuccess' => 'Successfully Reserved!',
			'busReserveCancelDate' => 'Date',
			'busReserveCancelLocation' => 'Location',
			'busReserveCancelTime' => 'Time',
			'busCancelReserveSuccess' => 'Successfully Canceled!',
			'busCancelReserveFail' => 'Fail Canceled',
			'busReservationEmpty' => 'Oops! You haven\'t reserved any bus~\n Ride public transport to save the Earth 😋',
			'busReserveFailTitle' => 'Oops! Reserve Failed',
			'iKnow' => 'I know',
			'busEmpty' => 'Oops! No bus today~\n Please choose another date 😋',
			'busNotPick' => ({required Object date}) => 'You have not chosen a date!\n Please choose a date first ${date}',
			'busNotifyHint' => 'Reminder will pop up 30 mins before reserved bus !\nIf you reserved or canceled the seat via website, please restart the app.',
			'busNotifyContent' => ({required Object start, required Object end}) => 'You\'ve got a bus departing at ${start} from ${end}!',
			'busNotifyJiangong' => 'JianGong',
			'busNotifyYanchao' => 'YanChao',
			'busNotify' => 'Bus Reservation Reminder',
			'busNotifySubTitle' => 'Reminder 30 mins before reserved bus',
			'bus' => 'Bus Reservation',
			'fromJiangong' => 'From JianGong',
			'fromYanchao' => 'From YanChao',
			'fromFirst' => 'From First',
			'destination' => 'Destination',
			'reserving' => 'Reserving...',
			'canceling' => 'Canceling...',
			'busFailInfinity' => 'Bus system perhaps broken!!!',
			'reserveDeadline' => 'Reserve Deadline',
			'busRule' => 'Bus Rule',
			'firstLoginHint' => 'For first-time login, please fill in the last four number of your ID as your password',
			'searchStudentIdFormat' => ({required Object name, required Object id}) => 'Name：${name}\nStudent ID：${id}\n',
			'noExpiration' => 'No Expiration',
			'punch' => 'Punch',
			'punchSuccess' => 'Punch Success',
			'nonCourseTime' => 'Non Course Time',
			'offlineScore' => 'Offline Score',
			'offlineBusReservations' => 'Offline Bus Reservations',
			'offlineLeaveData' => 'Offline Absent Report',
			'busRuleReservationRuleTitle' => 'Bus Reservation\n',
			'busRuleTravelBy' => '• Go to ',
			'busRuleFourteenDay' => ' Bus Reservation System can reserve bus in 14 days\nin need to follow office of general affairs\'s time requirement\n',
			'busRuleReservationTime' => '■ The classes before 9 A.M.：Please do reservation in 15 hours ago.\n■ The classes after 9 A.M.：Please do reservation in 5 hours ago\n',
			'busRuleCancellingTitle' => '• Cancellation Time\n',
			'busRuleCancelingTime' => '■ The classes before 9 A.M.：Please do cancellation in 15 hours ago.\n■ The classes after 9 A.M.：Please do cancellation in 5 hours ago\n',
			'busRuleFollow' => '• All students, teachers and staff reserve bus should be follow the rule，if you late or absent from class or work, please be responsible of whatever you do.\n',
			'busRuleTakeOn' => 'Take Bus\n',
			'busRuleTwentyDollars' => '• Every time take bus need pay 20 NTD',
			'busRulePrepareCoins' => '（Use coin when you don\'t got Student ID，Please prepare 20 dollars coin first.）\n',
			'busRuleIdCard' => '• Please take your student or staff ID(Before you get student or staff ID, Please use your ID) take bus\n',
			'busRuleNoIdCard' => '• If you don\'t take any ID, please line up standby zone\n',
			'busRuleFollowingTime' => 'Please follow the bus schedule (ex. 8:20 and 9:30 is different class), People can\'t take bus and get violation point who don\'t follow rule.\n',
			'busRuleLateAndNoReservation' => '• Late or don\'t reserved passenger, please line up standby zone waiting.\nStandby\n• If you can\'t pass verification(ex. Don\'t reserved)，Please change to standby zone waiting.\n"• Standby passenger can get on the bus in order after waiting all reserved passengers got on the bus.\n',
			'busRuleStandbyTitle' => 'Standby\n',
			'busRuleStandbyRule' => '• If you don\'t take the bus but you reserved already，It\'s a violation，and you get a violation point(ex. 8:20 and 9:30 is different class\n• If your class teacher take temporary leave、transfer cause you need take the bus early or lately，you need apply to class department then，department bus system administrator will logout violation.\n',
			'busRuleFineTitle' => 'Fine\n',
			'busRuleFineRule' => '• Fine Calculation，violation times below 3 times don\'t get point, From 4th violation begin recording point，every point should be pay off fine equal to bus fare.\n• Violation point recording until the end of the semester(1st Semester ended at 1/31，2nd Semester ended at 8/31)，violation point will restart recording. When you not paid off fine，next semester will stop your reservation right until you pay off fine.\n• Go to the auto payment machine or Office of General Affairs cashier pay off fine after you print violation statement by yourself, After paid off, go to Office of General Affairs General Affairs Division write off payment by receipt(Write off payment need receipt on the day.)，After write off and the next day 4A.M. will be reserve class after 9.A.M..\n• If you have any suspicion about violation point，please go to Office of General Affairs General Affairs Division check violation directly in 10 days(included holidays).\n',
			'busViolationRecordEmpty' => 'Good！No any bus violation record～',
			'schoolCloseCourseHint' => 'School close course system, we can\'t solve it temporarily.\nAny problems are recommended to the school.',
			'loginAuth' => 'Login Authentication',
			'clickShowDescription' => 'Description',
			'mobileNkustLoginHint' => 'Wait for the webpage to finish loading, the student ID and password will be filled in automatically.\nAfter completing the Google reCaptcha and clicking login, it will automatically redirected.',
			'mobileNkustLoginDescription' => 'Because the school has closed the original crawler function, this version needs to be logged in through the new version of the mobile school system. After successful login, it will be redirected automatically. Unless the certificate expires, repeated verification is rarely required. It is strongly recommended to check "Remember me".',
			'leaveApplyRecord' => 'Apply Records',
			'reportNetProblem' => 'Report Net Problem',
			'reportNetProblemSubTitle' => 'Report encountered network problems',
			'reportProblem' => 'Report Problem (Requires school email login)',
			'enrollmentLetter' => 'Enrollment Letter',
			'themeColor' => 'Theme Color',
			'traditionalChinese' => 'Traditional Chinese',
			'followSystem' => 'Follow System',
			'reportOptions' => 'Report Options',
			'reportAppBug' => 'Report App Bug',
			'reportAppBugSubtitle' => 'Crashes, bugs, and other issues',
			'featureSuggestion' => 'Feature Suggestion',
			'featureSuggestionSubtitle' => 'Suggest new features or improvements',
			'needHelp' => 'Need Help?',
			'selectReportOption' => 'Select an option below to report an issue or provide suggestions',
			'searchStudentId' => 'Search Student ID',
			'studentIdBarcode' => 'Student ID Barcode',
			'useStudentIdInLibrary' => 'Use this student ID in the library',
			'tapToLogin' => 'Tap to Login',
			'nkustBlue' => 'NKUST Blue',
			'oceanBlue' => 'Ocean Blue',
			'emeraldGreen' => 'Emerald Green',
			'coralOrange' => 'Coral Orange',
			'elegantPurple' => 'Elegant Purple',
			'roseRed' => 'Rose Red',
			'cyan' => 'Cyan',
			'amber' => 'Amber',
			'indigoBlue' => 'Indigo Blue',
			'brownTan' => 'Brown Tan',
			'customColor' => 'Custom',
			'selectThemeColor' => 'Select Theme Color',
			'cancel' => 'Cancel',
			'confirm' => 'Confirm',
			'hue' => 'Hue',
			'saturation' => 'Saturation',
			'brightness' => 'Brightness',
			'monday' => 'Mon',
			'tuesday' => 'Tue',
			'wednesday' => 'Wed',
			'thursday' => 'Thu',
			'friday' => 'Fri',
			'saturday' => 'Sat',
			'sunday' => 'Sun',
			'period' => 'Period',
			'instructor' => 'Instructor',
			'classLocation' => 'Location',
			'credits' => 'Credits',
			'creditsUnit' => 'credits',
			'classTime' => 'Class Time',
			'className' => 'Class',
			'close' => 'Close',
			'weekDay' => 'Week',
			'periodNumber' => ({required Object number}) => 'Period ${number}',
			'listMode' => 'List Mode',
			'tableMode' => 'Table Mode',
			'loadingCourse' => 'Loading course...',
			'tapToRetry' => 'Tap to retry',
			'courseDetails' => 'Course Details',
			'scoreOverview' => 'Score Overview',
			'loadingScore' => 'Loading scores...',
			'estimatedPR' => 'Estimated PR',
			'prDisclaimer' => '※ PR value is estimated based on average score, for reference only',
			'scoreStatistics' => 'Score Statistics',
			'highestScore' => 'Highest',
			'lowestScore' => 'Lowest',
			'standardDeviation' => 'Std Dev',
			'subjectCount' => 'Subjects',
			'scoreDistribution' => 'Score Distribution',
			'excellent' => 'Excellent',
			'good' => 'Good',
			'average' => 'Average',
			'pass' => 'Pass',
			'fail' => 'Fail',
			'subjectCountUnit' => ({required Object count}) => '${count} subjects',
			'creditStatistics' => 'Credit Statistics',
			'enrolledCredits' => 'Enrolled',
			'passedCredits' => 'Passed',
			'failedCredits' => 'Failed',
			'midtermScore' => ({required Object score}) => 'Midterm: ${score}',
			'prTop' => 'Top',
			'prExcellent' => 'Excellent',
			'prAverage' => 'Average',
			'prNeedsImprovement' => 'Needs Work',
			'prNeedsEffort' => 'Needs Effort',
			'firstSemester' => '1st Semester',
			'secondSemester' => '2nd Semester',
			'winterSession' => 'Winter Session',
			'summerSession' => 'Summer Session',
			'preSemester' => 'Pre-Semester',
			'summerSessionOne' => 'Summer (1)',
			'summerSessionSpecial' => 'Summer (Special)',
			'academicYear' => ({required Object year}) => 'Year ${year}',
			'loading' => 'Loading',
			'noData' => 'No Data',
			'currentSemester' => 'Current',
			'noEnrollmentData' => 'No enrollment data found',
			'noEnrollmentAvailable' => 'Enrollment letter not available\nPlease check if you have applied',
			'invalidPdfFormat' => 'Unable to get valid PDF document',
			'networkError' => ({required Object message}) => 'Network error: ${message}',
			'loadFailed' => ({required Object message}) => 'Load failed: ${message}',
			'loginFailedFiveTimes' => 'You have failed to login 5 times!! Please try again after 30 minutes!!',
			'projectCount' => ({required Object count}) => '${count} projects',
			'openSourceLicense' => 'Open Source License',
			'nkustLocation' => 'NKUST',
			'otherBuilding' => 'Other',
			_ => null,
		};
	}
}
