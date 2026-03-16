import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recon_mobile_app/core/network/api_error.dart';

void main() {
  test('maps 413 to image size message', () {
    final err = DioException(
      requestOptions: RequestOptions(path: '/api/items/analyze'),
      response: Response(requestOptions: RequestOptions(path: '/api/items/analyze'), statusCode: 413),
    );

    final mapped = mapDioError(err);
    expect(mapped.message, contains('100 KB'));
  });
}
