import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:nkust_crawler/nkust_crawler.dart';
import 'package:nkust_crawler/src/captcha/eucdist.dart';
import 'package:test/test.dart';

/// Loads BMP glyph templates straight off disk. Used as a stand-in for the
/// host app's [AssetCaptchaTemplateProvider] in unit tests.
class FileSystemTemplateProvider implements CaptchaTemplateProvider {
  FileSystemTemplateProvider(this.directory);

  final Directory directory;

  @override
  Future<Uint8List> loadTemplate(String char) async {
    final File file = File('${directory.path}/$char.bmp');
    return file.readAsBytes();
  }
}

/// Locates `assets/eucdist/` regardless of whether the test is run from the
/// repo root or the package directory.
Directory _findTemplateDir() {
  for (final String candidate in <String>[
    'assets/eucdist',
    '../../assets/eucdist',
  ]) {
    final Directory dir = Directory(candidate);
    if (dir.existsSync()) return dir;
  }
  throw StateError(
    'Could not locate assets/eucdist relative to ${Directory.current.path}',
  );
}

void main() {
  group('EuclideanCaptchaSolver', () {
    late Directory templateDir;
    late FileSystemTemplateProvider provider;

    setUpAll(() {
      templateDir = _findTemplateDir();
      provider = FileSystemTemplateProvider(templateDir);
    });

    test('loadReferenceMatrices loads every glyph in captchaCharset', () async {
      final List<Matrix<int>> matrices = await loadReferenceMatrices(provider);
      expect(matrices, hasLength(captchaCharset.length));
      // All templates are 22×22 binarised BMPs.
      for (final Matrix<int> m in matrices) {
        expect(m.width, 22);
        expect(m.height, 22);
      }
    });

    test('eucDist of identical matrices is zero', () async {
      final List<Matrix<int>> matrices = await loadReferenceMatrices(provider);
      for (final Matrix<int> m in matrices) {
        expect(eucDist(m, m), 0);
      }
    });

    test('getCharacter recovers each glyph from its own template', () async {
      final List<Matrix<int>> matrices = await loadReferenceMatrices(provider);
      for (int i = 0; i < captchaCharset.length; i++) {
        final String expected = captchaCharset[i];
        final String recovered = getCharacter(matrices[i], matrices);
        expect(
          recovered,
          expected,
          reason: 'matrix at index $i should match its own template',
        );
      }
    });

    test('solve throws on an undecodable JPEG', () async {
      final EuclideanCaptchaSolver solver = EuclideanCaptchaSolver(provider);
      expect(
        () => solver.solve(Uint8List.fromList(<int>[0, 1, 2, 3])),
        throwsA(isA<Exception>()),
      );
    });

    test('solve throws SegmentationException for an all-white image',
        () async {
      // 4 connected components are required; a blank image has zero, so the
      // segmentation step should reject it.
      final img.Image blank = img.Image(width: 60, height: 32);
      img.fill(blank, color: img.ColorRgb8(255, 255, 255));
      final Uint8List jpeg = Uint8List.fromList(img.encodeJpg(blank));

      final EuclideanCaptchaSolver solver = EuclideanCaptchaSolver(provider);
      expect(
        () => solver.solve(jpeg),
        throwsA(isA<SegmentationException>()),
      );
    });
  });
}
