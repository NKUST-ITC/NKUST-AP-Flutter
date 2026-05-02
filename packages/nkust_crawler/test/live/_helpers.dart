import 'dart:io';
import 'dart:typed_data';

import 'package:nkust_crawler/nkust_crawler.dart';

/// In-memory [KeyValueStore] so live tests don't pollute / read from the
/// host machine's preference storage. Wired via [configureCrawlerStorage].
class InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> _data = <String, String>{};

  @override
  String getString(String key, String fallback) => _data[key] ?? fallback;

  @override
  void setString(String key, String value) => _data[key] = value;
}

/// Loads BMP glyph templates straight off disk. Used in live tests so the
/// real Euclidean-distance solver can decode webap's captcha without
/// needing Flutter's `rootBundle`.
class FileSystemTemplateProvider implements CaptchaTemplateProvider {
  FileSystemTemplateProvider(this.directory);

  final Directory directory;

  @override
  Future<Uint8List> loadTemplate(String char) async {
    final File file = File('${directory.path}/$char.bmp');
    return file.readAsBytes();
  }
}

/// Locates `assets/eucdist/` regardless of whether the test is run from
/// the repo root or from `packages/nkust_crawler/`.
Directory findTemplateDir() {
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
