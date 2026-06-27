import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_settings.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/storage/app_settings_storage.dart';
import '../../core/storage/token_storage.dart';
import '../../data/demo/demo_catalog.dart';
import 'app_providers.dart';

class SettingsState {
  const SettingsState({
    required this.settings,
    this.savedFlash = false,
    this.gatewayStatus,
    this.checkingGateway = false,
    this.stats,
    this.refreshingStats = false,
  });

  final AppSettings settings;
  final bool savedFlash;
  final String? gatewayStatus;
  final bool checkingGateway;
  final NavStats? stats;
  final bool refreshingStats;

  SettingsState copyWith({
    AppSettings? settings,
    bool? savedFlash,
    String? gatewayStatus,
    bool? checkingGateway,
    bool clearGateway = false,
    NavStats? stats,
    bool? refreshingStats,
    bool clearStats = false,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      savedFlash: savedFlash ?? this.savedFlash,
      gatewayStatus: clearGateway ? null : (gatewayStatus ?? this.gatewayStatus),
      checkingGateway: checkingGateway ?? this.checkingGateway,
      stats: clearStats ? null : (stats ?? this.stats),
      refreshingStats: refreshingStats ?? this.refreshingStats,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return SettingsState(settings: ref.read(appSettingsStorageProvider).load());
  }

  /// Applique immédiatement + persiste (plus besoin d'attendre « Enregistrer »).
  Future<void> update(AppSettings next, {String? userEmail}) async {
    state = state.copyWith(settings: next);
    await _persist(userEmail);
    _flashSaved();
  }

  Future<void> save({String? emailToRemember}) async {
    await _persist(emailToRemember);
    _flashSaved();
  }

  Future<void> _persist(String? userEmail) async {
    await ref.read(appSettingsStorageProvider).save(state.settings);
    final storage = ref.read(tokenStorageProvider);
    if (state.settings.rememberEmail && userEmail != null) {
      await storage.saveRememberedEmail(userEmail);
    } else if (!state.settings.rememberEmail) {
      await storage.clearRememberedEmail();
    }
  }

  void _flashSaved() {
    state = state.copyWith(savedFlash: true);
    Future.delayed(const Duration(seconds: 2), () {
      state = state.copyWith(savedFlash: false);
    });
  }

  Future<void> reset({String? userEmail}) async {
    const defaults = AppSettings.defaults;
    await ref.read(appSettingsStorageProvider).save(defaults);
    state = SettingsState(settings: defaults, savedFlash: true);
    await _persist(userEmail);
    Future.delayed(const Duration(seconds: 2), () {
      state = state.copyWith(savedFlash: false);
    });
  }

  Future<void> checkGateway({required bool isDemo}) async {
    state = state.copyWith(checkingGateway: true, clearGateway: true);
    if (isDemo) {
      await Future.delayed(const Duration(milliseconds: 400));
      state = state.copyWith(gatewayStatus: 'UP', checkingGateway: false);
      return;
    }
    try {
      await ref.read(patientRepositoryProvider).list(size: 1);
      state = state.copyWith(gatewayStatus: 'UP', checkingGateway: false);
    } catch (_) {
      state = state.copyWith(gatewayStatus: 'DOWN', checkingGateway: false);
    }
  }

  Future<void> refreshStats({required bool isDemo}) async {
    state = state.copyWith(refreshingStats: true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (isDemo) {
      state = state.copyWith(stats: DemoCatalog.stats, refreshingStats: false);
      return;
    }
    try {
      final p = await ref.read(patientRepositoryProvider).list(size: 50);
      final d = await ref.read(doctorRepositoryProvider).list(size: 50);
      final a = await ref.read(appointmentRepositoryProvider).list(size: 50);
      final e = await ref.read(auditRepositoryProvider).list(size: 50);
      state = state.copyWith(
        stats: NavStats(
          patients: p.length,
          doctors: d.length,
          appointments: a.length,
          auditEvents: e.length,
          lastUpdated: DateTime.now(),
        ),
        refreshingStats: false,
      );
    } catch (_) {
      state = state.copyWith(refreshingStats: false);
    }
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

final appStringsProvider = Provider<AppStrings>((ref) {
  return AppStrings(ref.watch(settingsProvider).settings.language);
});

final animationsEnabledProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider).settings.animationsEnabled,
);

final compactNavProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider).settings.compactNav,
);

final inAppNotificationsEnabledProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider).settings.inAppNotifications,
);

final pagePaddingProvider = Provider<double>((ref) {
  final compact = ref.watch(compactNavProvider);
  return compact ? 12.0 : 20.0;
});
