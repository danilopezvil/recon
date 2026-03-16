import 'dart:math';

import '../../domain/models/analyzed_item.dart';
import '../../domain/models/publish_payload.dart';
import 'item_remote_data_source.dart';

class MockItemRemoteDataSource implements ItemRemoteDataSource {
  @override
  Future<AnalyzedItem> analyzeItem(String imagePath) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final samples = <AnalyzedItem>[
      const AnalyzedItem(
        title: 'Libro: Hábitos Atómicos',
        price: 12,
        category: 'books',
        condition: 'good',
        pickupArea: 'Centro',
        description: 'Libro en buen estado, sin páginas sueltas ni subrayados excesivos.',
        author: 'James Clear',
        genre: 'Productividad',
        language: 'es',
      ),
      const AnalyzedItem(
        title: 'Lámpara de escritorio LED',
        price: 18,
        category: 'home',
        condition: 'like_new',
        pickupArea: 'Centro',
        description: 'Lámpara compacta y funcional, luz regulable, poco uso.',
      ),
    ];
    return samples[Random().nextInt(samples.length)];
  }

  @override
  Future<bool> publishItem(PublishPayload payload) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return true;
  }
}
