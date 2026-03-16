class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    required this.bearerToken,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 20),
    this.sendTimeout = const Duration(seconds: 20),
  });

  factory ApiConfig.fromEnvironment() {
    return ApiConfig(
      baseUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.example.com'),
      bearerToken: const String.fromEnvironment('API_SECRET_KEY', defaultValue: ''),
      connectTimeout: Duration(seconds: int.fromEnvironment('API_CONNECT_TIMEOUT_SEC', defaultValue: 10)),
      receiveTimeout: Duration(seconds: int.fromEnvironment('API_RECEIVE_TIMEOUT_SEC', defaultValue: 20)),
      sendTimeout: Duration(seconds: int.fromEnvironment('API_SEND_TIMEOUT_SEC', defaultValue: 20)),
    );
  }

  final String baseUrl;
  final String bearerToken;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
}
