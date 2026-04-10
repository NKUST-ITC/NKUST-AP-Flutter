import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart';

class SegmentationException implements Exception {
  final String message;
  SegmentationException(this.message);

  @override
  String toString() => 'SegmentationException: $message';
}

// (label, (minX, minY, maxX, maxY))
typedef CausalNeighborOffsets = MapEntry<int, (int, int, int, int)>;

Future<String> solveByEucDist(Image image) async {
  final Matrix<int> img = imageToMatrix(image);

  final Matrix<int> binaryImg = binaryThreshold(img, 138);
  final (Matrix<int> labeledImg, int numLabels) = label(binaryImg);

  if (numLabels != 4) {
    throw SegmentationException('connected components != 4, found: $numLabels');
  }

  final List<Matrix<int>?> characters = cropImage(labeledImg, numLabels);

  final StringBuffer results = StringBuffer();
  for (final Matrix<int>? charImg in characters) {
    // null is never happened because numLabels == 4
    results.write(await getCharacter(charImg!));
  }
  return results.toString();
}

const String _characters = '123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

/// Load reference images from the assets directory.
final List<Future<Matrix<int>>> _referenceImages =
    List<Future<Matrix<int>>>.generate(_characters.length, (
  int index,
) async {
  final String char = _characters[index];
  final String path = 'assets/eucdist/$char.bmp';
  final Image img = await readImage(path);
  return imageToMatrix(img);
});

/// Calculate the Euclidean distance between two gray-scale images.
num eucDist(Matrix<int> a, Matrix<int> b) {
  if (a.width != b.width || a.height != b.height) {
    throw ArgumentError('Images must have the same dimensions');
  }

  num sum = 0;
  for (int y = 0; y < a.height; y++) {
    for (int x = 0; x < a.width; x++) {
      final num diff = a.get(x, y) - b.get(x, y); // Assuming grayscale images
      sum += diff * diff;
    }
  }

  return sum;
}

/// Get the character represented by the image.
/// The image should be a preprocessed, cropped character gray-scale image.
Future<String> getCharacter(Matrix<int> img) async {
  // Compute distances to reference images
  final List<Future<num>> distances = _referenceImages
      .map((Future<Matrix<int>> ref) async => eucDist(img, await ref))
      .toList();

  // Wait for all distances to be computed
  final List<num> resolvedDistances = await Future.wait(distances);
  // Find the index of the minimum distance
  final int index = resolvedDistances
      .indexOf(resolvedDistances.reduce((num a, num b) => a < b ? a : b));

  return _characters[index];
}

class Matrix<T> {
  final List<List<T>> _data;

  Matrix(this._data) {
    if (_data.isEmpty ||
        _data.any((List<T> row) => row.length != _data[0].length)) {
      throw ArgumentError(
        'All rows must have the same length and matrix cannot be empty.',
      );
    }
  }

  // 2D constructor
  Matrix.fromDimensions(int width, int height, T initialValue)
      : _data = List<List<T>>.generate(
          height,
          (_) => List<T>.filled(width, initialValue),
        );

  // Construct from 2D list
  Matrix.fromList(List<List<T>> data) : _data = data {
    if (data.isEmpty ||
        data.any((List<T> row) => row.length != data[0].length)) {
      throw ArgumentError(
        'All rows must have the same length and matrix cannot be empty.',
      );
    }
  }

  int get width => _data[0].length;
  int get height => _data.length;

  T get(int x, int y) => _data[y][x];
  void set(int x, int y, T value) {
    _data[y][x] = value;
  }

  Matrix<T> clone() {
    return Matrix<T>(_data.map((List<T> row) => List<T>.from(row)).toList());
  }

  Matrix<bool> notEqualMask(T value) {
    final Matrix<bool> result =
        Matrix<bool>.fromDimensions(width, height, false);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        result.set(x, y, _data[y][x] != value);
      }
    }
    return result;
  }

  @override
  String toString() {
    return _data.map((List<T> row) => row.join(' ')).join('\n');
  }
}

extension MatrixIntExtensions on Matrix<int> {
  int max() {
    int maxValue = _data[0][0];
    for (final List<int> row in _data) {
      for (final int value in row) {
        if (value > maxValue) {
          maxValue = value;
        }
      }
    }
    return maxValue;
  }

  List<int> unique() {
    final Set<int> values = <int>{};
    for (final List<int> row in _data) {
      values.addAll(row);
    }
    return values.toList();
  }
}

/// Read an image from the given path.
/// Throws [PathNotFoundException] if the file is not found.
/// Throws [Exception] if there is an error reading the image.
Future<Image> readImage(String path) async {
  final ByteData byteData = await rootBundle.load(path);
  final Uint8List bytes = byteData.buffer.asUint8List();
  final Image? img = decodeBmp(bytes);
  if (img == null) {
    throw Exception('Failed to decode image: $path');
  }
  return img;
}

Matrix<int> imageToMatrix(Image image) {
  final int width = image.width;
  final int height = image.height;

  return Matrix<int>.fromList(
    List<List<int>>.generate(
      height,
      (int y) => List<int>.generate(
        width,
        (int x) => getLuminance(image.getPixel(x, y)).toInt(),
      ),
    ),
  );
}

Matrix<int> binaryThreshold(Matrix<int> image, int threshold) {
  final Matrix<int> result =
      Matrix<int>.fromDimensions(image.width, image.height, 0);
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      result.set(x, y, image.get(x, y) < threshold ? 255 : 0);
    }
  }
  return result;
}

Matrix<int> _cropAndPad(
  Matrix<int> labeledImage,
  int x,
  int y,
  int width,
  int height,
) {
  final Matrix<int> result = Matrix<int>.fromDimensions(width, height, 0);

  // Crop the image
  for (int j = 0; j < height; j++) {
    for (int i = 0; i < width; i++) {
      result.set(i, j, labeledImage.get(x + i, y + j));
    }
  }

  /// Add padding to make it square
  /// The final size is 22x22
  assert(width > 0 && height > 0 && width <= 22 && height <= 22);

  final Matrix<int> canvas = Matrix<int>.fromDimensions(22, 22, 0);
  final int offsetX = (22 - width) ~/ 2;
  final int offsetY = (22 - height) ~/ 2;
  for (int j = 0; j < height; j++) {
    for (int i = 0; i < width; i++) {
      canvas.set(offsetX + i, offsetY + j, result.get(i, j) > 0 ? 255 : 0);
    }
  }

  return canvas;
}

List<Matrix<int>?> cropImage(
  Matrix<int> labeledImage,
  int labelCount, {
  int bgColor = 0,
}) {
  final Map<int, (int, int, int, int)> bboxes =
      <int, (int, int, int, int)>{}; // label -> (minX, minY, maxX, maxY)
  for (int label = 1; label <= labelCount; label++) {
    int minX = labeledImage.width;
    int minY = labeledImage.height;
    int maxX = 0;
    int maxY = 0;

    for (int y = 0; y < labeledImage.height; y++) {
      for (int x = 0; x < labeledImage.width; x++) {
        if (labeledImage.get(x, y) == label) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }

    // filter out too small boxes
    if (maxX - minX < 5 || maxY - minY < 5) continue;
    bboxes[label] = (minX, minY, maxX, maxY);
  }

  // Sort bounding boxes by x coordinate
  final List<CausalNeighborOffsets> sortedBboxes = bboxes.entries.toList()
    ..sort(
      (
        CausalNeighborOffsets a,
        CausalNeighborOffsets b,
      ) =>
          a.value.$1.compareTo(b.value.$1),
    );

  // Crop characters
  // Use fixed length list to avoid dynamic resizing, length should be 4
  final List<Matrix<int>?> result = List<Matrix<int>?>.filled(4, null);
  int index = 0;
  for (final CausalNeighborOffsets bbox in sortedBboxes) {
    final (int minX, int minY, int maxX, int maxY) = bbox.value;
    final Matrix<int> cropped = _cropAndPad(
      labeledImage,
      minX,
      minY,
      maxX - minX + 1,
      maxY - minY + 1,
    );
    result[index++] = cropped;
  }
  return result;
}

/// Connected-component labeling
/// Labels the connected components of a binary image.
///
/// Parameters:
/// - [a]: A 2D binary matrix.
/// - [structure]: A 2D matrix defining the connectivity. If null, defaults to 4-connectivity.
/// - [background]: The pixel value representing the background. Defaults to 0.
///
/// Returns:
/// A tuple containing:
/// - A 2D matrix with labeled connected components.
/// - The number of connected components found.
(Matrix<int>, int) label(
  Matrix<int> a, {
  Matrix<int>? structure,
  int? background = 0,
}) {
  // Validate input image
  if (a.width == 0 || a.height == 0) {
    throw ArgumentError('Cannot label an empty image.');
  }

  final Matrix<bool> foreground = a.notEqualMask(background!);

  // Construct footprint
  // Default to 4-connectivity
  structure ??= Matrix<int>.fromList(<List<int>>[
    <int>[0, 1, 0],
    <int>[1, 1, 1],
    <int>[0, 1, 0],
  ]);

  final List<List<int>> neighborOffsets =
      _computeCausalNeighborOffsets(structure);

  final Matrix<int> labels = Matrix<int>.fromDimensions(a.width, a.height, 0);

  // Union-Find data structure
  final List<int> parent = <int>[];
  final List<int> rank = <int>[];

  int ufMake() {
    parent.add(parent.length);
    rank.add(0);
    return parent.length - 1;
  }

  /// Path compression
  int ufFind(int x) {
    int root = x;
    while (parent[root] != root) {
      root = parent[root];
    }

    int curr = x;
    while (parent[curr] != curr) {
      final int next = parent[curr];
      parent[curr] = root;
      curr = next;
    }
    return root;
  }

  int ufUnion(int x, int y) {
    final int rootX = ufFind(x);
    final int rootY = ufFind(y);
    if (rootX == rootY) return rootX;
    if (rank[rootX] < rank[rootY]) {
      parent[rootX] = rootY;
      return rootY;
    } else if (rank[rootX] > rank[rootY]) {
      parent[rootY] = rootX;
      return rootX;
    } else {
      parent[rootY] = rootX;
      rank[rootX]++;
      return rootX;
    }
  }

  // First pass
  for (int y = 0; y < a.height; y++) {
    for (int x = 0; x < a.width; x++) {
      if (!foreground.get(x, y)) continue;

      final Set<int> neighborLabels = <int>{};

      for (final List<int> offset in neighborOffsets) {
        final int nx = x + offset[0];
        final int ny = y + offset[1];
        if (nx >= 0 && nx < a.width && ny >= 0 && ny < a.height) {
          final int neighborLabel = labels.get(nx, ny);
          if (neighborLabel > 0) {
            neighborLabels.add(neighborLabel);
          }
        }
      }

      if (neighborLabels.isEmpty) {
        // New component
        final int newLabel = ufMake() + 1; // Labels start from 1
        labels.set(x, y, newLabel);
      } else {
        // Assign the smallest label among neighbors
        final int minLabel =
            neighborLabels.reduce((int a, int b) => a < b ? a : b);
        labels.set(x, y, minLabel);

        // Union all neighbor labels
        for (final int nl in neighborLabels) {
          ufUnion(minLabel - 1, nl - 1); // Convert to zero-based index
        }
      }
    }
  }

  // Second pass
  if (labels.max() == 0) return (labels, 0);

  final List<int> used = labels.unique();
  used.remove(0); // Remove background (label 0)

  final Map<int, int> roots = <int, int>{};
  for (final int label in used) {
    final int root = ufFind(label - 1); // Convert to zero-based index
    roots[label] = root;
  }

  // Relabeling
  final List<int> rootSet = <int>[];
  final Set<int> seen = <int>{};
  for (final int lab in used) {
    final int r = roots[lab]!;
    if (!seen.contains(r)) {
      seen.add(r);
      rootSet.add(r);
    }
  }
  rootSet.sort();

  final Map<int, int> rootToCompact = <int, int>{};
  for (int i = 0; i < rootSet.length; i++) {
    rootToCompact[rootSet[i]] = i + 1; // Compact labels start from 1
  }

  final Map<int, int> labToCompact = <int, int>{};
  for (final int lab in used) {
    final int r = roots[lab]!;
    labToCompact[lab] = rootToCompact[r]!;
  }

  final int maxLab = labels.max();
  final List<int> lut = List<int>.filled(maxLab + 1, 0);
  for (final MapEntry<int, int> entry in labToCompact.entries) {
    lut[entry.key] = entry.value;
  }

  // Apply LUT
  final Matrix<bool> mask = labels.notEqualMask(0);
  for (int y = 0; y < a.height; y++) {
    for (int x = 0; x < a.width; x++) {
      if (mask.get(x, y)) {
        final int oldLabel = labels.get(x, y);
        labels.set(x, y, lut[oldLabel]);
      }
    }
  }

  return (labels, rootSet.length);
}

List<List<int>> _computeCausalNeighborOffsets(Matrix<int> structure) {
  final List<List<int>> offsets = <List<int>>[];
  final int centerX = structure.width ~/ 2;
  final int centerY = structure.height ~/ 2;

  for (int y = 0; y < structure.height; y++) {
    for (int x = 0; x < structure.width; x++) {
      if (structure.get(x, y) == 0) continue;

      // Only consider neighbors above and to the left of the center
      if (y < centerY || (y == centerY && x < centerX)) {
        offsets.add(<int>[x - centerX, y - centerY]);
      }
    }
  }

  return offsets;
}
