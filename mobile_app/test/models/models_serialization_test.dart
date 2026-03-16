import 'package:flutter_test/flutter_test.dart';
import 'package:recon_mobile_app/domain/models/analyzed_item.dart';
import 'package:recon_mobile_app/domain/models/process_result.dart';
import 'package:recon_mobile_app/domain/models/publish_payload.dart';

void main() {
  test('AnalyzedItem serialization roundtrip', () {
    const item = AnalyzedItem(
      title: 'Libro',
      price: 10,
      category: 'books',
      condition: 'good',
      pickupArea: 'Centro',
      description: 'Buen estado',
      author: 'Autor',
      genre: 'Ensayo',
      language: 'es',
    );

    final map = item.toJson();
    final parsed = AnalyzedItem.fromJson(map);
    expect(parsed.title, 'Libro');
    expect(parsed.author, 'Autor');
    expect(parsed.toJson()['genre'], 'Ensayo');
  });

  test('PublishPayload supports toJson/fromJson/copyWith', () {
    const item = AnalyzedItem(
      title: 'Lampara',
      price: 20,
      category: 'home',
      condition: 'like_new',
      pickupArea: 'Norte',
      description: 'Funciona bien',
    );

    final payload = PublishPayload(
      item: item,
      localImagePath: '/tmp/img.jpg',
      createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
    );

    final copy = payload.copyWith(localImagePath: '/tmp/next.jpg');
    expect(copy.localImagePath, '/tmp/next.jpg');

    final parsed = PublishPayload.fromJson(payload.toJson());
    expect(parsed.item.title, 'Lampara');
  });

  test('ProcessResult supports toJson/fromJson/copyWith', () {
    const item = AnalyzedItem(
      title: 'Silla',
      price: 15,
      category: 'home',
      condition: 'fair',
      pickupArea: 'Sur',
      description: 'Usada',
    );

    final result = ProcessResult(
      id: '1',
      item: item,
      imagePath: '/tmp/silla.jpg',
      imageBytes: 49000,
      published: true,
      createdAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
      message: 'ok',
    );

    final copy = result.copyWith(message: 'updated');
    expect(copy.message, 'updated');

    final parsed = ProcessResult.fromJson(result.toJson());
    expect(parsed.imageBytes, 49000);
    expect(parsed.published, isTrue);
  });
}
