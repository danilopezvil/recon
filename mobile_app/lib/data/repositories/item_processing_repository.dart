import '../../domain/models/analyzed_item.dart';
import '../../domain/models/publish_payload.dart';
import '../../domain/services/item_processing_service.dart';
import '../datasources/item_remote_data_source.dart';

class ItemProcessingRepository implements ItemProcessingService {
  ItemProcessingRepository(this.remote);

  final ItemRemoteDataSource remote;

  @override
  Future<AnalyzedItem> analyzeItem(String imagePath) => remote.analyzeItem(imagePath);

  @override
  Future<bool> publishItem(PublishPayload payload) => remote.publishItem(payload);
}
