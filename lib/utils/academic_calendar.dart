import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:nkust_ap/res/assets.dart';

/// One academic-calendar entry from the bundled `schedule_data.json`.
class AcademicCalendarEvent {
  const AcademicCalendarEvent({
    required this.start,
    required this.end,
    required this.title,
  });

  factory AcademicCalendarEvent.fromJson(Map<String, dynamic> json) {
    final DateTime start = DateTime.parse(json['start'] as String);
    final String rawEnd = json['end'] as String? ?? json['start'] as String;
    return AcademicCalendarEvent(
      start: start,
      end: DateTime.parse(rawEnd),
      title: (json['title'] as String? ?? '').trim(),
    );
  }

  final DateTime start;
  final DateTime end;
  final String title;

  bool get isRange => end.isAfter(start);
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
