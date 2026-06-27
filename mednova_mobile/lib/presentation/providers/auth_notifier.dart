import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/storage/token_storage.dart';
import '../../data/models/auth_models.dart';
import 'app_providers.dart';

class AuthState {
  const AuthState({
    this.user,
    this.roles = const [],
    this.loading = true,
    this.error,
  });

  final UserProfile? user;
  final List<UserRole> roles;
  final bool loading;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserProfile? user,
    List<UserRole>? roles,
    bool? loading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      roles: roles ?? this.roles,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool canAccess(AppModule module) => ModuleRoles.canAccess(module, roles);
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(tokenStorageProvider);
    if (!await repo.hasSession()) {
      return const AuthState(loading: false);
    }
    try {
      final user = await repo.loadProfile();
      final storedRoles = await storage.getRoles();
      final roles = _parseRoles(storedRoles.isNotEmpty ? storedRoles : user.roles);
      return AuthState(user: user, roles: roles, loading: false);
    } catch (_) {
      await storage.clear();
      return const AuthState(loading: false);
    }
  }

  List<UserRole> _parseRoles(List<String> raw) =>
      raw.map(UserRole.fromString).whereType<UserRole>().toList();

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final tokens = await repo.login(LoginRequest(email: email, password: password));
      if (tokens.requiresTwoFactor) {
        throw Exception('Authentification 2FA requise — utilisez le portail web.');
      }
      final user = await repo.loadProfile();
      final roles = _parseRoles(
        tokens.roles.isNotEmpty ? tokens.roles : user.roles,
      );
      return AuthState(user: user, roles: roles, loading: false);
    });
  }

  Future<void> loginDemo(DemoAccount account) => login(account.email, account.password);

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(AuthState(loading: false));
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
