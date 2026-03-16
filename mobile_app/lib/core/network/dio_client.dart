import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({String baseUrl = 'https://future-api.example.com'})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 20),
            sendTimeout: const Duration(seconds: 20),
            headers: const {'Content-Type': 'application/json'},
          ),
        );

  final Dio dio;
}
