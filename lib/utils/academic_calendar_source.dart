import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show compute, debugPrint;
import 'package:nkust_ap/integrations/pdf/pdf_text_lines.dart';
import 'package:nkust_ap/utils/academic_calendar_parser.dart';
import 'package:nkust_crawler/nkust_crawler.dart' show ApiConfig;

/// The registry's own index of published calendars, exported as CSV.
///
/// Reading the sheet rather than a hardcoded list of PDFs is what lets a
/// newly published semester appear without anyone shipping anything: the
/// registry adds a row, and the next refresh picks it up.
const String _csvUrl =
    'https://docs.google.com/spreadsheets/d/e/'
    '2PACX-1vSgjFXXnuyCosq2gWkvldnFtNPQl8mDU1d13UVIOx_IInPPeSsTXDUlTThakD_'
    'NAZKhM16O_1TwgOlT/pub?gid=1497644044&single=true&output=csv';

/// The only host a calendar is fetched from.
///
/// The index is a published spreadsheet, so its URL column is not something
/// this app controls: a row could name any address, and every install would
/// then request it. Constraining the host keeps a compromised or mistaken
/// sheet from turning the user base into traffic aimed wherever it likes.
const String calendarHost = 'acad.nkust.edu.tw';

/// Reading the calendars costs a few hundred KB of PDF, and the registry
/// publishes one semester at a time — months apart. Checking daily would be
/// spending a student's data to re-read documents that have not changed.
const Duration pdfRefreshInterval = Duration(days: 7);

/// The published calendars run to roughly 170KB. Anything far past that is
/// not one, and is not worth reading into memory to find out.
const int maxDocumentBytes = 4 * 1024 * 1024;

/// A ceiling for when the index cannot be narrowed by name — the window is
/// three semesters, and the sheet lists newest first.
const int maxDocuments = 4;

/// One row of the index.
typedef CalendarListing = ({String name, String url});

Dio _client() {
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: const <String, String>{'user-agent': 'nkust-ap'},
      followRedirects: false,
    ),
  );
  // acad.nkust.edu.tw serves its leaf without the intermediate that joins it
  // to the TWCA root. The adapter bootstrap installs carries that anchor, so
  // the chain verifies here for the same reason it does for the crawler.
  final HttpClientAdapter Function()? factory =
      ApiConfig.platformAdapterFactory;
  if (factory != null) dio.httpClientAdapter = factory();
  return dio;
}

/// The calendar as the registry currently publishes it, or null if it could
/// not be read.
///
/// Null is every uninteresting outcome — offline, the sheet moved, a PDF
/// whose layout no longer matches — so the caller can treat it as "keep what
/// you have" without distinguishing them.
Future<List<Map<String, String>>?> buildCalendarFromPdfs({
  DateTime? now,
}) async {
  final DateTime today = now ?? DateTime.now();
  final Dio dio = _client();
  try {
    final List<CalendarListing>? listed = await _index(dio);
    if (listed == null || listed.isEmpty) return null;

    final Map<String, List<Map<String, String>>> parsed =
        <String, List<Map<String, String>>>{};
    for (final CalendarListing entry in wanted(listed, today)) {
      final ParsedCalendar? document = await _read(dio, entry);
      // One unreadable document is not a reason to discard the others — the
      // window only needs the semesters around today.
      if (document != null) parsed[document.code] = document.events;
    }
    if (parsed.isEmpty) return null;

    // Chosen again on the dates the documents actually carry, rather than
    // the ones their names implied.
    final String? current = pickCurrentSemester(parsed, today);
    if (current == null) return null;
    final List<String> window = semestersAround(parsed.keys, current);
    debugPrint('[calendar] current $current, bundling ${window.join(', ')}');
    return mergeSemesters(parsed, window);
  } finally {
    dio.close();
  }
}

/// The rows of the index, or null if it could not be read.
Future<List<CalendarListing>?> _index(Dio dio) async {
  try {
    final Response<String> response = await dio.get<String>(
      _csvUrl,
      options: Options(responseType: ResponseType.plain),
    );
    return listCalendarPdfs(response.data ?? '');
  } on DioException catch (e) {
    debugPrint('[calendar] index unreachable: ${e.type}');
    return null;
  }
}

/// The documents worth fetching for [today].
///
/// Names carry the semester, so the window can be chosen before anything is
/// downloaded — which matters as the registry's archive grows. When a name
/// does not read, the list falls back to the first [maxDocuments] rows
/// rather than every row the sheet happens to hold.
List<CalendarListing> wanted(List<CalendarListing> listed, DateTime today) {
  final Map<String, CalendarListing> byCode = <String, CalendarListing>{};
  final Map<String, ({String start, String end})> spans =
      <String, ({String start, String end})>{};
  for (final CalendarListing entry in listed) {
    final AcademicSemester? semester = semesterFromName(entry.name);
    if (semester == null) return listed.take(maxDocuments).toList();
    byCode[semester.code] = entry;
    spans[semester.code] = nominalSpan(semester);
  }
  final String? current = pickCurrentSpan(spans, today);
  if (current == null) return listed.take(maxDocuments).toList();
  return <CalendarListing>[
    for (final String code in semestersAround(byCode.keys, current))
      byCode[code]!,
  ];
}

/// Downloads and reads one calendar, or null if that did not work out.
Future<ParsedCalendar?> _read(Dio dio, CalendarListing entry) async {
  try {
    Uri url = Uri.parse(entry.url);
    late Response<List<int>> response;
    for (int redirects = 0; ; redirects++) {
      response = await dio.get<List<int>>(
        url.toString(),
        options: Options(
          responseType: ResponseType.bytes,
          validateStatus: (int? status) =>
              status != null && status >= 200 && status < 400,
        ),
      );
      final int status = response.statusCode ?? 0;
      if (status < 300 || status >= 400) break;
      if (redirects >= 3) return null;
      final String? location = response.headers.value('location');
      if (location == null) return null;
      final Uri next = url.resolve(location);
      if (!_isAllowed(next)) return null;
      url = next;
    }

    final List<int>? body = response.data;
    if (body == null) return null;
    if (body.length > maxDocumentBytes) {
      debugPrint('[calendar] a listed document was too large to read');
      return null;
    }
    // Off the main isolate: a semester is a 170KB PDF and there are several,
    // which is long enough to drop frames if it ran here.
    return compute(parseCalendarDocument, Uint8List.fromList(body));
  } on DioException catch (e) {
    debugPrint('[calendar] a listed document was unreachable: ${e.type}');
    return null;
  }
}

/// A calendar document that read cleanly.
class ParsedCalendar {
  const ParsedCalendar(this.code, this.events);

  final String code;
  final List<Map<String, String>> events;
}

/// Reads one calendar PDF. Top-level so it can run under [compute].
ParsedCalendar? parseCalendarDocument(Uint8List bytes) {
  final List<String> lines;
  try {
    lines = extractPdfTextLines(bytes);
  } catch (_) {
    return null;
  }
  final AcademicSemester? semester = readSemester(lines);
  if (semester == null) return null;
  final List<Map<String, String>>? events =
      parseCalendarLines(lines, semester);
  if (events == null) return null;
  return ParsedCalendar(semester.code, events);
}

/// The Chinese-language calendars the sheet lists.
///
/// Rows naming anything but an https PDF on [calendarHost] are dropped: see
/// the constant for why the sheet is not trusted to say where to go.
List<CalendarListing> listCalendarPdfs(String csv) {
  final List<List<String>> rows = parseCsv(csv);
  if (rows.isEmpty) return <CalendarListing>[];
  final List<String> header =
      rows.first.map((String h) => h.trim()).toList();
  final int subgroup = header.indexOf('Subgroup');
  final int filename = header.indexOf('Filename');
  final int url = header.indexOf('URL');
  if (subgroup < 0 || filename < 0 || url < 0) return <CalendarListing>[];

  final List<CalendarListing> found = <CalendarListing>[];
  for (final List<String> row in rows.skip(1)) {
    if (row.length <= subgroup || row.length <= url) continue;
    if (row[subgroup].trim() != '中文版') continue;
    final Uri? href = _resolve(row[url].trim());
    if (href == null) continue;
    found.add((
      name: row.length > filename ? row[filename].trim() : '',
      url: href.toString(),
    ));
  }
  return found;
}

Uri? _resolve(String value) {
  final Uri? parsed = Uri.tryParse(value);
  if (parsed == null) return null;
  if (!parsed.path.toLowerCase().endsWith('.pdf')) return null;
  // Resolved against the registry rather than concatenated onto it, so that
  // a protocol-relative `//elsewhere/x.pdf` becomes the other host it really
  // names and is caught by the check below instead of being disguised as a
  // path. Relative rows — which is all the sheet has ever held — land on the
  // registry unchanged.
  final Uri absolute = Uri.https(calendarHost, '/').resolveUri(parsed);
  if (!_isAllowed(absolute)) return null;
  return absolute;
}

bool _isAllowed(Uri uri) {
  if (uri.scheme != 'https' || uri.host != calendarHost) return false;
  // The registry publishes on 443. A row naming another port would still be
  // the school's address while reaching a service that never expected to
  // hear from every phone on campus.
  return !uri.hasPort || uri.port == 443;
}

/// Minimal RFC 4180 reader — enough for a four-column sheet whose fields may
/// be quoted because a title contains a comma.
List<List<String>> parseCsv(String text) {
  final List<List<String>> rows = <List<String>>[];
  List<String> row = <String>[];
  final StringBuffer field = StringBuffer();
  bool quoted = false;

  for (int i = 0; i < text.length; i++) {
    final String ch = text[i];
    if (quoted) {
      if (ch != '"') {
        field.write(ch);
      } else if (i + 1 < text.length && text[i + 1] == '"') {
        field.write('"');
        i++;
      } else {
        quoted = false;
      }
      continue;
    }
    switch (ch) {
      case '"':
        quoted = true;
      case ',':
        row.add(field.toString());
        field.clear();
      case '\r':
        // Dropped; the '\n' beside it is what ends the row.
        break;
      case '\n':
        row.add(field.toString());
        field.clear();
        rows.add(row);
        row = <String>[];
      default:
        field.write(ch);
    }
  }
  if (field.isNotEmpty || row.isNotEmpty) {
    row.add(field.toString());
    rows.add(row);
  }
  // The export opens with a BOM, which would otherwise hide the first header.
  if (rows.isNotEmpty && rows.first.isNotEmpty) {
    rows.first[0] = rows.first[0].replaceFirst('﻿', '');
  }
  return rows;
}
