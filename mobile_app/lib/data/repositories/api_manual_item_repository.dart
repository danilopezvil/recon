import '../../domain/models/publish_payload.dart';
import '../../domain/models/published_item.dart';
import '../datasources/item_remote_data_source.dart';

class ApiManualItemRepository {
  ApiManualItemRepository(this._remote);

  final ItemRemoteDataSource _remote;

  Future<PublishedItem> create(PublishPayload payload) => _remote.createItem(payload);
  Future<List<String>> uploadImages({required String itemId, required List<String> imagePaths}) {
    return _remote.uploadItemImages(itemId: itemId, imagePaths: imagePaths);
  }
}
