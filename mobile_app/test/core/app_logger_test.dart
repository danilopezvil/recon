import 'package:flutter_test/flutter_test.dart';
import 'package:recon_mobile_app/core/logging/app_logger.dart';

void main() {
  test('redacts sensitive values', () {
    expect(AppLogger.redact('super-secret-token'), startsWith('supe'));
    expect(AppLogger.redact('super-secret-token'), contains('***'));
    expect(AppLogger.redact(''), '<empty>');
  });
}
