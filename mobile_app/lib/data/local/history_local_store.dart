import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/process_result.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryLocalStore implements HistoryRepository {
  static const _key = 'processed_history_v1';
  static const _maxRecords = 50;

  @override
  Future<List<ProcessResult>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    final parsed = <ProcessResult>[];

    for (final entry in raw) {
      try {
        final map = jsonDecode(entry) as Map<String, dynamic>;
        parsed.add(ProcessResult.fromJson(map));
      } catch (_) {
        // Ignora entradas corruptas para no romper todo el historial.
      }
    }

    parsed.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return parsed;
  }

  @override
  Future<void> save(ProcessResult result) async {
    final current = await getAll();
    final next = [result, ...current];
    final limited = next.take(_maxRecords).toList();

    final prefs = await SharedPreferences.getInstance();
    final raw = limited.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, raw);
  }
}
