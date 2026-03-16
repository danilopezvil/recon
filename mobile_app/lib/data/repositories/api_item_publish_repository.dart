import '../../domain/models/confirm_draft_payload.dart';
import '../../domain/models/published_item.dart';
import '../datasources/item_remote_data_source.dart';

class ApiItemPublishRepository {
  ApiItemPublishRepository(this._remote);

  final ItemRemoteDataSource _remote;

  Future<PublishedItem> confirm(ConfirmDraftPayload payload) => _remote.confirmDraft(payload);
}
