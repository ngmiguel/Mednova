import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animations/mednova_3d_scene.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/app_providers.dart';
import '../../shared/mednova_page_scaffold.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider).valueOrNull;
    final user = auth?.user;
    final roles = auth?.roles ?? [];

    final modules = [
      _ModuleTile(AppModule.patients, 'Patients', Icons.people_alt_rounded, '/patients', AppColors.auroraTeal),
      _ModuleTile(AppModule.doctors, 'Médecins', Icons.medical_services_rounded, '/doctors', AppColors.auroraCyan),
      _ModuleTile(AppModule.appointments, 'RDV', Icons.event_rounded, '/appointments', AppColors.auroraViolet),
      _ModuleTile(AppModule.ai, 'IA Prédictive', Icons.psychology_rounded, '/ai', AppColors.auroraPink),
      _ModuleTile(AppModule.messaging, 'Messages', Icons.chat_bubble_rounded, '/messaging', AppColors.auroraGold),
      _ModuleTile(AppModule.notifications, 'Alertes', Icons.notifications_rounded, '/notifications', AppColors.danger),
      _ModuleTile(AppModule.audit, 'Audit', Icons.fact_check_rounded, '/audit', AppColors.auroraViolet),
      _ModuleTile(AppModule.settings, 'Réglages', Icons.settings_rounded, '/settings', AppColors.textMuted),
    ].where((m) => ModuleRoles.canAccess(m.module, roles)).toList();

    return MedNovaPageScaffold(
      title: 'Bonjour, ${user?.firstName ?? 'Utilisateur'}',
      subtitle: 'Tableau de bord MedNova · ${roles.map((r) => r.name).join(', ')}',
      icon: Icons.dashboard_rounded,
      orbSize: 90,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Floating3DCard(
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AuroraText('Intelligence clinique'),
                      SizedBox(height: 8),
                      Text(
                        'Analyse prédictive des risques en temps réel, alimentée par Kafka & microservices.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const MedNovaDNAHelix(height: 100, width: 50),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.15),
          const SizedBox(height: 20),
          const _QuickStats(),
          const SizedBox(height: 24),
          Text(
            'Modules',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemCount: modules.length,
            itemBuilder: (context, i) {
              final m = modules[i];
              return Staggered3DEntrance(
                index: i,
                child: Floating3DCard(
                  padding: const EdgeInsets.all(16),
                  onTap: () => context.go(m.route),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: m.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(m.icon, color: m.color),
                      ),
                      const Spacer(),
                      Text(m.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ModuleTile {
  const _ModuleTile(this.module, this.label, this.icon, this.route, this.color);
  final AppModule module;
  final String label;
  final IconData icon;
  final String route;
  final Color color;
}

class _QuickStats extends ConsumerWidget {
  const _QuickStats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patients = ref.watch(patientsProvider);
    final doctors = ref.watch(doctorsProvider);
    final appointments = ref.watch(appointmentsProvider);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Patients',
            value: patients.maybeWhen(data: (d) => '${d.length}', orElse: () => '—'),
            color: AppColors.auroraTeal,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Médecins',
            value: doctors.maybeWhen(data: (d) => '${d.length}', orElse: () => '—'),
            color: AppColors.auroraCyan,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'RDV',
            value: appointments.maybeWhen(data: (d) => '${d.length}', orElse: () => '—'),
            color: AppColors.auroraViolet,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Floating3DCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9));
  }
}
