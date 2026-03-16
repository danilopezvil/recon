import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageOptimizer {
  static const int targetMaxBytes = 50 * 1024;

  Future<File> compressToTarget(File inputFile) async {
    var quality = 90;
    var minWidth = 1600;
    var minHeight = 1600;

    File? compressed = await _compress(
      file: inputFile,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
    );

    while (compressed != null && await compressed.length() > targetMaxBytes) {
      if (quality > 30) {
        quality -= 10;
      } else {
        minWidth = (minWidth * 0.85).round();
        minHeight = (minHeight * 0.85).round();
      }

      if (minWidth < 480 || minHeight < 480) break;

      final next = await _compress(
        file: compressed,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
      );
      if (next == null) break;
      compressed = next;
    }

    return compressed ?? inputFile;
  }

  Future<File?> _compress({
    required File file,
    required int quality,
    required int minWidth,
    required int minHeight,
  }) async {
    final dir = await getTemporaryDirectory();
    final outPath = '${dir.path}/${const Uuid().v4()}.jpg';

    final x = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
      format: CompressFormat.jpeg,
    );

    return x == null ? null : File(x.path);
  }
}
