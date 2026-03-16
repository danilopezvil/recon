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

  static OptimizationConfig? nextConfig(OptimizationConfig current) {
    if (current.quality > 30) {
      return OptimizationConfig(quality: current.quality - 10, width: current.width, height: current.height);
    }
    final nextW = (current.width * 0.85).round();
    final nextH = (current.height * 0.85).round();
    if (nextW < 480 || nextH < 480) return null;
    return OptimizationConfig(quality: current.quality, width: nextW, height: nextH);
  }

  Future<ImageOptimizationResult> compressToTarget(File inputFile) async {
    var attempts = 0;
    var cfg = const OptimizationConfig(quality: 90, width: 1600, height: 1600);
    final originalBytes = await inputFile.length();
    var current = inputFile;

    while (true) {
      attempts += 1;
      final compressed = await _compress(file: current, quality: cfg.quality, minWidth: cfg.width, minHeight: cfg.height);
      if (compressed == null) break;
      current = compressed;

      final bytes = await current.length();
      if (bytes <= targetMaxBytes) {
        return ImageOptimizationResult(
          file: current,
          originalBytes: originalBytes,
          finalBytes: bytes,
          finalWidth: cfg.width,
          finalHeight: cfg.height,
          targetReached: true,
          attempts: attempts,
        );
      }

      final next = nextConfig(cfg);
      if (next == null) break;
      cfg = next;
    }

    final finalBytes = await current.length();
    return ImageOptimizationResult(
      file: current,
      originalBytes: originalBytes,
      finalBytes: finalBytes,
      finalWidth: cfg.width,
      finalHeight: cfg.height,
      targetReached: finalBytes <= targetMaxBytes,
      attempts: attempts,
    );
  }

  Future<File?> _compress({required File file, required int quality, required int minWidth, required int minHeight}) async {
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
