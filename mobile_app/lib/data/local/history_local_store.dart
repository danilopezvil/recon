import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/process_result.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryLocalStore implements HistoryRepository {
  static const _key = 'processed_history_v1';

  @override
  Future<List<ProcessResult>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    return raw
        .map((e) => ProcessResult.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<void> save(ProcessResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    raw.add(jsonEncode(result.toJson()));
    await prefs.setStringList(_key, raw);
  }
}
