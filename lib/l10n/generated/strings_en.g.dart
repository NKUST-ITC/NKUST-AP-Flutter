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
	@override String busReserveConfirmContent({required Object from, required Object time}) => 'Are you sure to reserve a seat from ${from} at ${time} ?';
	@override String get busCancelReserveConfirmTitle => '<b>Cancel</b> this reservation?';
	@override String busCancelReserveConfirmContent({required Object from, required Object time}) => 'Are you sure to cancel a seat from ${from} at ${time} ?';
	@override String get busCancelReserveConfirmContent1 => 'Are you sure to cancel a seat from ';
	@override String get busCancelReserveConfirmContent2 => ' to ';
	@override String get busCancelReserveConfirmContent3 => ' ?';
	@override String get busFromJiangong => 'JianGong to YanChao';
	@override String get busFromYanchao => 'YanChao to JianGong';
	@override String get reserve => 'Reserve';
	@override String get busReserveDate => 'Date';
	@override String get busReserveLocation => 'Location';
	@override String get busReserveTime => 'Time';
	@override String get jiangong => 'JianGong';
	@override String get yanchao => 'YanChao';
	@override String get first => 'first';
	@override String get nanzi => 'Nanzi';
	@override String get qijin => 'Qijin';
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
	@override String get busReserveFailTitle => 'Oops! Reservation Failed';
	@override String get busEmpty => 'Oops! No bus today~\n Please choose another date 😋';
	@override String busNotPick({required Object hint}) => 'You have not chosen a date!\n Please choose a date first ${hint}';
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
	@override String get canceling => 'Canceling...';
	@override String get busFailInfinity => 'Bus system perhaps broken!!!';
	@override String get reserveDeadline => 'Reserve Deadline';
	@override String get busRule => 'Bus Rule';
	@override String searchStudentIdFormat({required Object name, required Object id}) => 'Name：${name}\nStudent ID：${id}\n';
	@override String get punch => 'Punch';
	@override String get punchSuccess => 'Punch Success';
	@override String get nonCourseTime => 'Non Course Time';
	@override String get offlineBusReservations => 'Offline Bus Reservations';
	@override String get busRuleReservationRuleTitle => 'Bus Reservation\n';
	@override String get busRuleTravelBy => '• Go to ';
	@override String get busRuleFourteenDay => ' Bus Reservation System can reserve bus in 14 days\nin need to follow office of general affairs\'s time requirement\n';
	@override String get busRuleReservationTime => '■ The classes before 9 A.M.：Please do reservation in 15 hours ago.\n■ The classes after 9 A.M.：Please do reservation in 5 hours ago\n';
	@override String get busRuleCancellingTitle => '• Cancelation Time\n';
	@override String get busRuleCancelingTime => '■ The classes before 9 A.M.：Please do cancelation in 15 hours ago.\n■ The classes after 9 A.M.：Please do cancelation in 5 hours ago\n';
	@override String get busRuleFollow => '• All students, teachers and staff reserve bus should follow the rule. If you late or absent from class or work, please be responsible.\n';
	@override String get busRuleTakeOn => 'Take Bus\n';
	@override String get busRuleTwentyDollars => '• Every time take bus need pay 20 NTD';
	@override String get busRulePrepareCoins => '（Use coin when you don\'t got Student ID. Please prepare 20 dollars coin first.）\n';
	@override String get busRuleIdCard => '• Please take your student or staff ID (Before you get student or staff ID, Please use your ID) take bus\n';
	@override String get busRuleNoIdCard => '• If you don\'t take any ID, please line up standby zone\n';
	@override String get busRuleFollowingTime => 'Please follow the bus schedule (ex. 8:20 and 9:30 is different class), People can\'t take bus and get violation point who don\'t follow rule.\n';
	@override String get busRuleLateAndNoReservation => '• Late or don\'t reserved passenger, please line up standby zone waiting.\nStandby\n• If you can\'t pass verification (ex. Don\'t reserved), Please change to standby zone waiting.\n• Standby passenger can get on the bus in order after waiting all reserved passengers got on the bus.\n';
	@override String get busRuleStandbyTitle => 'Standby\n';
	@override String get busRuleStandbyRule => '• If you don\'t take the bus but you reserved already, it\'s a violation, and you get a violation point (ex. 8:20 and 9:30 is different class)\n• If your class teacher take temporary leave, transfer cause you need take the bus early or lately, you need apply to class department then, department bus system administrator will logout violation.\n';
	@override String get busRuleFineTitle => 'Fine\n';
	@override String get busRuleFineRule => '• Fine Calculation, violation times below 3 times don\'t get point, From 4th violation begin recording point, every point should be pay off fine equal to bus fare.\n• Violation point recording until the end of the semester (1st Semester ended at 1/31, 2nd Semester ended at 8/31), violation point will restart recording. When you not paid off fine, next semester will stop your reservation right until you pay off fine.\n• Go to the auto payment machine or Office of General Affairs cashier pay off fine after you print violation statement by yourself, After paid off, go to Office of General Affairs General Affairs Division write off payment by receipt (Write off payment need receipt on the day.), After write off and the next day 4A.M. will be reserve class after 9.A.M..\n• If you have any suspicion about violation point, please go to Office of General Affairs General Affairs Division check violation directly in 10 days (included holidays).\n';
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
	@override String get reserving => 'Reserving...';
	@override String get unknown => 'Unknown';
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
			'busReserveConfirmContent' => ({required Object from, required Object time}) => 'Are you sure to reserve a seat from ${from} at ${time} ?',
			'busCancelReserveConfirmTitle' => '<b>Cancel</b> this reservation?',
			'busCancelReserveConfirmContent' => ({required Object from, required Object time}) => 'Are you sure to cancel a seat from ${from} at ${time} ?',
			'busCancelReserveConfirmContent1' => 'Are you sure to cancel a seat from ',
			'busCancelReserveConfirmContent2' => ' to ',
			'busCancelReserveConfirmContent3' => ' ?',
			'busFromJiangong' => 'JianGong to YanChao',
			'busFromYanchao' => 'YanChao to JianGong',
			'reserve' => 'Reserve',
			'busReserveDate' => 'Date',
			'busReserveLocation' => 'Location',
			'busReserveTime' => 'Time',
			'jiangong' => 'JianGong',
			'yanchao' => 'YanChao',
			'first' => 'first',
			'nanzi' => 'Nanzi',
			'qijin' => 'Qijin',
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
			'busReserveFailTitle' => 'Oops! Reservation Failed',
			'busEmpty' => 'Oops! No bus today~\n Please choose another date 😋',
			'busNotPick' => ({required Object hint}) => 'You have not chosen a date!\n Please choose a date first ${hint}',
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
			'canceling' => 'Canceling...',
			'busFailInfinity' => 'Bus system perhaps broken!!!',
			'reserveDeadline' => 'Reserve Deadline',
			'busRule' => 'Bus Rule',
			'searchStudentIdFormat' => ({required Object name, required Object id}) => 'Name：${name}\nStudent ID：${id}\n',
			'punch' => 'Punch',
			'punchSuccess' => 'Punch Success',
			'nonCourseTime' => 'Non Course Time',
			'offlineBusReservations' => 'Offline Bus Reservations',
			'busRuleReservationRuleTitle' => 'Bus Reservation\n',
			'busRuleTravelBy' => '• Go to ',
			'busRuleFourteenDay' => ' Bus Reservation System can reserve bus in 14 days\nin need to follow office of general affairs\'s time requirement\n',
			'busRuleReservationTime' => '■ The classes before 9 A.M.：Please do reservation in 15 hours ago.\n■ The classes after 9 A.M.：Please do reservation in 5 hours ago\n',
			'busRuleCancellingTitle' => '• Cancelation Time\n',
			'busRuleCancelingTime' => '■ The classes before 9 A.M.：Please do cancelation in 15 hours ago.\n■ The classes after 9 A.M.：Please do cancelation in 5 hours ago\n',
			'busRuleFollow' => '• All students, teachers and staff reserve bus should follow the rule. If you late or absent from class or work, please be responsible.\n',
			'busRuleTakeOn' => 'Take Bus\n',
			'busRuleTwentyDollars' => '• Every time take bus need pay 20 NTD',
			'busRulePrepareCoins' => '（Use coin when you don\'t got Student ID. Please prepare 20 dollars coin first.）\n',
			'busRuleIdCard' => '• Please take your student or staff ID (Before you get student or staff ID, Please use your ID) take bus\n',
			'busRuleNoIdCard' => '• If you don\'t take any ID, please line up standby zone\n',
			'busRuleFollowingTime' => 'Please follow the bus schedule (ex. 8:20 and 9:30 is different class), People can\'t take bus and get violation point who don\'t follow rule.\n',
			'busRuleLateAndNoReservation' => '• Late or don\'t reserved passenger, please line up standby zone waiting.\nStandby\n• If you can\'t pass verification (ex. Don\'t reserved), Please change to standby zone waiting.\n• Standby passenger can get on the bus in order after waiting all reserved passengers got on the bus.\n',
			'busRuleStandbyTitle' => 'Standby\n',
			'busRuleStandbyRule' => '• If you don\'t take the bus but you reserved already, it\'s a violation, and you get a violation point (ex. 8:20 and 9:30 is different class)\n• If your class teacher take temporary leave, transfer cause you need take the bus early or lately, you need apply to class department then, department bus system administrator will logout violation.\n',
			'busRuleFineTitle' => 'Fine\n',
			'busRuleFineRule' => '• Fine Calculation, violation times below 3 times don\'t get point, From 4th violation begin recording point, every point should be pay off fine equal to bus fare.\n• Violation point recording until the end of the semester (1st Semester ended at 1/31, 2nd Semester ended at 8/31), violation point will restart recording. When you not paid off fine, next semester will stop your reservation right until you pay off fine.\n• Go to the auto payment machine or Office of General Affairs cashier pay off fine after you print violation statement by yourself, After paid off, go to Office of General Affairs General Affairs Division write off payment by receipt (Write off payment need receipt on the day.), After write off and the next day 4A.M. will be reserve class after 9.A.M..\n• If you have any suspicion about violation point, please go to Office of General Affairs General Affairs Division check violation directly in 10 days (included holidays).\n',
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
			'reserving' => 'Reserving...',
			'unknown' => 'Unknown',
			_ => null,
		};
	}
}
