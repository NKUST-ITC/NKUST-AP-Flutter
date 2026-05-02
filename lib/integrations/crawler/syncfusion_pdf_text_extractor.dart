import 'dart:typed_data';

import 'package:nkust_crawler/nkust_crawler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

/// [PdfTextExtractor] adapter backed by `syncfusion_flutter_pdf`. Lives in
/// the Flutter app because syncfusion_flutter_pdf transitively depends on
/// `dart:ui` (for `Rect` / `Offset`), which is not available in the
/// pure-Dart `nkust_crawler` package.
class SyncfusionPdfTextExtractor implements PdfTextExtractor {
  const SyncfusionPdfTextExtractor();

  @override
  String extract(Uint8List bytes) {
    final sf.PdfDocument document = sf.PdfDocument(inputBytes: bytes);
    try {
      final sf.PdfTextExtractor extractor = sf.PdfTextExtractor(document);
      return extractor.extractText();
    } finally {
      document.dispose();
    }
  }
}
