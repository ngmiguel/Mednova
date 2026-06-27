import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../providers/auth_notifier.dart';

class MedNovaShell extends ConsumerWidget {
  const MedNovaShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider).valueOrNull;
    final roles = auth?.roles ?? [];

    final destinations = _destinations.where((d) {
      return ModuleRoles.canAccess(d.module, roles);
    }).toList();

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: _AuroraNavBar(
        activeBranchIndex: navigationShell.currentIndex,
        destinations: destinations,
        onTap: (branchIndex) {
          navigationShell.goBranch(
            branchIndex,
            initialLocation: branchIndex == navigationShell.currentIndex,
          );
        },
      ),
    );
  }

  static const _destinations = [
    _NavDestination(AppModule.dashboard, Icons.dashboard_rounded, 'Accueil', 0),
    _NavDestination(AppModule.patients, Icons.people_alt_rounded, 'Patients', 1),
    _NavDestination(AppModule.doctors, Icons.medical_services_rounded, 'Médecins', 2),
    _NavDestination(AppModule.appointments, Icons.event_rounded, 'RDV', 3),
    _NavDestination(AppModule.ai, Icons.psychology_rounded, 'IA', 4),
    _NavDestination(AppModule.messaging, Icons.chat_bubble_rounded, 'Messages', 5),
    _NavDestination(AppModule.notifications, Icons.notifications_rounded, 'Alertes', 6),
    _NavDestination(AppModule.audit, Icons.fact_check_rounded, 'Audit', 7),
    _NavDestination(AppModule.settings, Icons.settings_rounded, 'Réglages', 8),
  ];
}

class _NavDestination {
  const _NavDestination(this.module, this.icon, this.label, this.branchIndex);
  final AppModule module;
  final IconData icon;
  final String label;
  final int branchIndex;
}

class _AuroraNavBar extends StatelessWidget {
  const _AuroraNavBar({
    required this.activeBranchIndex,
    required this.destinations,
    required this.onTap,
  });

  final int activeBranchIndex;
  final List<_NavDestination> destinations;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.auroraViolet.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(destinations.length, (i) {
            final d = destinations[i];
            final selected = d.branchIndex == activeBranchIndex;
            return GestureDetector(
              onTap: () => onTap(d.branchIndex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: EdgeInsets.symmetric(
                  horizontal: selected ? 16 : 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.auroraGradient : null,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.auroraTeal.withValues(alpha: 0.4),
                            blurRadius: 16,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      d.icon,
                      size: 22,
                      color: selected ? Colors.white : AppColors.textMuted,
                    ),
                    if (selected) ...[
                      const SizedBox(width: 8),
                      Text(
                        d.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
