import '../../domain/models/analyze_draft_result.dart';
import '../../domain/models/confirm_draft_payload.dart';
import '../../domain/models/publish_payload.dart';
import '../../domain/models/published_item.dart';
import '../../domain/services/item_processing_service.dart';
import '../datasources/item_remote_data_source.dart';

class ItemProcessingRepository implements ItemProcessingService {
  ItemProcessingRepository(this.remote);

  final ItemRemoteDataSource remote;

  @override
  Future<AnalyzeDraftResult> analyzeItem(String imagePath) => remote.analyzeItem(imagePath);

  @override
  Future<PublishedItem> confirmDraft(ConfirmDraftPayload payload) => remote.confirmDraft(payload);

  @override
  Future<PublishedItem> createItem(PublishPayload payload) => remote.createItem(payload);

  @override
  Future<List<String>> uploadItemImages({required String itemId, required List<String> imagePaths}) {
    return remote.uploadItemImages(itemId: itemId, imagePaths: imagePaths);
  }
}
