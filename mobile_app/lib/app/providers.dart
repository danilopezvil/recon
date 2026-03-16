import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_config.dart';
import '../core/network/dio_client.dart';
import '../data/datasources/http_item_remote_data_source.dart';
import '../data/datasources/item_remote_data_source.dart';
import '../data/local/history_local_store.dart';
import '../data/repositories/item_processing_repository.dart';
import '../domain/repositories/history_repository.dart';
import '../domain/services/item_processing_service.dart';
import '../features/capture/application/workflow_controller.dart';

final apiConfigProvider = Provider<ApiConfig>((ref) => ApiConfig.fromEnvironment());

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref.read(apiConfigProvider)));

final itemRemoteDataSourceProvider = Provider<ItemRemoteDataSource>(
  (ref) => HttpItemRemoteDataSource(ref.read(apiClientProvider).dio),
);

final itemProcessingServiceProvider = Provider<ItemProcessingService>(
  (ref) => ItemProcessingRepository(ref.read(itemRemoteDataSourceProvider)),
);

final historyRepositoryProvider = Provider<HistoryRepository>((ref) => HistoryLocalStore());

final workflowControllerProvider = StateNotifierProvider<WorkflowController, WorkflowState>(
  (ref) => WorkflowController(ref.read(itemProcessingServiceProvider), ref.read(historyRepositoryProvider)),
);
