import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/animations/mednova_3d_scene.dart';
import '../../core/theme/app_theme.dart';

/// Standard page wrapper: parallax 3D background + animated header + content.
class MedNovaPageScaffold extends StatelessWidget {
  const MedNovaPageScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.body,
    this.actions,
    this.showOrb = true,
    this.orbSize = 100,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget body;
  final List<Widget>? actions;
  final bool showOrb;
  final double orbSize;

  @override
  Widget build(BuildContext context) {
    return Parallax3DBackground(
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _IconBadge(icon: icon),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  title,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                )
                                    .animate()
                                    .fadeIn(duration: 500.ms)
                                    .slideX(begin: -0.15, curve: Curves.easeOutCubic),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textMuted,
                                ),
                          )
                              .animate(delay: 100.ms)
                              .fadeIn()
                              .slideY(begin: 0.2),
                        ],
                      ),
                    ),
                    if (showOrb)
                      MedNova3DOrb(size: orbSize, glowIntensity: 0.7)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(0.95, 0.95),
                            end: const Offset(1.05, 1.05),
                            duration: 3.seconds,
                          ),
                    if (actions != null) ...actions!,
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              sliver: SliverToBoxAdapter(child: body),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppColors.auroraGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.auroraTeal.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    )
        .animate()
        .rotate(begin: -0.05, end: 0, duration: 600.ms, curve: Curves.easeOutBack)
        .fadeIn();
  }
}

/// Aurora gradient text for hero titles.
class AuroraText extends StatelessWidget {
  const AuroraText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => AppColors.auroraGradient.createShader(bounds),
      child: Text(
        text,
        style: (style ?? Theme.of(context).textTheme.headlineMedium)?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

/// Risk level chip with glow.
class RiskChip extends StatelessWidget {
  const RiskChip({super.key, required this.level});

  final String level;

  Color get _color => switch (level.toUpperCase()) {
        'CRITICAL' => AppColors.danger,
        'HIGH' => AppColors.auroraPink,
        'MODERATE' => AppColors.auroraGold,
        _ => AppColors.success,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(color: _color.withValues(alpha: 0.25), blurRadius: 12),
        ],
      ),
      child: Text(
        level,
        style: TextStyle(color: _color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

/// Loading state with spinning 3D orb.
class MedNovaLoader extends StatelessWidget {
  const MedNovaLoader({super.key, this.message = 'Chargement...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MedNova3DOrb(size: 120),
          const SizedBox(height: 24),
          Text(message, style: const TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

/// Error banner with retry.
class MedNovaErrorBanner extends StatelessWidget {
  const MedNovaErrorBanner({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Floating3DCard(
      child: Column(
        children: [
          const Icon(Icons.cloud_off, color: AppColors.danger, size: 40),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Animated empty state.
class MedNovaEmptyState extends StatelessWidget {
  const MedNovaEmptyState({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .rotate(begin: -0.03, end: 0.03, duration: 2.seconds),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
