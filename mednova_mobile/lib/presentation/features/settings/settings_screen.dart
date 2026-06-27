import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/animations/mednova_3d_scene.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/app_settings.dart' as prefs;
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_admin_model.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/person_detail_provider.dart';
import '../../providers/settings_provider.dart';
import '../../shared/mednova_page_scaffold.dart';
import '../../shared/person_detail_sheet.dart';
import '../../shell/mednova_shell.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isDemo = ref.read(isDemoSessionProvider);
      ref.read(settingsProvider.notifier).refreshStats(isDemo: isDemo);
      ref.read(settingsProvider.notifier).checkGateway(isDemo: isDemo);
    });
  }

  void _apply(prefs.AppSettings next) {
    final email = ref.read(authProvider).valueOrNull?.user?.email;
    ref.read(settingsProvider.notifier).update(next, userEmail: email);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider).valueOrNull;
    final user = auth?.user;
    final settingsState = ref.watch(settingsProvider);
    final settings = settingsState.settings;
    final strings = ref.watch(appStringsProvider);
    final isDemo = auth?.isDemoSession ?? false;
    final isAdmin = auth?.roles.contains(UserRole.admin) ?? false;
    final nursesAsync = isAdmin ? ref.watch(nursesProvider) : null;

    return MedNovaPageScaffold(
      title: strings.settingsTitle,
      subtitle: strings.settingsSubtitle,
      icon: Icons.settings_rounded,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (settingsState.savedFlash)
            _SavedBanner(message: strings.saved),
          if (isDemo) ...[
            _DemoBanner(title: strings.demoMode, hint: strings.demoModeHint),
            const SizedBox(height: 8),
          ],
          _SettingsSection(
            title: strings.profile,
            icon: Icons.person_outline,
            initiallyExpanded: true,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.auroraTeal.withValues(alpha: 0.2),
                  child: Text(
                    user?.firstName[0] ?? '?',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.fullName ?? '—', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                      Text(user?.email ?? '', style: const TextStyle(color: AppColors.textMuted)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: (auth?.roles ?? [])
                            .map((r) => Chip(label: Text(r.name, style: const TextStyle(fontSize: 11))))
                            .toList(),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '2FA : ${user?.twoFactorEnabled == true ? 'Activée' : 'Désactivée'}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _SettingsSection(
            title: strings.appearance,
            icon: Icons.palette_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Thème', style: _fieldLabel),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _themeChip(strings.themeLight, prefs.ThemeMode.light, settings),
                    _themeChip(strings.themeDark, prefs.ThemeMode.dark, settings),
                    _themeChip(strings.themeSystem, prefs.ThemeMode.system, settings),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<prefs.UiDensity>(
                  key: ValueKey(settings.density),
                  initialValue: settings.density,
                  decoration: InputDecoration(labelText: strings.densityComfortable),
                  items: [
                    DropdownMenuItem(value: prefs.UiDensity.comfortable, child: Text(strings.densityComfortable)),
                    DropdownMenuItem(value: prefs.UiDensity.compact, child: Text(strings.densityCompact)),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    _apply(settings.copyWith(density: v, compactNav: v == prefs.UiDensity.compact));
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<prefs.AppLanguage>(
                  key: ValueKey(settings.language),
                  initialValue: settings.language,
                  decoration: InputDecoration(labelText: strings.languageLabel),
                  items: [
                    DropdownMenuItem(value: prefs.AppLanguage.fr, child: Text(strings.french)),
                    DropdownMenuItem(value: prefs.AppLanguage.en, child: Text(strings.english)),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    _apply(settings.copyWith(language: v));
                  },
                ),
                _toggle(strings.animations, settings.animationsEnabled, (v) {
                  _apply(settings.copyWith(animationsEnabled: v));
                }),
                _toggle(strings.compactNav, settings.compactNav, (v) {
                  _apply(
                    settings.copyWith(
                      compactNav: v,
                      density: v ? prefs.UiDensity.compact : prefs.UiDensity.comfortable,
                    ),
                  );
                }),
              ],
            ),
          ),
          _SettingsSection(
            title: strings.sessionSecurity,
            icon: Icons.lock_outline,
            child: Column(
              children: [
                _toggle(strings.staySignedIn, settings.staySignedIn, (v) {
                  _apply(settings.copyWith(staySignedIn: v));
                }),
                _toggle(strings.rememberEmail, settings.rememberEmail, (v) {
                  _apply(settings.copyWith(rememberEmail: v));
                }),
              ],
            ),
          ),
          _SettingsSection(
            title: strings.notifications,
            icon: Icons.notifications_outlined,
            child: Column(
              children: [
                _toggle(strings.inAppNotif, settings.inAppNotifications, (v) {
                  _apply(settings.copyWith(inAppNotifications: v));
                }),
                _toggle(strings.emailNotif, settings.emailNotifications, (v) {
                  _apply(settings.copyWith(emailNotifications: v));
                }),
                if (settings.inAppNotifications) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => goToShellBranch(context, 6),
                      icon: const Icon(Icons.notifications_outlined),
                      label: Text(strings.openNotifications),
                    ),
                  ),
                ],
              ],
            ),
          ),
          _SettingsSection(
            title: strings.dataSync,
            icon: Icons.sync,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (settingsState.stats != null) ...[
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _statChip('Patients', settingsState.stats!.patients),
                      _statChip('Médecins', settingsState.stats!.doctors),
                      _statChip('RDV', settingsState.stats!.appointments),
                      _statChip('Audit', settingsState.stats!.auditEvents),
                    ],
                  ),
                  Text(
                    'Sync : ${DateFormat('HH:mm:ss').format(settingsState.stats!.lastUpdated)}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                ],
                ElevatedButton.icon(
                  onPressed: settingsState.refreshingStats
                      ? null
                      : () => ref.read(settingsProvider.notifier).refreshStats(isDemo: isDemo),
                  icon: settingsState.refreshingStats
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.refresh),
                  label: Text(strings.refreshStats),
                ),
                const SizedBox(height: 10),
                Text(
                  '${AppConfig.platformLabel} · env ${AppConfig.appEnv}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                Text(
                  AppConfig.apiBaseUrl,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
          if (isAdmin)
            _SettingsSection(
              title: strings.adminSection,
              icon: Icons.admin_panel_settings_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(strings.gateway, style: const TextStyle(fontWeight: FontWeight.w600))),
                      if (settingsState.checkingGateway)
                        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      else
                        _statusBadge(settingsState.gatewayStatus ?? '—'),
                    ],
                  ),
                  Text(AppConfig.apiBaseUrl, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  TextButton.icon(
                    onPressed: () => ref.read(settingsProvider.notifier).checkGateway(isDemo: isDemo),
                    icon: const Icon(Icons.network_check),
                    label: Text(strings.checkGateway),
                  ),
                  const Divider(color: AppColors.glassBorder),
                  Text(strings.nurses, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  nursesAsync?.when(
                        loading: () => const Text('Chargement…', style: TextStyle(color: AppColors.textMuted)),
                        error: (_, __) => const Text('Erreur chargement'),
                        data: (nurses) => nurses.isEmpty
                            ? const Text('Aucun infirmier', style: TextStyle(color: AppColors.textMuted))
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: nurses.map((n) => _staffChip(context, n)).toList(),
                              ),
                      ) ??
                      const SizedBox.shrink(),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton(onPressed: () => goToShellBranch(context, 1), child: const Text('Patients')),
                      TextButton(onPressed: () => goToShellBranch(context, 2), child: const Text('Médecins')),
                      TextButton(onPressed: () => goToShellBranch(context, 7), child: const Text('Audit')),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger.withValues(alpha: 0.18),
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Se déconnecter ?'),
                    content: const Text('Votre session sera fermée sur cet appareil.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Déconnexion', style: TextStyle(color: AppColors.danger)),
                      ),
                    ],
                  ),
                );
                if (confirm != true || !context.mounted) return;
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: Text(strings.logout),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => ref.read(settingsProvider.notifier).reset(userEmail: user?.email),
            icon: const Icon(Icons.restart_alt),
            label: Text(strings.reset),
          ),
          const SizedBox(height: 24),
          if (settings.animationsEnabled) const Center(child: MedNova3DOrb(size: 80, glowIntensity: 0.5)),
        ],
      ),
    );
  }

  static const _fieldLabel = TextStyle(fontWeight: FontWeight.w600, fontSize: 13);

  Widget _themeChip(String label, prefs.ThemeMode mode, prefs.AppSettings settings) {
    final selected = settings.theme == mode;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => _apply(settings.copyWith(theme: mode)),
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _statChip(String label, int count) {
    return Chip(label: Text('$label : $count'), backgroundColor: AppColors.glassWhite);
  }

  Widget _statusBadge(String status) {
    final ok = status == 'UP' || status.startsWith('UP');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (ok ? AppColors.success : AppColors.danger).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status, style: TextStyle(color: ok ? AppColors.success : AppColors.danger, fontWeight: FontWeight.w700)),
    );
  }

  Widget _staffChip(BuildContext context, UserAccountModel nurse) {
    return ActionChip(
      avatar: CircleAvatar(child: Text(nurse.firstName[0])),
      label: Text('${nurse.firstName} ${nurse.lastName}'),
      onPressed: () => showPersonDetailSheet(
        context,
        ref,
        kind: PersonDetailKind.staff,
        userId: nurse.id,
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.child,
    this.initiallyExpanded = false,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Floating3DCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            leading: Icon(icon, color: AppColors.auroraTeal),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            children: [child],
          ),
        ),
      ),
    );
  }
}

class _SavedBanner extends StatelessWidget {
  const _SavedBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: 10),
          Text(message, style: const TextStyle(color: AppColors.success)),
        ],
      ),
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner({required this.title, required this.hint});
  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Floating3DCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.offline_bolt, color: AppColors.auroraGold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(hint, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
