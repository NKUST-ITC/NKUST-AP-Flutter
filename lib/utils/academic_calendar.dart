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
    if (title.contains('考試') || title.contains('競賽')) {
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
