import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';


class OptimizationConfig {
  const OptimizationConfig({required this.quality, required this.width, required this.height});

  final int quality;
  final int width;
  final int height;
}

class ImageOptimizationResult {
  const ImageOptimizationResult({
    required this.file,
    required this.originalBytes,
    required this.finalBytes,
    required this.finalWidth,
    required this.finalHeight,
    required this.targetReached,
    required this.attempts,
  });

  final File file;
  final int originalBytes;
  final int finalBytes;
  final int finalWidth;
  final int finalHeight;
  final bool targetReached;
  final int attempts;
}

class ImageOptimizer {
  static const int targetMaxBytes = 50 * 1024;
  static const int _minQuality = 30;
  static const int _minDimension = 480;
  static const int _maxAttempts = 12;
  static OptimizationConfig? nextConfig(OptimizationConfig current) {
    if (current.quality > _minQuality) {
      return OptimizationConfig(
        quality: current.quality - 10,
        width: current.width,
        height: current.height,
      );
    }

    final nextWidth = (current.width * 0.85).round();
    final nextHeight = (current.height * 0.85).round();
    if (nextWidth < _minDimension || nextHeight < _minDimension) {
      return null;
    }

    return OptimizationConfig(
      quality: current.quality,
      width: nextWidth,
      height: nextHeight,
    );
  }


  Future<ImageOptimizationResult> compressToTarget(File inputFile) async {
    final originalBytes = await inputFile.length();
    var quality = 90;
    var width = 1600;
    var height = 1600;
    var attempts = 0;

    File current = inputFile;

    while (attempts < _maxAttempts) {
      attempts += 1;
      final compressed = await _compress(
        file: current,
        quality: quality,
        minWidth: width,
        minHeight: height,
      );

      if (compressed == null) {
        break;
      }

      current = compressed;
      final size = await current.length();
      if (size <= targetMaxBytes) {
        return ImageOptimizationResult(
          file: current,
          originalBytes: originalBytes,
          finalBytes: size,
          finalWidth: width,
          finalHeight: height,
          targetReached: true,
          attempts: attempts,
        );
      }

      final next = nextConfig(
        OptimizationConfig(quality: quality, width: width, height: height),
      );
      if (next == null) {
        break;
      }
      quality = next.quality;
      width = next.width;
      height = next.height;
    }

    final finalBytes = await current.length();
    return ImageOptimizationResult(
      file: current,
      originalBytes: originalBytes,
      finalBytes: finalBytes,
      finalWidth: width,
      finalHeight: height,
      targetReached: finalBytes <= targetMaxBytes,
      attempts: attempts,
    );
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
