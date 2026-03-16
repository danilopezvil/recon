import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/process_result.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryLocalStore implements HistoryRepository {
  static const _key = 'processed_history_v2';
  static const _limit = 50;

  @override
  Future<List<ProcessResult>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    final items = raw
        .map((e) => ProcessResult.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return items.take(_limit).toList();
  }

  @override
  Future<void> save(ProcessResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getAll();
    final next = <ProcessResult>[result, ...current]
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    final encoded = next.take(_limit).map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, encoded);
  }
}
