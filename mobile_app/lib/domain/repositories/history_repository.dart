import '../models/process_result.dart';

abstract class HistoryRepository {
  Future<List<ProcessResult>> getAll();
  Future<void> save(ProcessResult result);
}
