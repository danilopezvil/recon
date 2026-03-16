import '../models/analyzed_item.dart';
import '../models/publish_payload.dart';

abstract class ItemProcessingService {
  Future<AnalyzedItem> analyzeItem(String imagePath);
  Future<bool> publishItem(PublishPayload payload);
}
