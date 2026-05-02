import 'dart:developer';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:nkust_crawler/src/abstractions/captcha_solver.dart';
import 'package:nkust_crawler/src/abstractions/captcha_template_provider.dart';
import 'package:nkust_crawler/src/captcha/eucdist.dart';

/// Default [CaptchaSolver]: Euclidean-distance template matching against a
/// fixed glyph set. Templates are loaded once via the injected
/// [CaptchaTemplateProvider] and cached for the lifetime of this instance.
class EuclideanCaptchaSolver implements CaptchaSolver {
  EuclideanCaptchaSolver(this._templateProvider);

  final CaptchaTemplateProvider _templateProvider;
  Future<List<Matrix<int>>>? _references;

  Future<List<Matrix<int>>> _loadReferences() {
    return _references ??= loadReferenceMatrices(_templateProvider);
  }

  @override
  Future<String> solve(Uint8List imageBytes) async {
    final DateTime start = DateTime.now();
    final img.Image? source = img.decodeJpg(imageBytes);
    if (source == null) {
      throw Exception('Failed to decode verification code image.');
    }
    final List<Matrix<int>> references = await _loadReferences();
    final String result = await solveByEucDist(source, references);
    final int processTime =
        DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch;
    log('captcha solve = $processTime ms ($result)');
    return result;
  }
}
