import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../providers/auth_notifier.dart';
import '../providers/settings_provider.dart';

/// Navigation shell simplifiée : 4–5 onglets fixes + menu « Modules ».
class MedNovaShell extends ConsumerWidget {
  const MedNovaShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _homeBranch = 0;
  static const _messagesBranch = 5;
  static const _notificationsBranch = 6;
  static const _settingsBranch = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider).valueOrNull;
    final roles = auth?.roles ?? [];
    final compact = ref.watch(compactNavProvider);
    final canMessage = ModuleRoles.canAccess(AppModule.messaging, roles);
    final canNotif = ModuleRoles.canAccess(AppModule.notifications, roles);

    final tabs = <_ShellTab>[
      const _ShellTab(label: 'Accueil', icon: Icons.home_rounded, branchIndex: _homeBranch),
      _ShellTab(
        label: 'Modules',
        icon: Icons.grid_view_rounded,
        branchIndex: null,
        onTap: () => _openModulesSheet(context, roles, navigationShell),
      ),
      if (canMessage)
        const _ShellTab(label: 'Messages', icon: Icons.chat_rounded, branchIndex: _messagesBranch),
      if (canNotif)
        const _ShellTab(label: 'Alertes', icon: Icons.notifications_rounded, branchIndex: _notificationsBranch),
      const _ShellTab(label: 'Réglages', icon: Icons.settings_rounded, branchIndex: _settingsBranch),
    ];

    final activeIndex = _activeTabIndex(tabs, navigationShell.currentIndex);

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: EdgeInsets.fromLTRB(compact ? 8 : 12, 0, compact ? 8 : 12, compact ? 8 : 12),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(compact ? 20 : 24),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: NavigationBar(
            height: compact ? 58 : 64,
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: AppColors.auroraTeal.withValues(alpha: 0.25),
            selectedIndex: activeIndex,
            onDestinationSelected: (i) {
              final tab = tabs[i];
              if (tab.branchIndex != null) {
                navigationShell.goBranch(
                  tab.branchIndex!,
                  initialLocation: tab.branchIndex == navigationShell.currentIndex,
                );
              } else {
                tab.onTap?.call();
              }
            },
            destinations: tabs
                .map(
                  (t) => NavigationDestination(
                    icon: Icon(t.icon),
                    label: t.label,
                    tooltip: t.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  int _activeTabIndex(List<_ShellTab> tabs, int currentBranch) {
    for (var i = 0; i < tabs.length; i++) {
      if (tabs[i].branchIndex == currentBranch) return i;
    }
    // Branche secondaire (patients, doctors, etc.) → onglet Modules surligné
    if (currentBranch != _homeBranch &&
        currentBranch != _messagesBranch &&
        currentBranch != _notificationsBranch &&
        currentBranch != _settingsBranch) {
      return tabs.indexWhere((t) => t.branchIndex == null);
    }
    return 0;
  }

  void _openModulesSheet(BuildContext context, List<UserRole> roles, StatefulNavigationShell shell) {
    final modules = _ModuleEntry.all.where((m) => ModuleRoles.canAccess(m.module, roles)).toList();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Modules MedNova',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              const Text('Accès rapide à toutes vos sections', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.95,
                children: modules.map((m) {
                  return Material(
                    color: AppColors.glassWhite,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(ctx);
                        shell.goBranch(m.branchIndex, initialLocation: true);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(m.icon, color: m.color, size: 28),
                          const SizedBox(height: 6),
                          Text(
                            m.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShellTab {
  const _ShellTab({
    required this.label,
    required this.icon,
    required this.branchIndex,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final int? branchIndex;
  final VoidCallback? onTap;
}

class _ModuleEntry {
  const _ModuleEntry(this.module, this.label, this.icon, this.branchIndex, this.color);

  final AppModule module;
  final String label;
  final IconData icon;
  final int branchIndex;
  final Color color;

  static const all = [
    _ModuleEntry(AppModule.patients, 'Patients', Icons.people_alt_rounded, 1, AppColors.auroraTeal),
    _ModuleEntry(AppModule.doctors, 'Médecins', Icons.medical_services_rounded, 2, AppColors.auroraCyan),
    _ModuleEntry(AppModule.appointments, 'RDV', Icons.event_rounded, 3, AppColors.auroraViolet),
    _ModuleEntry(AppModule.ai, 'IA', Icons.psychology_rounded, 4, AppColors.auroraPink),
    _ModuleEntry(AppModule.messaging, 'Messages', Icons.chat_rounded, 5, AppColors.auroraGold),
    _ModuleEntry(AppModule.notifications, 'Alertes', Icons.notifications_rounded, 6, AppColors.danger),
    _ModuleEntry(AppModule.audit, 'Audit', Icons.fact_check_rounded, 7, AppColors.auroraViolet),
    _ModuleEntry(AppModule.settings, 'Réglages', Icons.settings_rounded, 8, AppColors.textMuted),
  ];
}

/// Navigue vers une branche du shell (depuis le dashboard, etc.).
void goToShellBranch(BuildContext context, int branchIndex) {
  final shell = StatefulNavigationShell.maybeOf(context);
  if (shell != null) {
    shell.goBranch(branchIndex, initialLocation: true);
    return;
  }
  final path = _ModuleEntry.all
      .where((m) => m.branchIndex == branchIndex)
      .map((m) => switch (m.module) {
            AppModule.dashboard => '/dashboard',
            AppModule.patients => '/patients',
            AppModule.doctors => '/doctors',
            AppModule.appointments => '/appointments',
            AppModule.ai => '/ai',
            AppModule.messaging => '/messaging',
            AppModule.notifications => '/notifications',
            AppModule.audit => '/audit',
            AppModule.settings => '/settings',
          })
      .firstOrNull;
  if (path != null) context.go(path);
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
