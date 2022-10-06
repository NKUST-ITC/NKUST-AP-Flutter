import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';

class CaptchaUtils {
  CaptchaUtils._();

  static Future<String> extractByTfLite({
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
      final img.Image grayscaleImage = img.grayscale(source);
      start = DateTime.now();
      await Tflite.loadModel(
        model: 'assets/webap_captcha.tflite',
        labels: 'assets/labels.txt',
      );
      end = DateTime.now();
      final int loadModelTime =
          end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
      log('loadModel time = $loadModelTime ms');
      final StringBuffer replaceText = StringBuffer();
      start = DateTime.now();
      const int w = imageWidth ~/ digitsCount;
      const int h = imageHeight;
      for (int i = 0; i < digitsCount; i++) {
        final img.Image target = img.copyCrop(
          grayscaleImage,
          (imageWidth ~/ digitsCount) * i,
          0,
          w,
          h,
        );
        final List<dynamic>? recognitions = await Tflite.runModelOnBinary(
          binary: imageToByteListFloat32(target, w, h, 127.5, 255.0),
          // required
          numResults: 1,
          // defaults to 5
          threshold: 0.05,
          // defaults to 0.1
        );
        if (recognitions != null && recognitions.isNotEmpty) {
          final Map<Object?, Object?> map =
              recognitions.first as Map<Object?, Object?>;
          replaceText.write(map['label'] as String?);
        }
      }
      end = DateTime.now();
      final int processTime =
          end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
      log('process time = $processTime ms');
      log(replaceText.toString());
      return replaceText.toString();
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
        final int pixel = image.getPixel(j, i);
        buffer[pixelIndex] = (img.getRed(pixel)) / std;
        pixelIndex++;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }
}
