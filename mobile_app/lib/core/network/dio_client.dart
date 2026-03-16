import 'package:dio/dio.dart';

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
        );

  final Dio dio;
}
