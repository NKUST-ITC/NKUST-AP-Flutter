import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

import 'package:zuvio_crawler/src/models/models.dart';

/// Parses the 課程相關 view (`/student5/irs/course/<courseId>/1`).
///
/// The page is a list of `.i-c-c-i-course-info-title` headings each
/// followed by a `.i-c-c-i-course-info-box`. A box is either simple
/// label/value rows (`.i-c-c-i-c-i-b-i-r-title-n` / `-text-n`) or a
/// grid where a header line of `.i-c-c-i-c-i-b-i-r-title` cells is
/// paired with a value line of `.i-c-c-i-c-i-b-i-r-text` cells.
ZuvioCourseInfo parseCourseInfo(String html) {
  final Document doc = parse(html);
  final List<ZuvioInfoSection> sections = <ZuvioInfoSection>[];

  final List<Element> titles =
      doc.querySelectorAll('.i-c-c-i-course-info-title');
  for (final Element title in titles) {
    final Element? box = title.nextElementSibling;
    if (box == null || !box.classes.contains('i-c-c-i-course-info-box')) {
      continue;
    }
    final List<ZuvioInfoRow> rows = <ZuvioInfoRow>[];

    for (final Element row in box.querySelectorAll('.i-c-c-i-c-i-b-info-row')) {
      final List<Element> simpleLabels =
          row.querySelectorAll('.i-c-c-i-c-i-b-i-r-title-n');
      final List<Element> simpleValues =
          row.querySelectorAll('.i-c-c-i-c-i-b-i-r-text-n');
      if (simpleLabels.isNotEmpty) {
        for (int i = 0; i < simpleLabels.length; i++) {
          rows.add(
            ZuvioInfoRow(
              label: simpleLabels[i].text.trim(),
              value: i < simpleValues.length
                  ? simpleValues[i].text.trim()
                  : '',
            ),
          );
        }
        continue;
      }

      final List<Element> gridLabels =
          row.querySelectorAll('.i-c-c-i-c-i-b-i-r-title');
      final List<Element> gridValues =
          row.querySelectorAll('.i-c-c-i-c-i-b-i-r-text');
      for (int i = 0; i < gridLabels.length; i++) {
        rows.add(
          ZuvioInfoRow(
            label: gridLabels[i].text.trim(),
            value: i < gridValues.length ? gridValues[i].text.trim() : '',
          ),
        );
      }
    }

    if (rows.isNotEmpty) {
      sections.add(
        ZuvioInfoSection(title: title.text.trim(), rows: rows),
      );
    }
  }

  return ZuvioCourseInfo(sections: sections);
}
