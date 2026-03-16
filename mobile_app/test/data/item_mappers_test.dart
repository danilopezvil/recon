import 'package:flutter_test/flutter_test.dart';
import 'package:recon_mobile_app/data/dtos/item_dtos.dart';

void main() {
  test('AnalyzeResponseDto maps to domain', () {
    final dto = AnalyzeResponseDto.fromJson({
      'draft_id': 'd1',
      'image_url': 'https://img',
      'suggestion': {
        'title': 'Mesa',
        'description': 'desc',
        'price': 20,
        'category': 'kitchen',
        'condition': 'good',
        'pickup_area': '',
      }
    });

    final domain = dto.toDomain();
    expect(domain.draftId, 'd1');
    expect(domain.suggestion.title, 'Mesa');
  });
}
