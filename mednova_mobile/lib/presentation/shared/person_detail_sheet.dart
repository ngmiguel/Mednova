import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/animations/mednova_3d_scene.dart';
import '../../core/theme/app_theme.dart';
import '../providers/person_detail_provider.dart';
import 'mednova_page_scaffold.dart';

Future<void> showPersonDetailSheet(
  BuildContext context,
  WidgetRef ref, {
  required PersonDetailKind kind,
  String? id,
  String? userId,
}) async {
  final notifier = ref.read(personDetailProvider.notifier);
  switch (kind) {
    case PersonDetailKind.patient:
      await notifier.openPatient(id!);
    case PersonDetailKind.doctor:
      await notifier.openDoctor(id!);
    case PersonDetailKind.staff:
      await notifier.openStaff(userId!);
  }

  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const PersonDetailSheet(),
  );

  ref.read(personDetailProvider.notifier).clear();
}

class PersonDetailSheet extends ConsumerWidget {
  const PersonDetailSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(personDetailProvider);
    final notifier = ref.read(personDetailProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: AppColors.glassBorder)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: state.loading
                    ? const Center(child: MedNovaLoader(message: 'Chargement...'))
                    : state.error != null
                        ? Center(child: Text(state.error!, style: const TextStyle(color: AppColors.danger)))
                        : state.view == null
                            ? const SizedBox.shrink()
                            : _DetailContent(
                                scrollController: scrollController,
                                view: state.view!,
                                saving: state.saving,
                                canBlock: notifier.canBlockAccess,
                                isSelf: notifier.isSelfAccount(),
                                onToggleAccess: notifier.toggleAccess,
                              ),
              ),
            ],
          ),
        ).animate().slideY(begin: 0.15, curve: Curves.easeOutCubic).fadeIn();
      },
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.scrollController,
    required this.view,
    required this.saving,
    required this.canBlock,
    required this.isSelf,
    required this.onToggleAccess,
  });

  final ScrollController scrollController;
  final PersonDetailViewModel view;
  final bool saving;
  final bool canBlock;
  final bool isSelf;
  final VoidCallback onToggleAccess;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: view.avatarColor.withValues(alpha: 0.25),
              child: Text(
                view.initials,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: view.avatarColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(view.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  if (view.subtitle != null)
                    Text(view.subtitle!, style: const TextStyle(color: AppColors.textMuted)),
                ],
              ),
            ),
            const MedNova3DOrb(size: 64, glowIntensity: 0.5),
          ],
        ),
        if (view.account != null) ...[
          const SizedBox(height: 20),
          Floating3DCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  view.account!.enabled ? Icons.verified_user : Icons.block,
                  color: view.account!.enabled ? AppColors.success : AppColors.danger,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    view.account!.enabled ? 'Compte actif' : 'Accès bloqué',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        ...view.fields.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Staggered3DEntrance(
              index: entry.key,
              child: Floating3DCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(entry.value.label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    ),
                    Expanded(
                      child: Text(entry.value.value, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        if (canBlock && view.account != null && !isSelf) ...[
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: saving ? null : onToggleAccess,
            style: ElevatedButton.styleFrom(
              backgroundColor: view.account!.enabled ? AppColors.danger : AppColors.success,
            ),
            icon: saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(view.account!.enabled ? Icons.block : Icons.check_circle),
            label: Text(view.account!.enabled ? 'Bloquer l\'accès' : 'Réactiver l\'accès'),
          ),
        ],
      ],
    );
  }
}
