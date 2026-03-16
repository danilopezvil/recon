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
    expect(mapped.kind, ApiErrorKind.client);
  });

  test('maps timeout and connectivity distinctly', () {
    final timeout = DioException(
      type: DioExceptionType.connectionTimeout,
      requestOptions: RequestOptions(path: '/api/items/analyze'),
    );
    final network = DioException(
      type: DioExceptionType.connectionError,
      requestOptions: RequestOptions(path: '/api/items/analyze'),
    );

    expect(mapDioError(timeout).kind, ApiErrorKind.timeout);
    expect(mapDioError(network).kind, ApiErrorKind.network);
  });

  test('maps 429 and rate limit headers', () {
    final response = Response(
      requestOptions: RequestOptions(path: '/api/items/confirm'),
      statusCode: 429,
      headers: Headers.fromMap({
        'X-RateLimit-Limit': ['100'],
        'X-RateLimit-Remaining': ['0'],
        'X-RateLimit-Reset': ['1893456000'],
        'Retry-After': ['45'],
      }),
    );

    final err = DioException(requestOptions: response.requestOptions, response: response);
    final mapped = mapDioError(err);

    expect(mapped.kind, ApiErrorKind.rateLimited);
    expect(mapped.rateLimit?.limit, 100);
    expect(mapped.rateLimit?.remaining, 0);
    expect(mapped.rateLimit?.retryAfter?.inSeconds, 45);
    expect(mapped.message, contains('45s'));
  });
}
