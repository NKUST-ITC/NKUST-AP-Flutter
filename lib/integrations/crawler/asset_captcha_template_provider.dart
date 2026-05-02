import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:nkust_crawler/nkust_crawler.dart';

/// [CaptchaTemplateProvider] that resolves glyph BMPs from the Flutter
/// app's `assets/eucdist/` bundle. Lives in the host app so the pure-Dart
/// `nkust_crawler` package never imports `flutter/services.dart`.
class AssetCaptchaTemplateProvider implements CaptchaTemplateProvider {
  const AssetCaptchaTemplateProvider();

  @override
  Future<Uint8List> loadTemplate(String char) async {
    final ByteData data = await rootBundle.load('assets/eucdist/$char.bmp');
    return data.buffer.asUint8List();
  }
}
