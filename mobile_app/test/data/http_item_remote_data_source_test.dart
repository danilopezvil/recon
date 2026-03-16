import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recon_mobile_app/data/datasources/http_item_remote_data_source.dart';
import 'package:recon_mobile_app/domain/models/analyzed_item.dart';
import 'package:recon_mobile_app/domain/models/confirm_draft_payload.dart';

class _FakeAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions requestOptions, Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    if (requestOptions.path == '/api/items/confirm') {
      return ResponseBody.fromString(
        '{"data":{"id":"p1","title":"Mesa","description":"desc","price":20,"category":"kitchen","condition":"good","pickup_area":"Downtown","status":"available","created_at":"2024-01-01T00:00:00.000Z","images":[]}}',
        200,
        headers: {Headers.contentTypeHeader: ['application/json']},
      );
    }

    return ResponseBody.fromString(
      '{"draft_id":"d1","image_url":"https://img","suggestion":{"title":"Mesa","description":"desc","price":20,"category":"kitchen","condition":"good","pickup_area":""}}',
      200,
      headers: {Headers.contentTypeHeader: ['application/json']},
    );
  }
}

void main() {
  test('analyze and confirm parse responses', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    dio.httpClientAdapter = _FakeAdapter();
    final ds = HttpItemRemoteDataSource(dio);

    final analyzed = await ds.analyzeItem('/tmp/a.jpg');
    expect(analyzed.draftId, 'd1');

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
}
