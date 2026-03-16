import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

ApiException mapDioError(Object error) {
  if (error is DioException) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const ApiException('Error de conectividad. Verifica tu conexión e intenta de nuevo.');
    }

    final code = error.response?.statusCode;
    switch (code) {
      case 400:
        return const ApiException('Solicitud inválida. Revisa los datos enviados.');
      case 401:
        return const ApiException('Credenciales inválidas. Revisa el token de acceso.');
      case 404:
        return const ApiException('Recurso no encontrado.');
      case 413:
        return const ApiException('Imagen demasiado grande. Reduce el peso por debajo de 100 KB.');
      case 415:
        return const ApiException('Formato de imagen no permitido. Usa JPEG, PNG o WEBP.');
      case 422:
        return const ApiException('Datos inválidos. Corrige los campos e inténtalo de nuevo.');
      case 429:
        return const ApiException('Demasiadas solicitudes. Intenta nuevamente más tarde.');
      case 500:
        return const ApiException('Error interno del servidor.');
      case 503:
        return const ApiException('Servicio no disponible temporalmente.');
      default:
        return const ApiException('Ocurrió un error inesperado al conectar con la API.');
    }
  }

  return const ApiException('Ocurrió un error inesperado.');
}
