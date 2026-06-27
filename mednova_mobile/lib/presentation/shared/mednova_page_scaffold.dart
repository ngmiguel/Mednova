import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/animations/mednova_3d_scene.dart';
import '../../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';

/// Standard page wrapper: parallax 3D background + animated header + content.
class MedNovaPageScaffold extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final animations = ref.watch(animationsEnabledProvider);
    final padding = ref.watch(pagePaddingProvider);

    return Parallax3DBackground(
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(padding, 12, padding, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _IconBadge(icon: icon, animate: animations),
                              SizedBox(width: padding * 0.6),
                              Expanded(
                                child: _maybeAnimate(
                                  animations,
                                  Text(
                                    title,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                        ),
                                  ),
                                  fadeSlideX: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _maybeAnimate(
                            animations,
                            Text(
                              subtitle,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                            ),
                            fadeSlideY: true,
                            delayMs: 100,
                          ),
                        ],
                      ),
                    ),
                    if (showOrb && animations)
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
              padding: EdgeInsets.fromLTRB(padding, 20, padding, 100),
              sliver: SliverToBoxAdapter(child: body),
            ),
          ],
        ),
      ),
    );
  }

  Widget _maybeAnimate(
    bool enabled,
    Widget child, {
    bool fadeSlideX = false,
    bool fadeSlideY = false,
    int delayMs = 0,
  }) {
    if (!enabled) return child;
    var w = child;
    if (fadeSlideX) {
      w = w.animate().fadeIn(duration: 500.ms).slideX(begin: -0.15, curve: Curves.easeOutCubic);
    } else if (fadeSlideY) {
      w = w.animate(delay: Duration(milliseconds: delayMs)).fadeIn().slideY(begin: 0.2);
    }
    return w;
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.animate});
  final IconData icon;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
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
    );
    if (!animate) return badge;
    return badge
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
          Icon(icon, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
