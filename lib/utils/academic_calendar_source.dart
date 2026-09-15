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

const String _site = 'https://acad.nkust.edu.tw';

/// Reading the calendars costs a few hundred KB of PDF, and the registry
/// publishes one semester at a time — months apart. Checking daily would be
/// spending a student's data to re-read documents that have not changed.
const Duration pdfRefreshInterval = Duration(days: 7);

Dio _client() {
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: const <String, String>{'user-agent': 'nkust-ap'},
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
  final Dio dio = _client();
  try {
    final List<({String name, String url})> listed;
    try {
      final Response<String> response = await dio.get<String>(
        _csvUrl,
        options: Options(responseType: ResponseType.plain),
      );
      listed = listCalendarPdfs(response.data ?? '');
    } on DioException catch (e) {
      debugPrint('[calendar] index unreachable: ${e.type}');
      return null;
    }
    if (listed.isEmpty) return null;

    final Map<String, List<Map<String, String>>> parsed =
        <String, List<Map<String, String>>>{};
    for (final ({String name, String url}) entry in listed) {
      try {
        final Response<List<int>> response = await dio.get<List<int>>(
          entry.url,
          options: Options(responseType: ResponseType.bytes),
        );
        final List<int>? body = response.data;
        if (body == null) continue;
        // Off the main isolate: a semester is a 160KB PDF and there are
        // several, which is long enough to drop frames if it ran here.
        final ParsedCalendar? document = await compute(
          parseCalendarDocument,
          Uint8List.fromList(body),
        );
        if (document == null) {
          // One unreadable document is not a reason to discard the others —
          // the window only needs the semesters around today.
          debugPrint('[calendar] ${entry.name} did not parse, skipping');
          continue;
        }
        parsed[document.code] = document.events;
      } on DioException catch (e) {
        debugPrint('[calendar] ${entry.name} unreachable: ${e.type}');
      }
    }
    if (parsed.isEmpty) return null;

    final String? current =
        pickCurrentSemester(parsed, now ?? DateTime.now());
    if (current == null) return null;
    final List<String> window = semestersAround(parsed.keys, current);
    debugPrint('[calendar] current $current, bundling ${window.join(', ')}');
    return mergeSemesters(parsed, window);
  } finally {
    dio.close();
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

/// The Chinese-language calendars the sheet lists, as (name, absolute url).
List<({String name, String url})> listCalendarPdfs(String csv) {
  final List<List<String>> rows = parseCsv(csv);
  if (rows.isEmpty) return <({String name, String url})>[];
  final List<String> header =
      rows.first.map((String h) => h.trim()).toList();
  final int subgroup = header.indexOf('Subgroup');
  final int filename = header.indexOf('Filename');
  final int url = header.indexOf('URL');
  if (subgroup < 0 || filename < 0 || url < 0) {
    return <({String name, String url})>[];
  }

  final List<({String name, String url})> found =
      <({String name, String url})>[];
  for (final List<String> row in rows.skip(1)) {
    if (row.length <= subgroup || row.length <= url) continue;
    if (row[subgroup].trim() != '中文版') continue;
    final String href = row[url].trim();
    if (!href.toLowerCase().endsWith('.pdf')) continue;
    found.add((
      name: row.length > filename ? row[filename].trim() : '',
      url: href.startsWith('http') ? href : '$_site$href',
    ));
  }
  return found;
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
