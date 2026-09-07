import 'dart:convert';
import 'dart:ui' show Color;

import 'package:flutter/services.dart' show rootBundle;
import 'package:nkust_ap/res/assets.dart';

enum AcademicCategory { holiday, exam, enrollment, registrar, general }

/// Shared by the month grid and the home card so both reds match.
const Color examAccent = Color(0xFFC62828);

/// One academic-calendar entry from the bundled `schedule_data.json`.
class AcademicCalendarEvent {
  const AcademicCalendarEvent({
    required this.start,
    required this.end,
    required this.title,
    required this.category,
  });

  factory AcademicCalendarEvent.fromJson(Map<String, dynamic> json) {
    final DateTime start = DateTime.parse(json['start'] as String);
    final String rawEnd = json['end'] as String? ?? json['start'] as String;
    final String title = (json['title'] as String? ?? '').trim();
    return AcademicCalendarEvent(
      start: start,
      end: DateTime.parse(rawEnd),
      title: title,
      category: _categorize(title),
    );
  }

  final DateTime start;
  final DateTime end;
  final String title;
  final AcademicCategory category;

  bool get isRange => end.isAfter(start);

  static AcademicCategory _categorize(String title) {
    if (title.contains('放假') ||
        title.contains('補假') ||
        title.contains('寒假') ||
        title.contains('暑假')) {
      return AcademicCategory.holiday;
    }
    // Only the two weeks the whole school sits. 英文大會考, 物理、化學競賽
    // and the 研究生申請學位考試 deadlines all spell out an exam without
    // being the date students plan a semester around, and giving them the
    // same red is what stops the red from meaning anything.
    if (title.contains('期中考') || title.contains('期末考')) {
      return AcademicCategory.exam;
    }
    if (title.contains('選課')) {
      return AcademicCategory.enrollment;
    }
    if (title.contains('休退學') ||
        title.contains('抵免') ||
        title.contains('畢業') ||
        title.contains('離校') ||
        title.contains('轉系') ||
        title.contains('學位') ||
        title.contains('成績')) {
      return AcademicCategory.registrar;
    }
    return AcademicCategory.general;
  }

  bool get isMajorExam => category == AcademicCategory.exam;

  /// 「第一學期期中考試」 runs long in a one-line banner, and the calendar
  /// only ever carries one of each per semester, so the two characters that
  /// tell them apart carry the whole meaning. Titles come from the school's
  /// PDF and are never translated, hence the literals.
  String get shortTitle {
    if (title.contains('期中考')) return '期中考';
    if (title.contains('期末考')) return '期末考';
    return title;
  }

  /// Days from [day] until this starts; zero once it has begun.
  int daysUntil(DateTime day) {
    final DateTime target = DateTime(day.year, day.month, day.day);
    final DateTime from = DateTime(start.year, start.month, start.day);
    final int days = from.difference(target).inDays;
    return days < 0 ? 0 : days;
  }

  bool covers(DateTime day) {
    final DateTime target = DateTime(day.year, day.month, day.day);
    return !target.isBefore(DateTime(start.year, start.month, start.day)) &&
        !target.isAfter(DateTime(end.year, end.month, end.day));
  }
}

/// Reads the bundled calendar (no network) sorted by start date.
Future<List<AcademicCalendarEvent>> loadAcademicCalendar() async {
  final String raw = await rootBundle.loadString(FileAssets.scheduleData);
  final List<dynamic> jsonArray = jsonDecode(raw) as List<dynamic>;
  return <AcademicCalendarEvent>[
    for (final dynamic item in jsonArray)
      if (item is Map<String, dynamic> && item['start'] is String)
        AcademicCalendarEvent.fromJson(item),
  ]..sort(
      (AcademicCalendarEvent a, AcademicCalendarEvent b) =>
          a.start.compareTo(b.start),
    );
}

/// The midterm or final week [day] falls in, else the next one ahead of it.
///
/// Returns null once both are behind us — late in the second semester the
/// bundled calendar has no exam left to count down to.
AcademicCalendarEvent? nextMajorExam(
  List<AcademicCalendarEvent> events,
  DateTime day,
) {
  final DateTime target = DateTime(day.year, day.month, day.day);
  AcademicCalendarEvent? best;
  for (final AcademicCalendarEvent event in events) {
    if (!event.isMajorExam) continue;
    if (DateTime(event.end.year, event.end.month, event.end.day)
        .isBefore(target)) {
      continue;
    }
    if (best == null || event.start.isBefore(best.start)) best = event;
  }
  return best;
}

/// Events overlapping the Monday–Sunday week that contains [day].
List<AcademicCalendarEvent> eventsThisWeek(
  List<AcademicCalendarEvent> events,
  DateTime day,
) {
  final DateTime target = DateTime(day.year, day.month, day.day);
  final DateTime monday = target.subtract(Duration(days: target.weekday - 1));
  final DateTime sunday = monday.add(const Duration(days: 6));
  return <AcademicCalendarEvent>[
    for (final AcademicCalendarEvent event in events)
      if (!event.start.isAfter(sunday) && !event.end.isBefore(monday)) event,
  ];
}
