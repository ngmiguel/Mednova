import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/mednova_palette.dart';

/// Rotating 3D medical orb — core visual signature of MedNova Mobile.
class MedNova3DOrb extends StatefulWidget {
  const MedNova3DOrb({
    super.key,
    this.size = 220,
    this.glowIntensity = 1,
  });

  final double size;
  final double glowIntensity;

  @override
  State<MedNova3DOrb> createState() => _MedNova3DOrbState();
}

class _MedNova3DOrbState extends State<MedNova3DOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value * 2 * math.pi;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _glowRing(t),
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateY(t * 0.6)
                  ..rotateX(t * 0.35),
                child: CustomPaint(
                  size: Size(widget.size * 0.72, widget.size * 0.72),
                  painter: _OrbPainter(phase: t),
                ),
              ),
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0015)
                  ..rotateY(-t * 0.9)
                  ..rotateZ(t * 0.5),
                child: CustomPaint(
                  size: Size(widget.size * 0.55, widget.size * 0.55),
                  painter: _RingPainter(phase: t),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _glowRing(double t) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.auroraTeal.withValues(
              alpha: 0.25 * widget.glowIntensity,
            ),
            blurRadius: 40 + 10 * math.sin(t),
            spreadRadius: 8,
          ),
          BoxShadow(
            color: AppColors.auroraViolet.withValues(
              alpha: 0.2 * widget.glowIntensity,
            ),
            blurRadius: 60 + 8 * math.cos(t * 1.3),
            spreadRadius: 4,
          ),
        ],
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final gradient = RadialGradient(
      colors: [
        AppColors.auroraCyan.withValues(alpha: 0.95),
        AppColors.auroraTeal.withValues(alpha: 0.8),
        AppColors.auroraViolet.withValues(alpha: 0.6),
        AppColors.deepSpace.withValues(alpha: 0.2),
      ],
      stops: const [0.0, 0.35, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);

    // Specular highlight (3D illusion)
    final highlight = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withValues(alpha: 0.55), Colors.transparent],
      ).createShader(
        Rect.fromCircle(
          center: center + Offset(-radius * 0.25, -radius * 0.3),
          radius: radius * 0.45,
        ),
      );
    canvas.drawCircle(center, radius, highlight);

    // Latitude lines
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var i = 0; i < 5; i++) {
      final angle = phase + i * math.pi / 5;
      final ry = radius * (0.25 + 0.12 * math.sin(angle));
      canvas.drawOval(
        Rect.fromCenter(center: center, width: radius * 1.6, height: ry * 2),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_OrbPainter oldDelegate) => oldDelegate.phase != phase;
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = SweepGradient(
        colors: [
          AppColors.auroraPink,
          AppColors.auroraViolet,
          AppColors.auroraCyan,
          AppColors.auroraPink,
        ],
        transform: GradientRotation(phase),
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawArc(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      0,
      math.pi * 1.6,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.phase != phase;
}

/// Interactive 3D tilt card reacting to touch position.
class Floating3DCard extends StatefulWidget {
  const Floating3DCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  State<Floating3DCard> createState() => _Floating3DCardState();
}

class _Floating3DCardState extends State<Floating3DCard>
    with SingleTickerProviderStateMixin {
  Offset _tilt = Offset.zero;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = MedNovaPalette.of(context);
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatY = math.sin(_floatController.value * math.pi) * 4;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_tilt.dy * 0.4)
            ..rotateY(-_tilt.dx * 0.4)
            ..translate(0.0, floatY),
          child: GestureDetector(
            onTap: widget.onTap,
            onPanUpdate: (d) {
              setState(() {
                _tilt = Offset(
                  (d.localPosition.dx / 200 - 0.5).clamp(-0.5, 0.5),
                  (d.localPosition.dy / 200 - 0.5).clamp(-0.5, 0.5),
                );
              });
            },
            onPanEnd: (_) => setState(() => _tilt = Offset.zero),
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                gradient: palette.cardGradient,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: palette.glassBorder),
                boxShadow: [
                  BoxShadow(
                    color: palette.cardShadow.withValues(alpha: palette.isDark ? 0.12 : 0.18),
                    blurRadius: palette.isDark ? 24 : 20,
                    offset: Offset(_tilt.dx * -20, _tilt.dy * -20 + 8),
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// Animated DNA double-helix in pseudo-3D.
class MedNovaDNAHelix extends StatefulWidget {
  const MedNovaDNAHelix({super.key, this.height = 280, this.width = 120});

  final double height;
  final double width;

  @override
  State<MedNovaDNAHelix> createState() => _MedNovaDNAHelixState();
}

class _MedNovaDNAHelixState extends State<MedNovaDNAHelix>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _HelixPainter(phase: _controller.value * 2 * math.pi),
        );
      },
    );
  }
}

class _HelixPainter extends CustomPainter {
  _HelixPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    const steps = 24;
    for (var i = 0; i < steps; i++) {
      final y = (i / steps) * size.height;
      final angle = phase + i * 0.45;
      final x1 = size.width / 2 + math.cos(angle) * size.width * 0.38;
      final x2 = size.width / 2 + math.cos(angle + math.pi) * size.width * 0.38;
      final depth = (math.sin(angle) + 1) / 2;
      final radius = 4 + depth * 5;

      final paint1 = Paint()..color = Color.lerp(AppColors.auroraTeal, AppColors.auroraCyan, depth)!;
      final paint2 = Paint()..color = Color.lerp(AppColors.auroraViolet, AppColors.auroraPink, depth)!;

      canvas.drawCircle(Offset(x1, y), radius, paint1);
      canvas.drawCircle(Offset(x2, y), radius, paint2);

      if (i % 3 == 0) {
        canvas.drawLine(
          Offset(x1, y),
          Offset(x2, y),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.08 + depth * 0.12)
            ..strokeWidth = 1,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_HelixPainter oldDelegate) => oldDelegate.phase != phase;
}

/// Deep parallax background with floating 3D layers.
class Parallax3DBackground extends StatefulWidget {
  const Parallax3DBackground({super.key, required this.child});

  final Widget child;

  @override
  State<Parallax3DBackground> createState() => _Parallax3DBackgroundState();
}

class _Parallax3DBackgroundState extends State<Parallax3DBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = MedNovaPalette.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value * 2 * math.pi;
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: palette.scaffoldGradient,
                ),
              ),
            ),
            ...List.generate(6, (i) {
              final angle = t + i * math.pi / 3;
              return Positioned(
                left: 40 + math.cos(angle) * 30 + i * 50.0,
                top: 80 + math.sin(angle * 0.7) * 40 + i * 90.0,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateX(angle * 0.2)
                    ..rotateY(angle * 0.3),
                  child: Container(
                    width: 80 + i * 12.0,
                    height: 80 + i * 12.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          palette.parallaxOrbColors[i % 4]
                              .withValues(alpha: palette.isDark ? 0.08 : 0.16),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}

/// Staggered fade + 3D slide entrance for list items.
class Staggered3DEntrance extends StatelessWidget {
  const Staggered3DEntrance({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + index * 80),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..translate(0.0, (1 - value) * 40)
            ..rotateX((1 - value) * 0.35)
            ..scale(0.85 + value * 0.15),
          child: Opacity(opacity: value.clamp(0, 1), child: child),
        );
      },
      child: child,
    );
  }
}

/// 3D page flip transition wrapper.
Route<T> build3DPageRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 700),
    reverseTransitionDuration: const Duration(milliseconds: 550),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final rotateAnim = Tween<double>(begin: 0.8, end: 0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );
      final fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: animation, curve: const Interval(0.2, 1)),
      );

      return AnimatedBuilder(
        animation: animation,
        child: child,
        builder: (context, child) {
          final m = Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(rotateAnim.value);
          return Transform(
            alignment: Alignment.centerRight,
            transform: m,
            child: Opacity(opacity: fadeAnim.value, child: child),
          );
        },
      );
    },
  );
}
