import 'package:dio/dio.dart';

import '../logging/app_logger.dart';
import 'api_config.dart';

class ApiClient {
  ApiClient(ApiConfig config)
      : dio = Dio(
          BaseOptions(
            baseUrl: config.baseUrl,
            connectTimeout: config.connectTimeout,
            receiveTimeout: config.receiveTimeout,
            sendTimeout: config.sendTimeout,
            headers: {
              'Authorization': 'Bearer ${config.bearerToken}',
              'Accept': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final safeHeaders = Map<String, dynamic>.from(options.headers)
            ..update('Authorization', (_) => 'Bearer ${AppLogger.redact(config.bearerToken)}', ifAbsent: () => '');
          AppLogger.info('HTTP ${options.method} ${options.path} headers=$safeHeaders', tag: 'HTTP');
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.info(
            'HTTP ${response.requestOptions.method} ${response.requestOptions.path} -> ${response.statusCode}',
            tag: 'HTTP',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.error(
            'HTTP error ${error.requestOptions.method} ${error.requestOptions.path} status=${error.response?.statusCode} type=${error.type}',
            tag: 'HTTP',
            error: error.error,
            stackTrace: error.stackTrace,
          );
          handler.next(error);
        },
      ),
    );
  }

  final Dio dio;
}
