import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'eucdist.dart' as eucdist;

class CaptchaUtils {
  CaptchaUtils._();

  static Future<String> extractByEucDist({
    required Uint8List bodyBytes,
  }) async {
    const int digitsCount = 4;
    const int imageHeight = 40;
    const int imageWidth = 85;
    try {
      final Directory directory = await getTemporaryDirectory();
      final String imagePath = join(
        directory.path,
        'tmp.jpg',
      );
      await File(imagePath).writeAsBytes(bodyBytes);
      DateTime start = DateTime.now();
      DateTime end = DateTime.now();
      final img.Image source =
          img.decodeImage(File(imagePath).readAsBytesSync())!;
      

      final String result = await eucdist.solveByEucDist(source);


      end = DateTime.now();
      final int processTime =
          end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
      log('process time = $processTime ms');
      log(result);
      return result;
    } catch (_) {
      rethrow;
    }
  }

  static Uint8List imageToByteListFloat32(
    img.Image image,
    int w,
    int h,
    double mean,
    double std,
  ) {
    final Float32List convertedBytes = Float32List(1 * w * h * 1);
    final Float32List buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (int i = 0; i < h; i++) {
      for (int j = 0; j < w; j++) {
        buffer[pixelIndex] = (image.getPixel(j, i).r) / std;
        pixelIndex++;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }
}
