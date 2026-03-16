import 'package:dio/dio.dart';

class RateLimitInfo {
  const RateLimitInfo({
    this.limit,
    this.remaining,
    this.resetAt,
    this.retryAfter,
  });

  final int? limit;
  final int? remaining;
  final DateTime? resetAt;
  final Duration? retryAfter;
}

class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.kind = ApiErrorKind.unknown,
    this.statusCode,
    this.rateLimit,
  });

  final String message;
  final ApiErrorKind kind;
  final int? statusCode;
  final RateLimitInfo? rateLimit;

  @override
  String toString() => message;
}

enum ApiErrorKind {
  network,
  timeout,
  server,
  client,
  rateLimited,
  serialization,
  unknown,
}

ApiException mapDioError(Object error) {
  if (error is ApiException) {
    return error;
  }

  if (error is FormatException || error is TypeError) {
    return const ApiException(
      'Error al procesar la respuesta del servidor.',
      kind: ApiErrorKind.serialization,
    );
  }

  if (error is DioException) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const ApiException(
        'Tiempo de espera agotado. Intenta nuevamente.',
        kind: ApiErrorKind.timeout,
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return const ApiException(
        'Sin conexión o red inestable. Verifica internet e intenta de nuevo.',
        kind: ApiErrorKind.network,
      );
    }

    final code = error.response?.statusCode;
    if (code == 429) {
      final rateLimit = parseRateLimitInfo(error.response?.headers);
      final retryAfter = rateLimit.retryAfter;
      final seconds = retryAfter?.inSeconds;
      final message = (seconds != null && seconds > 0)
          ? 'Demasiadas solicitudes. Reintenta en ${seconds}s.'
          : 'Demasiadas solicitudes. Intenta nuevamente más tarde.';
      return ApiException(
        message,
        kind: ApiErrorKind.rateLimited,
        statusCode: code,
        rateLimit: rateLimit,
      );
    }

    switch (code) {
      case 400:
        return const ApiException('Solicitud inválida. Revisa los datos enviados.', kind: ApiErrorKind.client, statusCode: 400);
      case 401:
        return const ApiException('Credenciales inválidas. Revisa el token de acceso.', kind: ApiErrorKind.client, statusCode: 401);
      case 404:
        return const ApiException('Recurso no encontrado.', kind: ApiErrorKind.client, statusCode: 404);
      case 413:
        return const ApiException('Imagen demasiado grande. Reduce el peso por debajo de 100 KB.', kind: ApiErrorKind.client, statusCode: 413);
      case 415:
        return const ApiException('Formato de imagen no permitido. Usa JPEG, PNG o WEBP.', kind: ApiErrorKind.client, statusCode: 415);
      case 422:
        return const ApiException('Datos inválidos. Corrige los campos e inténtalo de nuevo.', kind: ApiErrorKind.client, statusCode: 422);
      case 500:
      case 502:
      case 503:
      case 504:
        return ApiException('Servidor no disponible temporalmente. Intenta de nuevo en breve.', kind: ApiErrorKind.server, statusCode: code);
      default:
        return ApiException(
          'Ocurrió un error inesperado al conectar con la API.',
          kind: (code != null && code >= 400 && code < 500) ? ApiErrorKind.client : ApiErrorKind.unknown,
          statusCode: code,
        );
    }
  }

  return const ApiException('Ocurrió un error inesperado.', kind: ApiErrorKind.unknown);
}

RateLimitInfo parseRateLimitInfo(Headers? headers) {
  if (headers == null) return const RateLimitInfo();
  final limit = _toInt(headers.value('X-RateLimit-Limit'));
  final remaining = _toInt(headers.value('X-RateLimit-Remaining'));
  final reset = _toInt(headers.value('X-RateLimit-Reset'));
  final retryAfterSeconds = _toInt(headers.value('Retry-After'));

  DateTime? resetAt;
  if (reset != null && reset > 0) {
    resetAt = DateTime.fromMillisecondsSinceEpoch(reset * 1000, isUtc: true).toLocal();
  }

  return RateLimitInfo(
    limit: limit,
    remaining: remaining,
    resetAt: resetAt,
    retryAfter: retryAfterSeconds == null ? null : Duration(seconds: retryAfterSeconds),
  );
}

int? _toInt(String? raw) => raw == null ? null : int.tryParse(raw.trim());
