import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/animations/mednova_3d_scene.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../shared/audit_detail_sheet.dart';
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
                    onTap: () => showAuditDetailSheet(context, e),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                              Text(
                                _eventLabel(e.eventType),
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                              if (e.summary != null) ...[
                                const SizedBox(height: 4),
                                Text(e.summary!, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                              ],
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  _MetaChip(icon: Icons.dns_outlined, label: e.source),
                                  if (e.actorLabel != null)
                                    _MetaChip(icon: Icons.person_outline, label: e.actorLabel!),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatDate(e.receivedAt),
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
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

  static String _formatDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(parsed.toLocal());
  }

  static String _eventLabel(String type) => switch (type) {
        'USER_LOGIN_SUCCESS' => 'Connexion utilisateur',
        'HEALTH_ALERT_TRIGGERED' => 'Alerte santé déclenchée',
        'PATIENT_RECORD_CREATED' => 'Dossier patient créé',
        'APPOINTMENT_SCHEDULED' => 'Rendez-vous planifié',
        _ => type.replaceAll('_', ' '),
      };

  IconData _eventIcon(String type) {
    if (type.contains('HEALTH')) return Icons.health_and_safety;
    if (type.contains('LOGIN') || type.contains('AUTH')) return Icons.lock;
    if (type.contains('APPOINTMENT')) return Icons.event;
    if (type.contains('CREATE')) return Icons.add_circle_outline;
    if (type.contains('DELETE')) return Icons.delete_outline;
    return Icons.fact_check;
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
