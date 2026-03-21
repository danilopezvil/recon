import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_config.dart';
import '../core/network/dio_client.dart';
import '../data/datasources/http_item_remote_data_source.dart';
import '../data/datasources/item_remote_data_source.dart';
import '../data/local/history_local_store.dart';
import '../data/repositories/item_processing_repository.dart';
import '../domain/repositories/history_repository.dart';
import '../domain/services/item_processing_service.dart';
import '../features/settings/application/api_key_notifier.dart';

/// Rebuilds whenever the user changes the API key in Settings.
final apiConfigProvider = Provider<ApiConfig>((ref) {
  final keyState = ref.watch(apiKeyNotifierProvider);
  return ApiConfig(
    baseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://home-saledl.vercel.app',
    ),
    bearerToken: keyState.key,
    connectTimeout: Duration(
      seconds: int.fromEnvironment('API_CONNECT_TIMEOUT_SEC', defaultValue: 8),
    ),
    receiveTimeout: Duration(
      seconds: int.fromEnvironment('API_RECEIVE_TIMEOUT_SEC', defaultValue: 18),
    ),
    sendTimeout: Duration(
      seconds: int.fromEnvironment('API_SEND_TIMEOUT_SEC', defaultValue: 18),
    ),
  );
});

/// ref.watch ensures the client rebuilds when the config changes.
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(apiConfigProvider)),
);

final itemRemoteDataSourceProvider = Provider<ItemRemoteDataSource>(
  (ref) => HttpItemRemoteDataSource(ref.watch(apiClientProvider).dio),
);

final itemProcessingServiceProvider = Provider<ItemProcessingService>(
  (ref) => ItemProcessingRepository(ref.watch(itemRemoteDataSourceProvider)),
);

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryLocalStore(),
);
