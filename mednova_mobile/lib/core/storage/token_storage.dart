import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessKey = 'mednova_access_token';
  static const _refreshKey = 'mednova_refresh_token';
  static const _rolesKey = 'mednova_roles';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required List<String> roles,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
    await _storage.write(key: _rolesKey, value: jsonEncode(roles));
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

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _rolesKey);
  }
}

final tokenStorageProvider = Provider<TokenStorage>(
  (_) => TokenStorage(const FlutterSecureStorage()),
);

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
