import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_settings.dart';

class AppSettingsStorage {
  AppSettingsStorage(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'mednova_app_settings';

  AppSettings load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return AppSettings.defaults;
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return AppSettings.defaults;
    }
  }

  Future<void> save(AppSettings settings) async {
    await _prefs.setString(_key, jsonEncode(settings.toJson()));
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main()');
});

final appSettingsStorageProvider = Provider<AppSettingsStorage>((ref) {
  return AppSettingsStorage(ref.watch(sharedPreferencesProvider));
});
