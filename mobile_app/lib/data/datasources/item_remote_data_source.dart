import '../../domain/models/analyze_draft_result.dart';
import '../../domain/models/confirm_draft_payload.dart';
import '../../domain/models/publish_payload.dart';
import '../../domain/models/published_item.dart';

abstract class ItemRemoteDataSource {
  Future<AnalyzeDraftResult> analyzeItem(String imagePath);
  Future<PublishedItem> confirmDraft(ConfirmDraftPayload payload);
  Future<PublishedItem> createItem(PublishPayload payload);
  Future<List<String>> uploadItemImages({required String itemId, required List<String> imagePaths});
}
