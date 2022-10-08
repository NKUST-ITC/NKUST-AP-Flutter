library utils;

import 'dart:ui';

import 'package:intl/intl.dart';

/*This fork from https://github.com/apptreesoftware/date_utils
*Copyright (c) 2018, AppTree. All rights reserved.
*
*Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met: * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. * Neither the name of the nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
*
*THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
//ignore_for_file: lines_longer_than_80_chars

class CalendarDateUtils {
  CalendarDateUtils._();

  static final DateFormat _monthFormat =
      DateFormat('MMMM yyyy', Locale(Intl.defaultLocale!).languageCode);
  static final DateFormat _dayFormat =
      DateFormat('dd', Locale(Intl.defaultLocale!).languageCode);
  static final DateFormat _firstDayFormat =
      DateFormat('MMM dd', Locale(Intl.defaultLocale!).languageCode);
  static final DateFormat _fullDayFormat =
      DateFormat('EEE MMM dd, yyyy', Locale(Intl.defaultLocale!).languageCode);
  static final DateFormat _apiDayFormat =
      DateFormat('yyyy-MM-dd', Locale(Intl.defaultLocale!).languageCode);

  static String formatMonth(DateTime d) => _monthFormat.format(d);

  static String formatDay(DateTime d) => _dayFormat.format(d);

  static String formatFirstDay(DateTime d) => _firstDayFormat.format(d);

  static String fullDayFormat(DateTime d) => _fullDayFormat.format(d);

  static String apiDayFormat(DateTime d) => _apiDayFormat.format(d);

  static const List<String> weekdays = <String>[
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];

  /// The list of days in a given month
  static List<DateTime> daysInMonth(DateTime month) {
    final DateTime first = firstDayOfMonth(month);
    final int daysBefore = first.weekday;
    final DateTime firstToDisplay = first.subtract(Duration(days: daysBefore));
    final DateTime last = CalendarDateUtils.lastDayOfMonth(month);

    int daysAfter = 7 - last.weekday;

    // If the last day is sunday (7) the entire week must be rendered
    if (daysAfter == 0) {
      daysAfter = 7;
    }

    final DateTime lastToDisplay = last.add(Duration(days: daysAfter));
    return daysInRange(firstToDisplay, lastToDisplay).toList();
  }

  static bool isFirstDayOfMonth(DateTime day) {
    return isSameDay(firstDayOfMonth(day), day);
  }

  static bool isLastDayOfMonth(DateTime day) {
    return isSameDay(lastDayOfMonth(day), day);
  }

  static DateTime firstDayOfMonth(DateTime month) {
    return DateTime(month.year, month.month);
  }

  static DateTime firstDayOfWeek(DateTime dateTime) {
    /// Handle Daylight Savings by setting hour to 12:00 Noon
    /// rather than the default of Midnight
    final DateTime day =
        DateTime.utc(dateTime.year, dateTime.month, dateTime.day, 12);

    /// Weekday is on a 1-7 scale Monday - Sunday,
    /// This Calendar works from Sunday - Monday
    final int decreaseNum = day.weekday % 7;
    return day.subtract(Duration(days: decreaseNum));
  }

  static DateTime lastDayOfWeek(DateTime dateTime) {
    /// Handle Daylight Savings by setting hour to 12:00 Noon
    /// rather than the default of Midnight
    final DateTime day =
        DateTime.utc(dateTime.year, dateTime.month, dateTime.day, 12);

    /// Weekday is on a 1-7 scale Monday - Sunday,
    /// This Calendar's Week starts on Sunday
    final int increaseNum = day.weekday % 7;
    return day.add(Duration(days: 7 - increaseNum));
  }

  /// The last day of a given month
  static DateTime lastDayOfMonth(DateTime month) {
    final DateTime beginningNextMonth = (month.month < 12)
        ? DateTime(month.year, month.month + 1)
        : DateTime(month.year + 1);
    return beginningNextMonth.subtract(const Duration(days: 1));
  }

  /// Returns a [DateTime] for each day the given range.
  ///
  /// [start] inclusive
  /// [end] exclusive
  static Iterable<DateTime> daysInRange(DateTime start, DateTime end) sync* {
    DateTime i = start;
    Duration offset = start.timeZoneOffset;
    while (i.isBefore(end)) {
      yield i;
      i = i.add(const Duration(days: 1));
      final Duration timeZoneDiff = i.timeZoneOffset - offset;
      if (timeZoneDiff.inSeconds != 0) {
        offset = i.timeZoneOffset;
        i = i.subtract(Duration(seconds: timeZoneDiff.inSeconds));
      }
    }
  }

  /// Whether or not two times are on the same day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isSameWeek(DateTime dataTimeA, DateTime dataTimeB) {
    /// Handle Daylight Savings by setting hour to 12:00 Noon
    /// rather than the default of Midnight
    final DateTime a =
        DateTime.utc(dataTimeA.year, dataTimeA.month, dataTimeA.day);
    final DateTime b =
        DateTime.utc(dataTimeB.year, dataTimeB.month, dataTimeB.day);

    final int diff = a.toUtc().difference(b.toUtc()).inDays;
    if (diff.abs() >= 7) {
      return false;
    }

    final DateTime min = a.isBefore(b) ? a : b;
    final DateTime max = a.isBefore(b) ? b : a;
    final bool result = max.weekday % 7 - min.weekday % 7 >= 0;
    return result;
  }

  static DateTime previousMonth(DateTime m) {
    int year = m.year;
    int month = m.month;
    if (month == 1) {
      year--;
      month = 12;
    } else {
      month--;
    }
    return DateTime(year, month);
  }

  static DateTime nextMonth(DateTime m) {
    int year = m.year;
    int month = m.month;

    if (month == 12) {
      year++;
      month = 1;
    } else {
      month++;
    }
    return DateTime(year, month);
  }

  static DateTime previousWeek(DateTime w) {
    return w.subtract(const Duration(days: 7));
  }

  static DateTime nextWeek(DateTime w) {
    return w.add(const Duration(days: 7));
  }
}
