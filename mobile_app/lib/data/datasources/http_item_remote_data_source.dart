import 'package:dio/dio.dart';

import '../../core/network/api_error.dart';
import '../../domain/models/analyze_draft_result.dart';
import '../../domain/models/confirm_draft_payload.dart';
import '../../domain/models/publish_payload.dart';
import '../../domain/models/published_item.dart';
import '../dtos/item_dtos.dart';
import '../mappers/item_dto_mappers.dart';
import 'item_remote_data_source.dart';

class HttpItemRemoteDataSource implements ItemRemoteDataSource {
  HttpItemRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<AnalyzeDraftResult> analyzeItem(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });
      final response = await _dio.post<Map<String, dynamic>>('/api/items/analyze', data: formData);
      final dto = AnalyzeResponseDto.fromJson(response.data ?? const {});
      return mapAnalyzeResponseToDomain(dto);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<PublishedItem> confirmDraft(ConfirmDraftPayload payload) async {
    try {
      final body = mapConfirmPayloadToDto(payload).toJson();
      final response = await _dio.post<Map<String, dynamic>>('/api/items/confirm', data: body);
      final data = Map<String, dynamic>.from((response.data ?? const {})['data'] as Map? ?? {});
      final dto = PublishedItemDto.fromJson(data);
      return mapPublishedItemToDomain(dto);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<PublishedItem> createItem(PublishPayload payload) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>('/api/items', data: payload.item.toJson());
      final data = Map<String, dynamic>.from((response.data ?? const {})['data'] as Map? ?? {});
      final dto = PublishedItemDto.fromJson(data);
      return mapPublishedItemToDomain(dto);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<String>> uploadItemImages({required String itemId, required List<String> imagePaths}) async {
    try {
      final formData = FormData();
      for (final path in imagePaths) {
        formData.files.add(MapEntry('image', await MultipartFile.fromFile(path)));
      }
      final response = await _dio.post<Map<String, dynamic>>('/api/items/$itemId/images', data: formData);
      final images = (response.data?['data'] as List<dynamic>? ?? <dynamic>[])
          .map((e) => Map<String, dynamic>.from(e as Map)['image_url'] as String? ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
      return images;
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
