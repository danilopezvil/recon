import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/logging/app_logger.dart';
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
    AppLogger.info('Analyze request started imagePath=$imagePath', tag: 'WORKFLOW');
    try {
      final response = await _retryAnalyze(() async {
        final imageFile = File(imagePath);
        final filename = imageFile.uri.pathSegments.isNotEmpty ? imageFile.uri.pathSegments.last : 'image.jpg';
        final ext = filename.contains('.') ? filename.split('.').last.toLowerCase() : '';
        final contentType = switch (ext) {
          'png' => DioMediaType('image', 'png'),
          'webp' => DioMediaType('image', 'webp'),
          _ => DioMediaType('image', 'jpeg'),
        };

        final formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(
            imagePath,
            filename: filename,
            contentType: contentType,
          ),
        });
        return _dio.post<Map<String, dynamic>>('/api/items/analyze', data: formData);
      });
      final dto = AnalyzeResponseDto.fromJson(response.data ?? const {});
      final result = mapAnalyzeResponseToDomain(dto);
      AppLogger.info('Analyze request success draftId=${result.draftId}', tag: 'WORKFLOW');
      return result;
    } catch (e, st) {
      if (e is FormatException || e is TypeError) {
        AppLogger.error('Analyze serialization error', error: e, stackTrace: st, tag: 'WORKFLOW');
      }
      final mapped = mapDioError(e);
      AppLogger.warn('Analyze request failed: ${mapped.message}', tag: 'WORKFLOW');
      throw mapped;
    }
  }

  @override
  Future<PublishedItem> confirmDraft(ConfirmDraftPayload payload) async {
    AppLogger.info('Confirm request started draftId=${payload.draftId}', tag: 'WORKFLOW');
    try {
      final body = mapConfirmPayloadToDto(payload).toJson();
      final response = await _dio.post<Map<String, dynamic>>('/api/items/confirm', data: body);
      final data = Map<String, dynamic>.from((response.data ?? const {})['data'] as Map? ?? {});
      final dto = PublishedItemDto.fromJson(data);
      final result = mapPublishedItemToDomain(dto);
      AppLogger.info('Confirm request success itemId=${result.id}', tag: 'WORKFLOW');
      return result;
    } catch (e, st) {
      if (e is FormatException || e is TypeError) {
        AppLogger.error('Confirm serialization error', error: e, stackTrace: st, tag: 'WORKFLOW');
      }
      final mapped = mapDioError(e);
      AppLogger.warn('Confirm request failed: ${mapped.message}', tag: 'WORKFLOW');
      throw mapped;
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

  Future<Response<Map<String, dynamic>>> _retryAnalyze(
    Future<Response<Map<String, dynamic>>> Function() action,
  ) async {
    const maxAttempts = 2;
    var attempt = 0;

    while (true) {
      attempt += 1;
      try {
        return await action();
      } catch (e) {
        final shouldRetry = attempt < maxAttempts && _isRetryableAnalyzeError(e);
        if (!shouldRetry) rethrow;
        AppLogger.warn('Analyze retry attempt=$attempt', tag: 'WORKFLOW');
        await Future<void>.delayed(Duration(milliseconds: 250 * attempt));
      }
    }
  }

  bool _isRetryableAnalyzeError(Object error) {
    if (error is! DioException) return false;
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return true;
    }
    final code = error.response?.statusCode;
    return code != null && code >= 500;
  }
}
