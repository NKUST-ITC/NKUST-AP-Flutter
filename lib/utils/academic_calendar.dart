import 'dart:async';
import 'dart:convert';
import 'dart:ui' show Brightness, Color;

import 'package:ap_common/ap_common.dart' show PreferenceUtil;
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:nkust_ap/res/assets.dart';

/// Where a new semester's calendar arrives from between store releases.
///
/// This is the same file the app bundles, served from the repository, so
/// publishing one is a commit rather than a build. Hardcoded on purpose:
/// a remotely configurable source would let whoever holds that config
/// redirect the app somewhere else.
const String _remoteUrl =
    'https://raw.githubusercontent.com/NKUST-ITC/NKUST-AP-Flutter'
    '/master/assets/schedule_data.json';

const String _prefCached = 'cached_schedule_data';
const String _prefCachedAt = 'cached_schedule_data_at';

/// Long enough that a semester rollover lands within a day of publishing,
/// short enough that nobody is fetching an unchanged file on every launch.
const Duration _refreshInterval = Duration(hours: 12);

Future<List<AcademicCalendarEvent>?>? _inFlight;

enum AcademicCategory { holiday, exam, enrollment, registrar, general }

/// Red reads as "day off" on every printed calendar in Taiwan, so weekends
/// and holidays claim it and the exam weeks take a colour of their own.
///
/// Each accent comes as a pair. The tone that carries a printed calendar's
/// weight on white drops to roughly 2:1 against a dark surface — below even
/// the 3:1 a non-text element needs — so dark mode swaps in a light twin
/// instead of reusing the dark one at a lower opacity.
Color holidayAccentOf(Brightness brightness) => brightness == Brightness.dark
    ? const Color(0xFFEF9A9A)
    : const Color(0xFFC62828);

/// Shared by the month grid and the home card so both match.
Color examAccentOf(Brightness brightness) => brightness == Brightness.dark
    ? const Color(0xFFCE93D8)
    : const Color(0xFF6A1B9A);

Color registrarAccentOf(Brightness brightness) => brightness == Brightness.dark
    ? const Color(0xFFFFB74D)
    : const Color(0xFFEF6C00);

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

/// Parses a calendar document, or returns null if anything about it is off.
///
/// All or nothing by design. A half-read calendar is worse than no update
/// at all, and this parses input the app did not build — the bundled asset,
/// a cached copy, and a file fetched over the network all come through
/// here, so one malformed entry must not be able to land.
/// Dart rolls impossible dates over rather than rejecting them, so
/// `2026-13-45` parses cleanly as 2027-02-14 and a typo in the source
/// would land as a real-looking entry. Require the result to say back
/// exactly what was written.
DateTime? _strictDate(String value) {
  final RegExpMatch? match =
      RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(value);
  if (match == null) return null;
  final DateTime? parsed = DateTime.tryParse(value);
  if (parsed == null) return null;
  if (parsed.year != int.parse(match.group(1)!) ||
      parsed.month != int.parse(match.group(2)!) ||
      parsed.day != int.parse(match.group(3)!)) {
    return null;
  }
  return parsed;
}

List<AcademicCalendarEvent>? parseAcademicCalendar(String raw) {
  try {
    final dynamic decoded = jsonDecode(raw);
    if (decoded is! List<dynamic>) return null;
    final List<AcademicCalendarEvent> events = <AcademicCalendarEvent>[];
    for (final dynamic item in decoded) {
      if (item is! Map<String, dynamic>) return null;
      final Object? start = item['start'];
      final Object? end = item['end'];
      final Object? title = item['title'];
      if (start is! String) return null;
      if (end != null && end is! String) return null;
      if (title is! String || title.trim().isEmpty) return null;
      if (_strictDate(start) == null) return null;
      if (end is String && _strictDate(end) == null) return null;
      events.add(AcademicCalendarEvent.fromJson(item));
    }
    if (events.isEmpty) return null;
    return events
      ..sort(
        (AcademicCalendarEvent a, AcademicCalendarEvent b) =>
            a.start.compareTo(b.start),
      );
  } catch (_) {
    return null;
  }
}

/// The best calendar available without going to the network.
///
/// The bundled asset is the floor — it ships with the app, so it always
/// parses and the page always has something to draw. A cached download
/// wins when there is one, because it is the same file from the same
/// repository, only newer.
Future<List<AcademicCalendarEvent>> loadAcademicCalendar() async {
  final String cached = PreferenceUtil.instance.getString(_prefCached, '');
  if (cached.isNotEmpty) {
    final List<AcademicCalendarEvent>? events = parseAcademicCalendar(cached);
    if (events != null) return events;
    await PreferenceUtil.instance.remove(_prefCached);
  }
  final String raw = await rootBundle.loadString(FileAssets.scheduleData);
  return parseAcademicCalendar(raw) ?? <AcademicCalendarEvent>[];
}

/// Fetches a newer calendar, returning it only when one actually arrived.
///
/// Null covers every uninteresting outcome — checked recently, offline,
/// server unhappy, response unparseable, nothing changed — so callers can
/// treat it as "keep what you are showing" without distinguishing them.
Future<List<AcademicCalendarEvent>?> refreshAcademicCalendar({
  bool force = false,
}) {
  return _inFlight ??= _refresh(force: force).whenComplete(() {
    _inFlight = null;
  });
}

Future<List<AcademicCalendarEvent>?> _refresh({required bool force}) async {
  final String cached = PreferenceUtil.instance.getString(_prefCached, '');
  if (!force) {
    final String at = PreferenceUtil.instance.getString(_prefCachedAt, '');
    final DateTime? last = DateTime.tryParse(at);
    if (last != null &&
        DateTime.now().difference(last) < _refreshInterval) {
      return null;
    }
  }
  try {
    final Response<String> response = await Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
        responseType: ResponseType.plain,
      ),
    ).get<String>(_remoteUrl);
    final String? body = response.data;
    if (body == null) return null;
    final List<AcademicCalendarEvent>? events = parseAcademicCalendar(body);
    if (events == null) return null;
    await PreferenceUtil.instance.setString(_prefCached, body);
    await PreferenceUtil.instance.setString(
      _prefCachedAt,
      DateTime.now().toIso8601String(),
    );
    return body == cached ? null : events;
  } catch (_) {
    return null;
  }
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
