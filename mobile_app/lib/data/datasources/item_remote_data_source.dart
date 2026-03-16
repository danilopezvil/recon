import '../../domain/models/analyzed_item.dart';
import '../../domain/models/publish_payload.dart';

abstract class ItemRemoteDataSource {
  Future<AnalyzedItem> analyzeItem(String imagePath);
  Future<bool> publishItem(PublishPayload payload);
}
