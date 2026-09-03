import 'dart:typed_data';

/// Extracts plain-text content from a PDF byte buffer. The crawler
/// extracts transcripts from stdsys as PDFs, but the actual decoder
/// (`syncfusion_flutter_pdf`) transitively pulls in `dart:ui`, so the
/// host app provides the implementation and the package never imports
/// Flutter.
abstract interface class PdfTextExtractor {
  String extract(Uint8List bytes);
}
