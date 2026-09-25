import 'dart:typed_data';

import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

/// The visual rows of text in [bytes], blank ones dropped.
///
/// `extractText()` is the obvious call and the wrong one here: it breaks a
/// line wherever the font changes, so a heading that mixes Chinese with
/// Arabic numerals arrives as three fragments and nothing that reads a line
/// at a time can match it. `extractTextLines()` returns rows as laid out,
/// which is what the calendar's `單位(日期)標題` entries need.
List<String> extractPdfTextLines(Uint8List bytes) {
  final sf.PdfDocument document = sf.PdfDocument(inputBytes: bytes);
  try {
    return <String>[
      for (final sf.TextLine line in sf.PdfTextExtractor(document)
          .extractTextLines())
        if (line.text.trim().isNotEmpty) line.text.trim(),
    ];
  } finally {
    document.dispose();
  }
}
