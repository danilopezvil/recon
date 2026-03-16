import 'package:dio/dio.dart';

import '../../domain/models/analyzed_item.dart';
import '../../domain/models/publish_payload.dart';
import 'item_remote_data_source.dart';

/// Preparado para Fase posterior: integración API real.
class HttpItemRemoteDataSource implements ItemRemoteDataSource {
  HttpItemRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<AnalyzedItem> analyzeItem(String imagePath) async {
    throw UnimplementedError('Pendiente conexión con API real de análisis.');
  }

  @override
  Future<bool> publishItem(PublishPayload payload) async {
    throw UnimplementedError('Pendiente conexión con API real de publicación.');
  }
}
