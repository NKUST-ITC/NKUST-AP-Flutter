// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "aboutOpenSourceContent": MessageLookupByLibrary.simpleMessage(
            "https://github.com/NKUST-ITC/NKUST-AP-Flutter\n\nThis project is licensed under the terms of the MIT license:\nThe MIT License (MIT)\n\nCopyright © 2021 Rainvisitor\n\nThis project is Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."),
        "appName": MessageLookupByLibrary.simpleMessage("NKUST AP"),
        "bus": MessageLookupByLibrary.simpleMessage("Bus Reservation"),
        "busCancelReserve":
            MessageLookupByLibrary.simpleMessage("Cancel Bus Reservation"),
        "busCancelReserveConfirmContent": MessageLookupByLibrary.simpleMessage(
            "Are you sure to cancel a seat from %s at %s ?"),
        "busCancelReserveConfirmContent1": MessageLookupByLibrary.simpleMessage(
            "Are you sure to cancel a seat from "),
        "busCancelReserveConfirmContent2":
            MessageLookupByLibrary.simpleMessage(" to "),
        "busCancelReserveConfirmContent3":
            MessageLookupByLibrary.simpleMessage(" ?"),
        "busCancelReserveConfirmTitle": MessageLookupByLibrary.simpleMessage(
            "<b>Cancel</b> this reservation?"),
        "busCancelReserveFail":
            MessageLookupByLibrary.simpleMessage("Fail Canceled"),
        "busCancelReserveSuccess":
            MessageLookupByLibrary.simpleMessage("Successfully Canceled!"),
        "busCount": MessageLookupByLibrary.simpleMessage("(%s / %s)"),
        "busEmpty": MessageLookupByLibrary.simpleMessage(
            "Oops! No bus today~\n Please choose another date 😋"),
        "busFailInfinity": MessageLookupByLibrary.simpleMessage(
            "Bus system perhaps broken!!!"),
        "busFromJiangong":
            MessageLookupByLibrary.simpleMessage("JianGong to YanChao"),
        "busFromYanchao":
            MessageLookupByLibrary.simpleMessage("YanChao to JianGong"),
        "busJiangong":
            MessageLookupByLibrary.simpleMessage("To YanChao, Departure time："),
        "busJiangongReservations":
            MessageLookupByLibrary.simpleMessage("To YanChao, Scheduled date："),
        "busJiangongReserved": MessageLookupByLibrary.simpleMessage(
            "√ To YanChao, Departure time："),
        "busNotPick": MessageLookupByLibrary.simpleMessage(
            "You have not chosen a date!\n Please choose a date first %s"),
        "busNotPickDate": MessageLookupByLibrary.simpleMessage("Chosen Date"),
        "busNotify":
            MessageLookupByLibrary.simpleMessage("Bus Reservation Reminder"),
        "busNotifyContent": MessageLookupByLibrary.simpleMessage(
            "You\'ve got a bus departing at %s from %s!"),
        "busNotifyHint": MessageLookupByLibrary.simpleMessage(
            "Reminder will pop up 30 mins before reserved bus !\nIf you reserved or canceled the seat via website, please restart the app."),
        "busNotifyJiangong": MessageLookupByLibrary.simpleMessage("JianGong"),
        "busNotifySubTitle": MessageLookupByLibrary.simpleMessage(
            "Reminder 30 mins before reserved bus"),
        "busNotifyYanchao": MessageLookupByLibrary.simpleMessage("YanChao"),
        "busPickDate": MessageLookupByLibrary.simpleMessage("Chosen Date: %s"),
        "busReservationEmpty": MessageLookupByLibrary.simpleMessage(
            "Oops! You haven\'t reserved any bus~\n Ride public transport to save the Earth 😋"),
        "busReservations": MessageLookupByLibrary.simpleMessage("Bus Record"),
        "busReserve": MessageLookupByLibrary.simpleMessage("Bus Reservation"),
        "busReserveCancelDate": MessageLookupByLibrary.simpleMessage("Date"),
        "busReserveCancelLocation":
            MessageLookupByLibrary.simpleMessage("Location"),
        "busReserveCancelTime": MessageLookupByLibrary.simpleMessage("Time"),
        "busReserveConfirmContent": MessageLookupByLibrary.simpleMessage(
            "Are you sure to reserve a seat from %s at %s ?"),
        "busReserveConfirmTitle":
            MessageLookupByLibrary.simpleMessage("Reserve this bus?"),
        "busReserveDate": MessageLookupByLibrary.simpleMessage("Date"),
        "busReserveLocation": MessageLookupByLibrary.simpleMessage("Location"),
        "busReserveSuccess":
            MessageLookupByLibrary.simpleMessage("Successfully Reserved!"),
        "busReserveTime": MessageLookupByLibrary.simpleMessage("Time"),
        "busRule": MessageLookupByLibrary.simpleMessage("Bus Rule"),
        "busRuleCancelingTime": MessageLookupByLibrary.simpleMessage(
            "■ The classes before 9 A.M.：Please do calcelation in 15 hours ago.\n■ The classes after 9 A.M.：Please do calcelation in 5 hours ago\n"),
        "busRuleCancellingTitle":
            MessageLookupByLibrary.simpleMessage("• Cancelation Time\n"),
        "busRuleFineRule": MessageLookupByLibrary.simpleMessage(
            "• Fine Calculation，violation times below 3 times don\'t get point, From 4th violation begin recording point，every point should be pay off fine equal to bus fare.\n• Violation point recording until the end of the semester(1st Semester ended at 1/31，2nd Semester ended at 8/31)，violation point will restart recording. When you not paid off fine，next semester will stop your reservation right until you pay off fine.\n• Go to the auto payment machine or Office of General Affairs cashier pay off fine after you print violation statement by yourself, After paid off, go to Office of General Affairs General Affairs Division write off payment by receipt(Write off payment need receipt on the day.)，After write off and the next day 4A.M. will be reserve class after 9.A.M..\n• If you have any suspicion about violation point，please go to Office of General Affairs General Affairs Division check violation directly in 10 days(included holidays).\n"),
        "busRuleFineTitle": MessageLookupByLibrary.simpleMessage("Fine\n"),
        "busRuleFollowingTime": MessageLookupByLibrary.simpleMessage(
            "Please follow the bus schedule (ex. 8:20 and 9:30 is different class), People can\'t take bus and get violation point who don\t follow rule.\n"),
        "busRuleFourteenDay": MessageLookupByLibrary.simpleMessage(
            " Bus Reservation System can reserve bus in 14 days\nin need to follow office of general affairs\'s time requirement\n"),
        "busRuleIdCard": MessageLookupByLibrary.simpleMessage(
            "• Please take your student or staff ID(Before you get student or staff ID, Please use your ID) take bus\n"),
        "busRuleLateAndNoReservation": MessageLookupByLibrary.simpleMessage(
            "• Late or don\'t reserved passenger, please line up standby zone waiting.\nStandby\n• If you can\'t pass verification(ex. Don\'t reserved)，Please change to standby zone waiting.\n\"• Standby passenger can get on the bus in order after waiting all reserved passangers got on the bus.\n"),
        "busRuleNoIdCard": MessageLookupByLibrary.simpleMessage(
            "• If you don\'t take any ID, please line up standby zone\n"),
        "busRulePrepareCoins": MessageLookupByLibrary.simpleMessage(
            "（Use coin when you don\'t got Student ID，Please prepare 20 dollars coin first.）\n"),
        "busRuleReservationRuleTitle":
            MessageLookupByLibrary.simpleMessage("Bus Reservation\n"),
        "busRuleReservationTime": MessageLookupByLibrary.simpleMessage(
            "■ The classes before 9 A.M.：Please do resevation in 15 hours ago.\n■ The classes after 9 A.M.：Please do resevation in 5 hours ago\n"),
        "busRuleStandbyRule": MessageLookupByLibrary.simpleMessage(
            "• If you don\'t take the bus but you reserved already，It\'s a violation，and you get a violation point(ex. 8:20 and 9:30 is different class\n• If your class teacher take temporary leave、transfer cause you need take the bus early or lately，you need apply to class department then，deparment bus system administator will logout violation.\n"),
        "busRuleStandbyTitle":
            MessageLookupByLibrary.simpleMessage("Standby\n"),
        "busRuleTakeOn": MessageLookupByLibrary.simpleMessage("Take Bus\n"),
        "busRuleTwentyDollars": MessageLookupByLibrary.simpleMessage(
            "• Every time take bus need pay 20 NTD"),
        "busViolationRecordEmpty": MessageLookupByLibrary.simpleMessage(
            "Good！No any bus violation record～"),
        "busViolationRecords":
            MessageLookupByLibrary.simpleMessage("Bus Penalty"),
        "busYanchao": MessageLookupByLibrary.simpleMessage(
            "To JianGong, Departure time："),
        "busYanchaoReservations": MessageLookupByLibrary.simpleMessage(
            "To JianGong, Scheduled date："),
        "busYanchaoReserved": MessageLookupByLibrary.simpleMessage(
            "√ To JianGong, Departure time："),
        "canNotReserve": MessageLookupByLibrary.simpleMessage("Can\'t reserve"),
        "canceling": MessageLookupByLibrary.simpleMessage("Canceling..."),
        "clickShowDescription":
            MessageLookupByLibrary.simpleMessage("Description"),
        "destination": MessageLookupByLibrary.simpleMessage("Destination"),
        "enrollmentLetter":
            MessageLookupByLibrary.simpleMessage("Enrollment Letter"),
        "first": MessageLookupByLibrary.simpleMessage("first"),
        "firstLoginHint": MessageLookupByLibrary.simpleMessage(
            "For first-time login, please fill in the last four number of your ID as your password"),
        "fromFirst": MessageLookupByLibrary.simpleMessage("From First"),
        "fromJiangong": MessageLookupByLibrary.simpleMessage("From JianGong"),
        "fromYanchao": MessageLookupByLibrary.simpleMessage("From YanChao"),
        "jiangong": MessageLookupByLibrary.simpleMessage("JianGong"),
        "leaveApplyRecord":
            MessageLookupByLibrary.simpleMessage("Apply Records"),
        "loginAuth":
            MessageLookupByLibrary.simpleMessage("Login Authentication"),
        "mobileNkustLoginDescription": MessageLookupByLibrary.simpleMessage(
            "Because the school has closed the original crawler function, this version needs to be logged in through the new version of the mobile school system. After successful login, it will be redirected automatically. Unless the certificate expires, repeated verification is rarely required. It is strongly recommended to \"記住我\" to check it.。"),
        "mobileNkustLoginHint": MessageLookupByLibrary.simpleMessage(
            "Wait for the webpage to finish loading, the student ID and password will be filled in automatically.\nAfter completing the Google reCaptcha and clicking login, it will automatically redirected."),
        "nanzi": MessageLookupByLibrary.simpleMessage("Nanzi"),
        "nonCourseTime":
            MessageLookupByLibrary.simpleMessage("Non Course Time"),
        "offlineBusReservations":
            MessageLookupByLibrary.simpleMessage("Offline Bus Reservations"),
        "offlineLeaveData":
            MessageLookupByLibrary.simpleMessage("Offline absent Report"),
        "offlineScore": MessageLookupByLibrary.simpleMessage("Offline Score"),
        "paid": MessageLookupByLibrary.simpleMessage("Paid"),
        "punch": MessageLookupByLibrary.simpleMessage("Punch"),
        "punchSuccess": MessageLookupByLibrary.simpleMessage("Punch Success"),
        "qijin": MessageLookupByLibrary.simpleMessage("Qijin"),
        "reportNetProblem":
            MessageLookupByLibrary.simpleMessage("Report Net Problem"),
        "reportNetProblemSubTitle": MessageLookupByLibrary.simpleMessage(
            "Report encountered network problems"),
        "reportProblem": MessageLookupByLibrary.simpleMessage(
            "Report Problem (Requires school email login)"),
        "reserve": MessageLookupByLibrary.simpleMessage("Reserve"),
        "reserveDeadline":
            MessageLookupByLibrary.simpleMessage("Reserve Deadline"),
        "reserved": MessageLookupByLibrary.simpleMessage("Reserved"),
        "reserving": MessageLookupByLibrary.simpleMessage("Reserving..."),
        "schoolCloseCourseHint": MessageLookupByLibrary.simpleMessage(
            "School close course system, we can\'t solve it temporarily.\nAny problems are recommended to the school."),
        "searchStudentIdFormat":
            MessageLookupByLibrary.simpleMessage("Name：%s\nStudent ID：%s\n"),
        "specialBus": MessageLookupByLibrary.simpleMessage("Special Bus"),
        "trialBus": MessageLookupByLibrary.simpleMessage("Trial Bus"),
        "unpaid": MessageLookupByLibrary.simpleMessage("Unpaid"),
        "updateNoteContent": MessageLookupByLibrary.simpleMessage(
            "* Fix part of device home widget error."),
        "yanchao": MessageLookupByLibrary.simpleMessage("YanChao")
      };
}
