import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/animations/mednova_3d_scene.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/auth_models.dart';
import '../../providers/auth_notifier.dart';
import '../../shared/mednova_page_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);
    final loading = authAsync.isLoading;
    final error = authAsync.hasError
        ? authAsync.error.toString().replaceFirst('Exception: ', '')
        : null;

    return Scaffold(
      body: Parallax3DBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const MedNova3DOrb(size: 260, glowIntensity: 1.2),
                    Positioned(
                      right: 20,
                      top: 40,
                      child: MedNovaDNAHelix(height: 200, width: 80)
                          .animate(onPlay: (c) => c.repeat())
                          .fadeIn(duration: 800.ms),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const AuroraText('MedNova AI')
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
                Text(
                  'Santé prédictive · Interface nouvelle génération',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                  textAlign: TextAlign.center,
                ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.3),
                const SizedBox(height: 32),
                Floating3DCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.alternate_email),
                          ),
                          validator: (v) =>
                              v != null && v.contains('@') ? null : 'Email invalide',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) =>
                              v != null && v.length >= 6 ? null : 'Minimum 6 caractères',
                        ),
                        if (error != null) ...[
                          const SizedBox(height: 12),
                          Text(error, style: const TextStyle(color: AppColors.danger)),
                        ],
                        const SizedBox(height: 24),
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final scale = 1 + math.sin(_pulseController.value * math.pi) * 0.02;
                            return Transform.scale(scale: scale, child: child);
                          },
                          child: ElevatedButton(
                            onPressed: loading ? null : _submit,
                            child: loading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Connexion sécurisée'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: 450.ms).fadeIn().slideY(begin: 0.2),
                const SizedBox(height: 28),
                Text(
                  'Comptes démo — touchez pour connexion instantanée',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: demoAccounts.asMap().entries.map((entry) {
                    final i = entry.key;
                    final account = entry.value;
                    return Staggered3DEntrance(
                      index: i,
                      child: ActionChip(
                        avatar: CircleAvatar(
                          backgroundColor: AppColors.auroraViolet.withValues(alpha: 0.3),
                          child: Text(account.label[0]),
                        ),
                        label: Text(account.label),
                        onPressed: loading
                            ? null
                            : () => ref.read(authProvider.notifier).loginDemo(account),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
