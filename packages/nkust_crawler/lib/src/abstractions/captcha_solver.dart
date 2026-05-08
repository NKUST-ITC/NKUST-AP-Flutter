import 'dart:typed_data';

/// Solves the per-login captcha image returned by webap. The crawler does
/// not assume any particular OCR backend — host apps can plug in the
/// shipped Euclidean-distance solver, a TFLite model, or even a manual
/// "ask the user" prompt for testing.
///
/// Implementations should:
/// - return the recognised 4-character code on success;
/// - throw if segmentation / decoding fails so the caller's retry loop
///   can fetch a fresh image.
abstract interface class CaptchaSolver {
  Future<String> solve(Uint8List imageBytes);
}
