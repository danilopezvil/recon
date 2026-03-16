import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recon_mobile_app/core/network/api_error.dart';
import 'package:recon_mobile_app/data/datasources/http_item_remote_data_source.dart';
import 'package:recon_mobile_app/domain/models/analyzed_item.dart';
import 'package:recon_mobile_app/domain/models/confirm_draft_payload.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({this.failAnalyzeOnce = false});

  final bool failAnalyzeOnce;
  int analyzeCalls = 0;
  RequestOptions? lastAnalyzeRequest;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions requestOptions, Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    if (requestOptions.path == '/api/items/analyze') {
      lastAnalyzeRequest = requestOptions;
      analyzeCalls += 1;
      if (failAnalyzeOnce && analyzeCalls == 1) {
        throw DioException(type: DioExceptionType.connectionError, requestOptions: requestOptions);
      }
      return ResponseBody.fromString(
        '{"draft_id":"d1","image_url":"https://img","suggestion":{"title":"Mesa","description":"desc","price":20,"category":"kitchen","condition":"good","pickup_area":"Downtown"}}',
        200,
        headers: {Headers.contentTypeHeader: ['application/json']},
      );
    }

    if (requestOptions.path == '/api/items/confirm') {
      return ResponseBody.fromString(
        '{"data":{"id":"p1","title":"Mesa","description":"desc","price":20,"category":"kitchen","condition":"good","pickup_area":"Downtown","status":"available","created_at":"2024-01-01T00:00:00.000Z","images":[]}}',
        200,
        headers: {Headers.contentTypeHeader: ['application/json']},
      );
    }

    return ResponseBody.fromString('{}', 404);
  }
}

void main() {
  test('analyze sends multipart image field with filename and parses response', () async {
    final adapter = _FakeAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    dio.httpClientAdapter = adapter;
    final ds = HttpItemRemoteDataSource(dio);

    final tmp = await Directory.systemTemp.createTemp('recon_test_');
    final file = File('${tmp.path}/a.jpg');
    await file.writeAsBytes(List<int>.filled(20, 1));

    final analyzed = await ds.analyzeItem(file.path);
    expect(analyzed.draftId, 'd1');

    final formData = adapter.lastAnalyzeRequest?.data as FormData;
    expect(formData.files.single.key, 'image');
    expect(formData.files.single.value.filename, 'a.jpg');
    expect(formData.files.single.value.contentType?.mimeType, 'image/jpeg');

    final published = await ds.confirmDraft(
      ConfirmDraftPayload(
        draftId: 'd1',
        imageUrl: 'https://img',
        item: const AnalyzedItem(
          title: 'Mesa',
          description: 'desc',
          price: 20,
          category: 'kitchen',
          condition: 'good',
          pickupArea: 'Downtown',
        ),
      ),
    );
    expect(published.id, 'p1');
  });

  test('analyze retries once on transient network error', () async {
    final adapter = _FakeAdapter(failAnalyzeOnce: true);
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    dio.httpClientAdapter = adapter;
    final ds = HttpItemRemoteDataSource(dio);

    final tmp = await Directory.systemTemp.createTemp('recon_test_');
    final file = File('${tmp.path}/b.jpg');
    await file.writeAsBytes(List<int>.filled(20, 1));

    final analyzed = await ds.analyzeItem(file.path);
    expect(analyzed.draftId, 'd1');
    expect(adapter.analyzeCalls, 2);
  });

  test('confirm does not retry blindly on network error', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    dio.httpClientAdapter = _ConfirmFailAdapter();
    final ds = HttpItemRemoteDataSource(dio);

    expect(
      () => ds.confirmDraft(
        const ConfirmDraftPayload(
          draftId: 'd1',
          imageUrl: 'https://img',
          item: AnalyzedItem(
            title: 'Mesa',
            description: 'desc',
            price: 20,
            category: 'kitchen',
            condition: 'good',
            pickupArea: 'Downtown',
          ),
        ),
      ),
      throwsA(isA<ApiException>()),
    );
  });
}

class _ConfirmFailAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions requestOptions, Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    throw DioException(type: DioExceptionType.connectionError, requestOptions: requestOptions);
  }
}
