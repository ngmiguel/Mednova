import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/storage/token_storage.dart';
import '../../data/demo/demo_catalog.dart';
import '../../data/models/auth_models.dart';
import 'app_providers.dart';
import 'settings_provider.dart';

class AuthState {
  const AuthState({
    this.user,
    this.roles = const [],
    this.loading = true,
    this.error,
    this.isDemoSession = false,
  });

  final UserProfile? user;
  final List<UserRole> roles;
  final bool loading;
  final String? error;
  final bool isDemoSession;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserProfile? user,
    List<UserRole>? roles,
    bool? loading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
    bool? isDemoSession,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      roles: roles ?? this.roles,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      isDemoSession: isDemoSession ?? this.isDemoSession,
    );
  }

  bool canAccess(AppModule module) => ModuleRoles.canAccess(module, roles);
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final storage = ref.read(tokenStorageProvider);
    if (!await storage.hasSession()) {
      return const AuthState(loading: false);
    }

    final mode = await storage.getSessionMode();
    ref.read(sessionModeProvider.notifier).state = mode;

    if (mode == SessionMode.demo) {
      final profile = await storage.getCachedProfile();
      if (profile == null) {
        await storage.clear();
        return const AuthState(loading: false);
      }
      final roles = _parseRoles(profile.roles);
      return AuthState(user: profile, roles: roles, loading: false, isDemoSession: true);
    }

    try {
      final user = await ref.read(authRepositoryProvider).loadProfile();
      final storedRoles = await storage.getRoles();
      final roles = _parseRoles(storedRoles.isNotEmpty ? storedRoles : user.roles);
      return AuthState(user: user, roles: roles, loading: false);
    } catch (_) {
      if (!ref.read(settingsProvider).settings.staySignedIn) {
        await storage.clear();
      }
      return const AuthState(loading: false);
    }
  }

  List<UserRole> _parseRoles(List<String> raw) =>
      raw.map(UserRole.fromString).whereType<UserRole>().toList();

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final demo = DemoCatalog.accountByEmail(email);
      if (demo != null && demo.password == password) {
        return _loginDemoInternal(demo);
      }

      try {
        final repo = ref.read(authRepositoryProvider);
        final storage = ref.read(tokenStorageProvider);
        final tokens = await repo.login(LoginRequest(email: email, password: password));
        if (tokens.requiresTwoFactor) {
          throw Exception('Authentification 2FA requise — utilisez le portail web.');
        }
        await storage.saveApiSession();
        ref.read(sessionModeProvider.notifier).state = SessionMode.api;
        final user = await repo.loadProfile();
        final roles = _parseRoles(tokens.roles.isNotEmpty ? tokens.roles : user.roles);
        ref.invalidate(patientsProvider);
        return AuthState(user: user, roles: roles, loading: false, isDemoSession: false);
      } on DioException {
        if (demo != null) {
          return _loginDemoInternal(demo);
        }
        rethrow;
      }
    });
  }

  Future<void> loginDemo(DemoAccount account) async {
    state = const AsyncLoading();
    state = AsyncData(await _loginDemoInternal(account));
  }

  Future<AuthState> _loginDemoInternal(DemoAccount account) async {
    final storage = ref.read(tokenStorageProvider);
    final profile = DemoCatalog.profileFor(account);
    await storage.saveDemoSession(profile);
    ref.read(sessionModeProvider.notifier).state = SessionMode.demo;
    ref.invalidate(patientsProvider);
    ref.invalidate(doctorsProvider);
    ref.invalidate(appointmentsProvider);
    ref.invalidate(notificationsProvider);
    ref.invalidate(auditEventsProvider);
    return AuthState(
      user: profile,
      roles: [account.role],
      loading: false,
      isDemoSession: true,
    );
  }

  Future<void> logout() async {
    final storage = ref.read(tokenStorageProvider);
    final mode = ref.read(sessionModeProvider);
    if (mode == SessionMode.api) {
      await ref.read(authRepositoryProvider).logout();
    } else {
      await storage.clear();
    }
    ref.read(sessionModeProvider.notifier).state = SessionMode.none;
    state = const AsyncData(AuthState(loading: false));
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final isDemoSessionProvider = Provider<bool>((ref) {
  return ref.watch(sessionModeProvider) == SessionMode.demo;
});
