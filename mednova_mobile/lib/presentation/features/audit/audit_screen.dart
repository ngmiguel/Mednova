import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/animations/mednova_3d_scene.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../shared/mednova_page_scaffold.dart';

class AuditScreen extends ConsumerWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(auditEventsProvider);

    return MedNovaPageScaffold(
      title: 'Audit',
      subtitle: 'Traçabilité & conformité',
      icon: Icons.fact_check_rounded,
      body: async.when(
        loading: () => const MedNovaLoader(message: 'Chargement des événements...'),
        error: (e, _) => MedNovaErrorBanner(
          message: e.toString(),
          onRetry: () => ref.invalidate(auditEventsProvider),
        ),
        data: (events) {
          if (events.isEmpty) {
            return const MedNovaEmptyState(
              icon: Icons.history,
              message: 'Aucun événement audit',
            );
          }
          return Column(
            children: events.asMap().entries.map((entry) {
              final e = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Staggered3DEntrance(
                  index: entry.key,
                  child: Floating3DCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.auroraViolet.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_eventIcon(e.eventType), color: AppColors.auroraViolet),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.eventType, style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text('Source: ${e.source}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                              Text(e.receivedAt, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
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

  IconData _eventIcon(String type) {
    if (type.contains('HEALTH')) return Icons.health_and_safety;
    if (type.contains('LOGIN') || type.contains('AUTH')) return Icons.lock;
    if (type.contains('CREATE')) return Icons.add_circle_outline;
    if (type.contains('DELETE')) return Icons.delete_outline;
    return Icons.fact_check;
  }
}
