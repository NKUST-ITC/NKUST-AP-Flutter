import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

const List<String> labels = <String>[
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  '0',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
];

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
      final Interpreter interpreter = await Interpreter.fromAsset(
        'assets/webap_captcha.tflite',
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
          x: (imageWidth ~/ digitsCount) * i,
          y: 0,
          width: w,
          height: h,
        );
        final List<dynamic> output =
            List<dynamic>.filled(1 * labels.length, 0).reshape(<int>[
          1,
          labels.length,
        ]);
        interpreter.run(
          imageToByteListFloat32(target, w, h, 127.5, 255.0),
          output,
        );
        if (output.first case final List<double> list?) {
          final List<double> flattedOutputs = list.toList();
          flattedOutputs.sort();
          final int maxIndex = list.indexOf(flattedOutputs.last);
          replaceText.write(labels[maxIndex]);
        }
      }
      end = DateTime.now();
      final int processTime =
          end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
      log('process time = $processTime ms');
      log(replaceText.toString());
      interpreter.close();
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
        buffer[pixelIndex] = (image.getPixel(j, i).r) / std;
        pixelIndex++;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }
}
