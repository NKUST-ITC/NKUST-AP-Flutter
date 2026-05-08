import 'dart:typed_data';

/// Resolves the reference glyph templates used by the Euclidean-distance
/// captcha solver. The crawler ships the algorithm but never the assets
/// themselves, so host apps inject their own loader (`rootBundle`-backed
/// in Flutter, filesystem-backed for CLI / server, in-memory for tests).
///
/// Implementations must return raw BMP bytes for the requested character
/// (`'1'..'9'`, `'A'..'Z'` excluding ambiguous glyphs the captcha never
/// emits). Throw if a template is missing — the solver treats absence as
/// a fatal configuration bug rather than a recoverable miss.
abstract interface class CaptchaTemplateProvider {
  Future<Uint8List> loadTemplate(String char);
}
