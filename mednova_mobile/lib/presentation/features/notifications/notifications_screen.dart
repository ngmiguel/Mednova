import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/animations/mednova_3d_scene.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../providers/settings_provider.dart';
import '../../shared/mednova_page_scaffold.dart';
import '../../shell/mednova_shell.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inAppEnabled = ref.watch(inAppNotificationsEnabledProvider);
    final async = ref.watch(notificationsProvider);

    return MedNovaPageScaffold(
      title: 'Notifications',
      subtitle: 'Alertes cliniques & événements',
      icon: Icons.notifications_rounded,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!inAppEnabled)
            Floating3DCard(
              child: Row(
                children: [
                  const Icon(Icons.notifications_off, color: AppColors.auroraGold),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Notifications in-app désactivées', style: TextStyle(fontWeight: FontWeight.w700)),
                        const Text(
                          'Activez-les dans Réglages pour recevoir les alertes ici.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                        TextButton(
                          onPressed: () => goToShellBranch(context, 8),
                          child: const Text('Ouvrir les réglages'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (!inAppEnabled) const SizedBox(height: 12),
          async.when(
            loading: () => const MedNovaLoader(message: 'Chargement des alertes...'),
            error: (e, _) => MedNovaErrorBanner(
              message: e.toString(),
              onRetry: () => ref.invalidate(notificationsProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return const MedNovaEmptyState(
                  icon: Icons.notifications_off,
                  message: 'Aucune notification',
                );
              }
              return Column(
                children: items.asMap().entries.map((entry) {
                  final n = entry.value;
                  final unread = inAppEnabled && n.status.toUpperCase() == 'UNREAD';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Staggered3DEntrance(
                      index: entry.key,
                      child: Floating3DCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _iconForType(n.type),
                              color: unread ? AppColors.auroraPink : AppColors.textMuted,
                            )
                                .animate(onPlay: unread ? (c) => c.repeat(reverse: true) : null)
                                .scale(
                                  begin: const Offset(1, 1),
                                  end: const Offset(1.15, 1.15),
                                  duration: 1.seconds,
                                ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(n.message, style: const TextStyle(color: AppColors.textMuted)),
                                  Text(n.createdAt, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            if (unread)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.auroraPink,
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
        ],
      ),
    );
  }

  IconData _iconForType(String type) => switch (type.toUpperCase()) {
        'ALERT' || 'HEALTH' => Icons.warning_amber_rounded,
        'APPOINTMENT' => Icons.event,
        _ => Icons.info_outline,
      };
}
