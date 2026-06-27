import 'package:dio/dio.dart';

import '../../core/network/api_response.dart';
import '../../core/storage/token_storage.dart';
import '../../domain/repositories/mednova_repositories.dart';
import '../models/auth_models.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dio, this._storage);

  final Dio _dio;
  final TokenStorage _storage;

  @override
  Future<AuthTokens> login(LoginRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: request.toJson(),
    );
    final api = ApiResponse.fromJson(
      response.data!,
      (d) => AuthTokens.fromJson(d! as Map<String, dynamic>),
    );
    final tokens = api.data!;
    if (!tokens.requiresTwoFactor) {
      final roles = tokens.roles.isNotEmpty
          ? tokens.roles
          : extractRolesFromJwt(tokens.accessToken);
      await _storage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        roles: roles,
      );
    }
    return tokens;
  }

  @override
  Future<UserProfile> loadProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    final api = ApiResponse.fromJson(
      response.data!,
      (d) => UserProfile.fromJson(d! as Map<String, dynamic>),
    );
    return api.data!;
  }

  @override
  Future<void> logout() async {
    try {
      final refresh = await _storage.getRefreshToken();
      if (refresh != null) {
        await _dio.post('/auth/logout', data: {'refreshToken': refresh});
      }
    } catch (_) {}
    await _storage.clear();
  }

  @override
  Future<bool> hasSession() => _storage.hasSession();
}
