import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/animations/mednova_3d_scene.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/patient_model.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/app_providers.dart';
import '../../shared/mednova_page_scaffold.dart';
import '../../shell/mednova_shell.dart';
import 'dashboard_charts.dart';
import 'dashboard_metrics.dart';

final dashboardMetricsProvider = FutureProvider.autoDispose<DashboardMetrics>((ref) async {
  final patients = await ref.watch(patientsProvider.future);
  final doctors = await ref.watch(doctorsProvider.future);
  final appointments = await ref.watch(appointmentsProvider.future);
  final notifications = await ref.watch(notificationsProvider.future);

  final riskCounts = <String, int>{'LOW': 0, 'MODERATE': 0, 'HIGH': 0, 'CRITICAL': 0};
  for (final p in patients) {
    try {
      final risks = await ref.read(riskAssessmentsProvider(p.id).future);
      if (risks.isEmpty) continue;
      final level = risks.first.riskLevel.toUpperCase();
      riskCounts[level] = (riskCounts[level] ?? 0) + 1;
    } catch (_) {}
  }

  return buildDashboardMetrics(
    patients: patients,
    doctors: doctors,
    appointments: appointments,
    notifications: notifications,
    riskLevelCounts: riskCounts,
  );
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider).valueOrNull;
    final user = auth?.user;
    final roles = auth?.roles ?? [];
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final notificationsAsync = ref.watch(notificationsProvider);
    final now = DateTime.now();
    final today = '${_weekdayFull(now.weekday)} ${now.day} ${_monthShort(now.month)} ${now.year}';

    final modules = [
      _ModuleTile(AppModule.patients, 'Patients', Icons.people_alt_rounded, 1, AppColors.auroraTeal),
      _ModuleTile(AppModule.doctors, 'Médecins', Icons.medical_services_rounded, 2, AppColors.auroraCyan),
      _ModuleTile(AppModule.appointments, 'RDV', Icons.event_rounded, 3, AppColors.auroraViolet),
      _ModuleTile(AppModule.ai, 'IA', Icons.psychology_rounded, 4, AppColors.auroraPink),
      _ModuleTile(AppModule.messaging, 'Messages', Icons.chat_rounded, 5, AppColors.auroraGold),
      _ModuleTile(AppModule.notifications, 'Alertes', Icons.notifications_rounded, 6, AppColors.danger),
      _ModuleTile(AppModule.audit, 'Audit', Icons.fact_check_rounded, 7, AppColors.auroraViolet),
    ].where((m) => ModuleRoles.canAccess(m.module, roles)).toList();

    return MedNovaPageScaffold(
      title: 'Bonjour, ${user?.firstName ?? 'Utilisateur'}',
      subtitle: 'Tableau de bord · ${roles.map((r) => r.name).join(', ')}',
      icon: Icons.insights_rounded,
      showOrb: false,
      body: metricsAsync.when(
        loading: () => const MedNovaLoader(message: 'Chargement des indicateurs…'),
        error: (e, _) => MedNovaErrorBanner(
          message: e.toString(),
          onRetry: () => ref.invalidate(dashboardMetricsProvider),
        ),
        data: (metrics) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Floating3DCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          today[0].toUpperCase() + today.substring(1),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        const AuroraText('Vue opérationnelle'),
                        const SizedBox(height: 6),
                        Text(
                          'Synthèse temps réel — ${AppConfig.appName}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  _LiveIndicator(unread: metrics.unreadNotifications),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),
            const SizedBox(height: 16),
            _KpiGrid(metrics: metrics),
            const SizedBox(height: 20),
            _ChartSection(
              title: 'Rendez-vous cette semaine',
              subtitle: 'Volume journalier des consultations',
              icon: Icons.show_chart_rounded,
              child: DashboardWeeklyChart(data: metrics.weeklyAppointments),
            ),
            const SizedBox(height: 16),
            _ChartSection(
              title: 'Statuts des rendez-vous',
              subtitle: 'Répartition par état',
              icon: Icons.pie_chart_outline_rounded,
              child: DashboardStatusPieChart(counts: metrics.appointmentStatusCounts),
            ),
            const SizedBox(height: 16),
            _ChartSection(
              title: 'Risques IA par patient',
              subtitle: 'Dernière évaluation par niveau',
              icon: Icons.bar_chart_rounded,
              child: DashboardRiskBarChart(counts: metrics.riskLevelCounts),
            ),
            const SizedBox(height: 20),
            Text(
              'Activité récente',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            notificationsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (items) => _ActivityFeed(
                items: items.take(3).toList(),
                onSeeAll: ModuleRoles.canAccess(AppModule.notifications, roles)
                    ? () => goToShellBranch(context, 6)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Accès rapide',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: modules.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final m = modules[i];
                  return ActionChip(
                    avatar: Icon(m.icon, size: 18, color: m.color),
                    label: Text(m.label),
                    onPressed: () => goToShellBranch(context, m.branchIndex),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveIndicator extends StatelessWidget {
  const _LiveIndicator({required this.unread});

  final int unread;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              const Text('Live', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
        ),
        if (unread > 0) ...[
          const SizedBox(height: 8),
          Text('$unread alerte${unread > 1 ? 's' : ''}', style: const TextStyle(color: AppColors.auroraPink, fontSize: 11)),
        ],
      ],
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.metrics});
  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.85,
      children: [
        _KpiTile(label: 'Patients', value: '${metrics.patientCount}', icon: Icons.people, color: AppColors.auroraTeal),
        _KpiTile(label: 'Médecins', value: '${metrics.doctorCount}', icon: Icons.medical_services, color: AppColors.auroraCyan),
        _KpiTile(label: 'RDV', value: '${metrics.appointmentCount}', icon: Icons.event, color: AppColors.auroraViolet),
        _KpiTile(
          label: 'Alertes',
          value: '${metrics.unreadNotifications}',
          icon: Icons.notifications_active,
          color: AppColors.auroraPink,
        ),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Floating3DCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color, height: 1.1),
                ),
                Text(
                  label,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartSection extends StatelessWidget {
  const _ChartSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Floating3DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.auroraTeal, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ActivityFeed extends StatelessWidget {
  const _ActivityFeed({required this.items, this.onSeeAll});

  final List<NotificationModel> items;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Floating3DCard(
        child: Text('Aucune activité récente', style: TextStyle(color: AppColors.textMuted)),
      );
    }

    return Floating3DCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          for (final n in items)
            ListTile(
              dense: true,
              leading: Icon(
                n.type.toUpperCase() == 'HEALTH' ? Icons.warning_amber : Icons.info_outline,
                color: n.status.toUpperCase() == 'UNREAD' ? AppColors.auroraPink : AppColors.textMuted,
              ),
              title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: Text(n.message, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          if (onSeeAll != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: onSeeAll, child: const Text('Voir toutes les alertes')),
            ),
        ],
      ),
    );
  }
}

class _ModuleTile {
  const _ModuleTile(this.module, this.label, this.icon, this.branchIndex, this.color);
  final AppModule module;
  final String label;
  final IconData icon;
  final int branchIndex;
  final Color color;
}

String _weekdayFull(int weekday) => switch (weekday) {
      1 => 'Lundi',
      2 => 'Mardi',
      3 => 'Mercredi',
      4 => 'Jeudi',
      5 => 'Vendredi',
      6 => 'Samedi',
      7 => 'Dimanche',
      _ => '',
    };

String _monthShort(int month) => switch (month) {
      1 => 'janv.',
      2 => 'févr.',
      3 => 'mars',
      4 => 'avr.',
      5 => 'mai',
      6 => 'juin',
      7 => 'juil.',
      8 => 'août',
      9 => 'sept.',
      10 => 'oct.',
      11 => 'nov.',
      12 => 'déc.',
      _ => '',
    };
