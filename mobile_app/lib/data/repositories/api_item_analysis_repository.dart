import '../../domain/models/analyze_draft_result.dart';
import '../datasources/item_remote_data_source.dart';

class ApiItemAnalysisRepository {
  ApiItemAnalysisRepository(this._remote);

  final ItemRemoteDataSource _remote;

  Future<AnalyzeDraftResult> analyze(String imagePath) => _remote.analyzeItem(imagePath);
}
