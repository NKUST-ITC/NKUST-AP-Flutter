import 'dart:developer';
// import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:nkust_ap/utils/eucdist.dart' as eucdist;
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';

class CaptchaUtils {
  CaptchaUtils._();

  static Future<String> extractByEucDist({
    required Uint8List bodyBytes,
  }) async {
    try {
      // final Directory directory = await getTemporaryDirectory();
      // final String imagePath = join(
      //   directory.path,
      //   'tmp.jpg',
      // );
      // await File(imagePath).writeAsBytes(bodyBytes);
      final DateTime start = DateTime.now();
      // final img.Image source =
      //     img.decodeImage(File(imagePath).readAsBytesSync())!;
      final img.Image? source = img.decodeJpg(bodyBytes);

      if (source == null) {
        throw Exception('Failed to decode verification code image.');
      }

      final String result = await eucdist.solveByEucDist(source);

      final DateTime end = DateTime.now();
      final int processTime =
          end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
      log('process time = $processTime ms');
      log(result);
      return result;
    } catch (_) {
      rethrow;
    }
  }
}
