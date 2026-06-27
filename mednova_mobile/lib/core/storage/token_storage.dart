import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/models/auth_models.dart';
import '../platform/secure_storage_factory.dart';

enum SessionMode { none, api, demo }

class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessKey = 'mednova_access_token';
  static const _refreshKey = 'mednova_refresh_token';
  static const _rolesKey = 'mednova_roles';
  static const _sessionModeKey = 'mednova_session_mode';
  static const _profileKey = 'mednova_user_profile';
  static const _rememberedEmailKey = 'mednova_remembered_email';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required List<String> roles,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
    await _storage.write(key: _rolesKey, value: jsonEncode(roles));
  }

  Future<void> saveDemoSession(UserProfile profile) async {
    await saveTokens(
      accessToken: 'demo-access-token',
      refreshToken: 'demo-refresh-token',
      roles: profile.roles,
    );
    await _storage.write(key: _sessionModeKey, value: SessionMode.demo.name);
    await _storage.write(key: _profileKey, value: jsonEncode(profile.toJson()));
  }

  Future<void> saveApiSession() async {
    await _storage.write(key: _sessionModeKey, value: SessionMode.api.name);
    await _storage.delete(key: _profileKey);
  }

  Future<SessionMode> getSessionMode() async {
    final raw = await _storage.read(key: _sessionModeKey);
    if (raw == null) return SessionMode.none;
    return SessionMode.values.byName(raw);
  }

  Future<UserProfile?> getCachedProfile() async {
    final raw = await _storage.read(key: _profileKey);
    if (raw == null) return null;
    try {
      return UserProfile.fromStorage(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessKey);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  Future<List<String>> getRoles() async {
    final raw = await _storage.read(key: _rolesKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>).cast<String>();
    } catch (_) {
      return [];
    }
  }

  Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveRememberedEmail(String email) async {
    await _storage.write(key: _rememberedEmailKey, value: email);
  }

  Future<String?> getRememberedEmail() => _storage.read(key: _rememberedEmailKey);

  Future<void> clearRememberedEmail() async {
    await _storage.delete(key: _rememberedEmailKey);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _rolesKey);
    await _storage.delete(key: _sessionModeKey);
    await _storage.delete(key: _profileKey);
  }
}

final tokenStorageProvider = Provider<TokenStorage>(
  (_) => TokenStorage(createSecureStorage()),
);

final sessionModeProvider = StateProvider<SessionMode>((ref) => SessionMode.none);

List<String> extractRolesFromJwt(String token) {
  try {
    final parts = token.split('.');
    if (parts.length < 2) return [];
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final map = jsonDecode(payload) as Map<String, dynamic>;
    final roles = map['roles'];
    if (roles is List) return roles.cast<String>();
    return [];
  } catch (_) {
    return [];
  }
}
