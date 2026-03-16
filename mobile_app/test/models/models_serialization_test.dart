import 'package:flutter_test/flutter_test.dart';
import 'package:recon_mobile_app/domain/models/analyze_draft_result.dart';
import 'package:recon_mobile_app/domain/models/analyzed_item.dart';
import 'package:recon_mobile_app/domain/models/process_result.dart';

void main() {
  test('AnalyzedItem serialization roundtrip', () {
    const item = AnalyzedItem(
      title: 'Libro',
      price: 10,
      category: 'books',
      condition: 'good',
      pickupArea: 'Centro',
      description: 'Buen estado',
    );

    final map = item.toJson();
    final parsed = AnalyzedItem.fromJson(map);
    expect(parsed.title, 'Libro');
    expect(parsed.description, 'Buen estado');
  });

  test('AnalyzeDraftResult serialization roundtrip', () {
    const result = AnalyzeDraftResult(
      draftId: 'd1',
      imageUrl: 'https://img',
      suggestion: AnalyzedItem(
        title: 'Silla',
        description: 'Desc',
        price: 20,
        category: 'home',
        condition: 'good',
        pickupArea: '',
      ),
    );

    final parsed = AnalyzeDraftResult.fromJson(result.toJson());
    expect(parsed.draftId, 'd1');
  });

  test('ProcessResult supports toJson/fromJson/copyWith', () {
    final result = ProcessResult(
      id: '1',
      flowType: 'ai_assisted',
      draftId: 'd1',
      publishedItemId: 'p1',
      imageUrl: 'https://img',
      title: 'Silla',
      category: 'home',
      condition: 'good',
      price: 10,
      pickupArea: 'Centro',
      publishedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
      success: true,
      message: 'ok',
    );

    final copy = result.copyWith(message: 'updated');
    expect(copy.message, 'updated');

    final parsed = ProcessResult.fromJson(result.toJson());
    expect(parsed.success, isTrue);
  });
}
