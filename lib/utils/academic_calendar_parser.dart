/// Turns the registry's academic-calendar PDFs into calendar entries.
///
/// A Dart port of `tool/parse_academic_calendar.py`, kept deliberately
/// rule-for-rule identical to it: the CI script and the app read the same
/// documents, and two sets of rules would drift into two different
/// calendars. Pure — text in, entries out — so it can be tested without a
/// PDF or a network.
library;

/// One semester of the ROC academic year.
class AcademicSemester {
  const AcademicSemester(this.year, this.term);

  /// ROC academic year, e.g. 115.
  final int year;

  /// 1 or 2.
  final int term;

  String get code => '$year-$term';

  /// Calendar year a bare M/D in this semester belongs to.
  ///
  /// A semester's PDF only ever spans one turn of the new year. The first
  /// runs August to January, so months before August have rolled over; the
  /// second runs February to August and never does.
  int gregorianYear(int month) {
    final int base = year + 1911;
    if (term == 1) return month >= 8 ? base : base + 1;
    return base + 1;
  }

  @override
  bool operator ==(Object other) =>
      other is AcademicSemester && other.year == year && other.term == term;

  @override
  int get hashCode => Object.hash(year, term);

  @override
  String toString() => code;
}

/// 課(9/7-9/16)115-1 學期選課加退選
///
/// Not anchored to the start of the line. Syncfusion returns a PDF's visual
/// rows, and where the month grid sits level with an entry the row arrives
/// as `1 2 3 4 5 6 7 ○ 課(9/7-9/16)…`. Excluding digits and spaces from the
/// unit keeps the search from starting inside those grid numbers.
final RegExp _event = RegExp(
  r'([^()（）\s\d]{1,4})[(（]'
  r'(\d{1,2}\s*/\s*\d{1,2}[^)）]*)'
  r'[)）](.+)$',
);
final RegExp _range = RegExp(
  r'^(\d{1,2})\s*/\s*(\d{1,2})\s*[-~－～]\s*'
  r'(\d{1,2})\s*/\s*(\d{1,2})\s*$',
);
final RegExp _single = RegExp(r'^(\d{1,2})\s*/\s*(\d{1,2})\s*(前|起|截止)?\s*$');

/// 國立高雄科技大學115 學年度第一學期行事曆
final RegExp _heading = RegExp(r'(\d{3})\s*學年度第(一|二)學期行事曆');

/// 115學年度第2學期行事曆 (NEW!!) — the index writes the term as a digit
/// where the document itself spells it out.
final RegExp _indexName = RegExp(r'(\d{3})\s*學年度第\s*([12一二])\s*學期');

final RegExp _whitespace = RegExp(r'\s+');

/// A layout change that breaks the line format shows up as a handful of
/// matches rather than an error, so too few entries is treated as a failure.
const int _minEvents = 20;

/// The semester a document declares, or null if it does not declare one.
AcademicSemester? readSemester(List<String> lines) {
  for (final String line in lines.take(5)) {
    final RegExpMatch? match = _heading.firstMatch(line.replaceAll(' ', ''));
    if (match != null) {
      return AcademicSemester(
        int.parse(match.group(1)!),
        match.group(2) == '一' ? 1 : 2,
      );
    }
  }
  return null;
}

/// Entries from a calendar's text rows, or null if the document does not
/// read as one.
///
/// All or nothing, like every other calendar input the app accepts: a date
/// field nobody anticipated means the rules no longer describe the document,
/// and half a semester is worse than falling back to the one already loaded.
List<Map<String, String>>? parseCalendarLines(
  List<String> lines,
  AcademicSemester semester,
) {
  final List<Map<String, String>> events = <Map<String, String>>[];
  for (final String line in lines) {
    final RegExpMatch? match = _event.firstMatch(line);
    if (match == null) continue;
    final String dates = match.group(2)!.trim();
    // Titles arrive with the spacing the PDF used for glyph layout, which is
    // not spacing anyone typed: 115-1 學期選課 is one word.
    String title = match.group(3)!.replaceAll(_whitespace, '').trim();
    if (title.isEmpty) continue;

    final RegExpMatch? span = _range.firstMatch(dates);
    if (span != null) {
      final int m1 = int.parse(span.group(1)!);
      final int d1 = int.parse(span.group(2)!);
      final int m2 = int.parse(span.group(3)!);
      final int d2 = int.parse(span.group(4)!);
      // A range that runs backwards has crossed into the new year.
      final bool wraps = m2 < m1 || (m2 == m1 && d2 < d1);
      final int endYear = wraps
          ? semester.gregorianYear(m1) + 1
          : semester.gregorianYear(m2);
      events.add(<String, String>{
        'start': _stamp(semester.gregorianYear(m1), m1, d1),
        'end': _stamp(endYear, m2, d2),
        'title': title,
      });
      continue;
    }

    final RegExpMatch? point = _single.firstMatch(dates);
    if (point != null) {
      final int month = int.parse(point.group(1)!);
      final int day = int.parse(point.group(2)!);
      final String? suffix = point.group(3);
      if (suffix != null) {
        // 「(9/7 前)申請休退學」 reads as a deadline, and the deadline is the
        // whole meaning, so it has to survive into the title.
        title = '$title（$month/$day $suffix）';
      }
      final String stamp = _stamp(semester.gregorianYear(month), month, day);
      events.add(<String, String>{
        'start': stamp,
        'end': stamp,
        'title': title,
      });
      continue;
    }

    return null;
  }

  if (events.length < _minEvents) return null;
  _sort(events);
  return events;
}

/// The semester a document's name claims, or null if it does not read as
/// one. Lets the caller choose which documents to fetch without fetching
/// every one of them first.
AcademicSemester? semesterFromName(String name) {
  final RegExpMatch? match = _indexName.firstMatch(name);
  if (match == null) return null;
  final String term = match.group(2)!;
  return AcademicSemester(
    int.parse(match.group(1)!),
    term == '1' || term == '一' ? 1 : 2,
  );
}

/// The span a semester covers by definition, for ordering documents that
/// have not been read yet. A read one has real dates; prefer those.
({String start, String end}) nominalSpan(AcademicSemester semester) {
  if (semester.term == 1) {
    return (
      start: _stamp(semester.gregorianYear(8), 8, 1),
      end: _stamp(semester.gregorianYear(1), 1, 31),
    );
  }
  return (
    start: _stamp(semester.gregorianYear(2), 2, 1),
    end: _stamp(semester.gregorianYear(8), 8, 31),
  );
}

/// The span a semester's entries actually cover.
({String start, String end}) eventSpan(List<Map<String, String>> events) => (
      start: events.map((Map<String, String> e) => e['start']!).reduce(_min),
      end: events.map((Map<String, String> e) => e['end']!).reduce(_max),
    );

/// The semester a reader is actually in.
///
/// Not simply the newest one published: the registry posts both of next
/// year's calendars well before either starts, so through the autumn the
/// latest document describes a semester nobody has reached yet.
String? pickCurrentSemester(
  Map<String, List<Map<String, String>>> parsed,
  DateTime today,
) =>
    pickCurrentSpan(
      <String, ({String start, String end})>{
        for (final MapEntry<String, List<Map<String, String>>> entry
            in parsed.entries)
          entry.key: eventSpan(entry.value),
      },
      today,
    );

/// [pickCurrentSemester] over spans from any source.
String? pickCurrentSpan(
  Map<String, ({String start, String end})> spans,
  DateTime today,
) {
  if (spans.isEmpty) return null;
  final String stamp = _stamp(today.year, today.month, today.day);
  final List<String> order = spans.keys.toList()
    ..sort((String a, String b) => spans[a]!.start.compareTo(spans[b]!.start));
  for (final String code in order) {
    final ({String start, String end}) span = spans[code]!;
    if (span.start.compareTo(stamp) <= 0 && span.end.compareTo(stamp) >= 0) {
      return code;
    }
  }
  for (final String code in order) {
    if (stamp.compareTo(spans[code]!.start) < 0) return code;
  }
  return order.last;
}

/// [current] and whichever neighbours have been published.
///
/// Week one still looks back at last semester's make-up exams, and from the
/// midterms on the question is when the next one starts. Either side may be
/// absent — the registry posts a calendar months after the one it follows —
/// so a missing neighbour just shortens the window.
List<String> semestersAround(Iterable<String> codes, String current) {
  final List<String> order = codes.toList()..sort(_bySemesterCode);
  final int at = order.indexOf(current);
  if (at < 0) return <String>[];
  final int from = at == 0 ? 0 : at - 1;
  final int to = at + 2 > order.length ? order.length : at + 2;
  return order.sublist(from, to);
}

/// Those semesters as one calendar, in date order.
///
/// Consecutive semesters overlap by a few days and the registry prints some
/// of the entries in that seam on both sheets, so identical ones collapse.
List<Map<String, String>> mergeSemesters(
  Map<String, List<Map<String, String>>> parsed,
  List<String> codes,
) {
  final Set<(String, String, String)> seen =
      <(String, String, String)>{};
  final List<Map<String, String>> events = <Map<String, String>>[];
  for (final String code in codes) {
    final List<Map<String, String>> semesterEvents =
        parsed[code] ?? const <Map<String, String>>[];
    for (final Map<String, String> event in semesterEvents) {
      // A record rather than a joined string: records compare
      // structurally, so there is no separator to choose and nothing
      // a title could contain that would fuse two entries into one.
      final (String, String, String) key =
          (event['start']!, event['end']!, event['title']!);
      if (seen.add(key)) events.add(event);
    }
  }
  _sort(events);
  return events;
}

String _stamp(int year, int month, int day) =>
    '${year.toString().padLeft(4, '0')}-'
    '${month.toString().padLeft(2, '0')}-'
    '${day.toString().padLeft(2, '0')}';

String _min(String a, String b) => a.compareTo(b) <= 0 ? a : b;

String _max(String a, String b) => a.compareTo(b) >= 0 ? a : b;

int _bySemesterCode(String a, String b) {
  final List<int> x = a.split('-').map(int.parse).toList();
  final List<int> y = b.split('-').map(int.parse).toList();
  final int byYear = x[0].compareTo(y[0]);
  return byYear != 0 ? byYear : x[1].compareTo(y[1]);
}

void _sort(List<Map<String, String>> events) {
  events.sort((Map<String, String> a, Map<String, String> b) {
    final int byStart = a['start']!.compareTo(b['start']!);
    if (byStart != 0) return byStart;
    final int byEnd = a['end']!.compareTo(b['end']!);
    return byEnd != 0 ? byEnd : a['title']!.compareTo(b['title']!);
  });
}
