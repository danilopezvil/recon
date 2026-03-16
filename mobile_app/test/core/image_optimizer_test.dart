import 'package:flutter_test/flutter_test.dart';
import 'package:recon_mobile_app/core/utils/image_optimizer.dart';

void main() {
  test('nextConfig decreases quality first', () {
    const start = OptimizationConfig(quality: 90, width: 1600, height: 1600);
    final next = ImageOptimizer.nextConfig(start);

    expect(next, isNotNull);
    expect(next!.quality, 80);
    expect(next.width, 1600);
    expect(next.height, 1600);
  });

  test('nextConfig decreases dimensions at min quality', () {
    const start = OptimizationConfig(quality: 30, width: 1000, height: 1000);
    final next = ImageOptimizer.nextConfig(start);

    expect(next, isNotNull);
    expect(next!.quality, 30);
    expect(next.width, lessThan(1000));
  });

  test('nextConfig returns null when below minimum dimension', () {
    const start = OptimizationConfig(quality: 30, width: 500, height: 500);
    final next = ImageOptimizer.nextConfig(start);
    expect(next, isNull);
  });
}
