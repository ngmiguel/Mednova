import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animations/mednova_3d_scene.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_notifier.dart';
import '../../shared/mednova_page_scaffold.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider).valueOrNull;
    final user = auth?.user;

    return MedNovaPageScaffold(
      title: 'Réglages',
      subtitle: 'Profil & session',
      icon: Icons.settings_rounded,
      body: Column(
        children: [
          Floating3DCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.auroraTeal.withValues(alpha: 0.2),
                  child: Text(
                    user != null ? user.firstName[0] : '?',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'Utilisateur',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                      Text(user?.email ?? '', style: const TextStyle(color: AppColors.textMuted)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: (auth?.roles ?? [])
                            .map(
                              (r) => Chip(
                                label: Text(r.name, style: const TextStyle(fontSize: 11)),
                                backgroundColor: AppColors.glassWhite,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Staggered3DEntrance(
            index: 0,
            child: _SettingsTile(
              icon: Icons.security,
              title: 'Sécurité',
              subtitle: '2FA ${user?.twoFactorEnabled == true ? 'activée' : 'désactivée'}',
            ),
          ),
          const SizedBox(height: 12),
          Staggered3DEntrance(
            index: 1,
            child: _SettingsTile(
              icon: Icons.api,
              title: 'API Gateway',
              subtitle: AppConfig.apiBaseUrl,
            ),
          ),
          const SizedBox(height: 12),
          Staggered3DEntrance(
            index: 2,
            child: Floating3DCard(
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: AppColors.danger),
                  SizedBox(width: 10),
                  Text(
                    'Déconnexion',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const MedNova3DOrb(size: 140, glowIntensity: 0.6),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Floating3DCard(
      child: Row(
        children: [
          Icon(icon, color: AppColors.auroraCyan),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
