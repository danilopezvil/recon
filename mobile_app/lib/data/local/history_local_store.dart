import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/logging/app_logger.dart';
import '../../domain/models/process_result.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryLocalStore implements HistoryRepository {
  static const _key = 'processed_history_v3';
  static const _legacyKeyV2 = 'processed_history_v2';
  static const _limit = 50;

  @override
  Future<List<ProcessResult>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateIfNeeded(prefs);

    final raw = prefs.getStringList(_key) ?? <String>[];
    final validItems = <ProcessResult>[];

    for (final entry in raw) {
      try {
        final item = ProcessResult.fromJson(jsonDecode(entry) as Map<String, dynamic>);
        validItems.add(item);
      } catch (e, st) {
        AppLogger.warn('Skipping corrupted history entry', tag: 'HISTORY');
        AppLogger.error('History parse error', error: e, stackTrace: st, tag: 'HISTORY');
      }
    }

    validItems.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    final trimmed = validItems.take(_limit).toList();

    if (trimmed.length != raw.length) {
      await prefs.setStringList(_key, trimmed.map((e) => jsonEncode(e.toJson())).toList());
    }

    return trimmed;
  }

  @override
  Future<void> save(ProcessResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getAll();
    final next = <ProcessResult>[result, ...current]..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    final encoded = next.take(_limit).map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, encoded);
  }

  Future<void> _migrateIfNeeded(SharedPreferences prefs) async {
    if (prefs.containsKey(_key)) return;
    final legacy = prefs.getStringList(_legacyKeyV2);
    if (legacy == null) return;

    final parsed = <ProcessResult>[];
    for (final row in legacy) {
      try {
        parsed.add(ProcessResult.fromJson(jsonDecode(row) as Map<String, dynamic>));
      } catch (_) {
        // Ignora filas corruptas durante migración.
      }
    }

    parsed.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    await prefs.setStringList(_key, parsed.take(_limit).map((e) => jsonEncode(e.toJson())).toList());
  }
}
