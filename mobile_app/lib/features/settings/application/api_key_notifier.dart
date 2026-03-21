import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyState {
  const ApiKeyState({required this.key, required this.isCustom});

  /// The effective key (stored > env fallback).
  final String key;

  /// True when the key comes from user storage, false when from --dart-define.
  final bool isCustom;

  bool get isEmpty => key.isEmpty;
}

class ApiKeyNotifier extends Notifier<ApiKeyState> {
  static const _storageKey = 'user_api_key';
  static const _envKey =
      String.fromEnvironment('API_SECRET_KEY', defaultValue: '');

  @override
  ApiKeyState build() => ApiKeyState(key: _envKey, isCustom: false);

  /// Call this once at startup (before runApp) to load any previously saved key.
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored != null && stored.isNotEmpty) {
      state = ApiKeyState(key: stored, isCustom: true);
    }
  }

  /// Persists [key] and updates the state so all API providers rebuild.
  Future<void> save(String key) async {
    final trimmed = key.trim();
    final prefs = await SharedPreferences.getInstance();
    if (trimmed.isEmpty) {
      await prefs.remove(_storageKey);
      state = ApiKeyState(key: _envKey, isCustom: false);
    } else {
      await prefs.setString(_storageKey, trimmed);
      state = ApiKeyState(key: trimmed, isCustom: true);
    }
  }

  /// Removes the stored key and falls back to the --dart-define value.
  Future<void> resetToEnv() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    state = ApiKeyState(key: _envKey, isCustom: false);
  }
}

final apiKeyNotifierProvider =
    NotifierProvider<ApiKeyNotifier, ApiKeyState>(ApiKeyNotifier.new);
