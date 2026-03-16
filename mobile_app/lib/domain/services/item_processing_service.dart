import '../models/analyze_draft_result.dart';
import '../models/confirm_draft_payload.dart';
import '../models/publish_payload.dart';
import '../models/published_item.dart';

abstract class ItemProcessingService {
  Future<AnalyzeDraftResult> analyzeItem(String imagePath);
  Future<PublishedItem> confirmDraft(ConfirmDraftPayload payload);
  Future<PublishedItem> createItem(PublishPayload payload);
  Future<List<String>> uploadItemImages({required String itemId, required List<String> imagePaths});
}
