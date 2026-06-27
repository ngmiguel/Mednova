import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/animations/mednova_3d_scene.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../shared/mednova_page_scaffold.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(appointmentsProvider);

    return MedNovaPageScaffold(
      title: 'Rendez-vous',
      subtitle: 'Planning médical en temps réel',
      icon: Icons.event_rounded,
      body: async.when(
        loading: () => const MedNovaLoader(message: 'Chargement du planning...'),
        error: (e, _) => MedNovaErrorBanner(
          message: e.toString(),
          onRetry: () => ref.invalidate(appointmentsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const MedNovaEmptyState(
              icon: Icons.event_busy,
              message: 'Aucun rendez-vous planifié',
            );
          }
          return Column(
            children: items.asMap().entries.map((entry) {
              final appt = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Staggered3DEntrance(
                  index: entry.key,
                  child: Floating3DCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _statusColor(appt.status).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.schedule, color: _statusColor(appt.status)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appt.scheduledAt,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              if (appt.reason != null)
                                Text(appt.reason!, style: const TextStyle(color: AppColors.textMuted)),
                              Text(
                                '${appt.durationMinutes} min · ${appt.status}',
                                style: TextStyle(
                                  color: _statusColor(appt.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Color _statusColor(String status) => switch (status.toUpperCase()) {
        'CONFIRMED' => AppColors.success,
        'CANCELLED' => AppColors.danger,
        'COMPLETED' => AppColors.auroraViolet,
        _ => AppColors.auroraGold,
      };
}
