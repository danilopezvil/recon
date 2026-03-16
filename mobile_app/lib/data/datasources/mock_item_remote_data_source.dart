import '../../domain/models/analyze_draft_result.dart';
import '../../domain/models/analyzed_item.dart';
import '../../domain/models/confirm_draft_payload.dart';
import '../../domain/models/publish_payload.dart';
import '../../domain/models/published_image.dart';
import '../../domain/models/published_item.dart';
import 'item_remote_data_source.dart';

class MockItemRemoteDataSource implements ItemRemoteDataSource {
  @override
  Future<AnalyzeDraftResult> analyzeItem(String imagePath) async {
    return const AnalyzeDraftResult(
      draftId: 'draft-mock',
      imageUrl: 'https://example.com/image.jpg',
      suggestion: AnalyzedItem(
        title: 'Item mock',
        description: 'Descripción mock',
        price: 10,
        category: 'kitchen',
        condition: 'good',
        pickupArea: '',
      ),
    );
  }

  @override
  Future<PublishedItem> confirmDraft(ConfirmDraftPayload payload) async {
    return PublishedItem(
      id: 'item-mock',
      title: payload.item.title,
      description: payload.item.description,
      price: payload.item.price,
      category: payload.item.category,
      condition: payload.item.condition,
      pickupArea: payload.item.pickupArea,
      status: 'available',
      createdAt: DateTime.now(),
      images: [
        PublishedImage(id: 'img-1', imageUrl: payload.imageUrl, sortOrder: 1),
      ],
    );
  }

  @override
  Future<PublishedItem> createItem(PublishPayload payload) async {
    return PublishedItem(
      id: 'manual-mock',
      title: payload.item.title,
      description: payload.item.description,
      price: payload.item.price,
      category: payload.item.category,
      condition: payload.item.condition,
      pickupArea: payload.item.pickupArea,
      status: 'available',
      createdAt: DateTime.now(),
      images: const [],
    );
  }

  @override
  Future<List<String>> uploadItemImages({required String itemId, required List<String> imagePaths}) async {
    return imagePaths;
  }
}
