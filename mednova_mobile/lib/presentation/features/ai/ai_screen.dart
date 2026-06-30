import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/animations/mednova_3d_scene.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/patient_model.dart';
import '../../providers/app_providers.dart';
import '../../providers/person_detail_provider.dart';
import '../../shared/person_detail_sheet.dart';
import '../../shared/mednova_page_scaffold.dart';

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  String? _selectedPatientId;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<PatientModel> _filter(List<PatientModel> patients, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return patients;
    return patients
        .where((p) => p.fullName.toLowerCase().contains(q) || p.email.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsProvider);
    final assessmentsAsync = _selectedPatientId == null
        ? null
        : ref.watch(riskAssessmentsProvider(_selectedPatientId!));

    return MedNovaPageScaffold(
      title: 'IA Prédictive',
      subtitle: 'Évaluation des risques santé',
      icon: Icons.psychology_rounded,
      showOrb: true,
      orbSize: 110,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Floating3DCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.auroraViolet.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: AppColors.auroraViolet),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Déclenchement automatique', style: TextStyle(fontWeight: FontWeight.w800)),
                      SizedBox(height: 6),
                      Text(
                        'L\'IA s\'active seule quand un infirmier ou un médecin enregistre les constantes vitales d\'un patient (événement VITALS_RECORDED). '
                        'Personne ne lance l\'analyse manuellement ici — cette page sert à consulter les scores et recommandations.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedPatientId != null) ...[
            _SelectedPatientBar(
              name: patientsAsync.maybeWhen(
                data: (list) => list.where((p) => p.id == _selectedPatientId).map((p) => p.fullName).firstOrNull ?? 'Patient',
                orElse: () => 'Patient',
              ),
              onClear: () => setState(() => _selectedPatientId = null),
              onOpenProfile: () => showPersonDetailSheet(
                context,
                ref,
                kind: PersonDetailKind.patient,
                id: _selectedPatientId!,
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Floating3DCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AuroraText('Health Risk Engine'),
                  const SizedBox(height: 8),
                  const Text(
                    'Tapez un nom ou sélectionnez un patient dans la liste.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un patient…',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            patientsAsync.when(
              loading: () => const MedNovaLoader(message: 'Chargement des patients…'),
              error: (_, __) => MedNovaErrorBanner(
                message: 'Impossible de charger les patients',
                onRetry: () => ref.invalidate(patientsProvider),
              ),
              data: (patients) {
                final filtered = _filter(patients, _searchCtrl.text);
                if (filtered.isEmpty) {
                  return const MedNovaEmptyState(
                    icon: Icons.person_search,
                    message: 'Aucun patient trouvé',
                  );
                }
                return Column(
                  children: filtered.take(8).map((p) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Floating3DCard(
                        onTap: () => setState(() {
                          _selectedPatientId = p.id;
                          _searchCtrl.clear();
                        }),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.auroraPink.withValues(alpha: 0.2),
                              child: Text(p.firstName[0], style: const TextStyle(fontWeight: FontWeight.w800)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  Text(p.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
          if (_selectedPatientId == null)
            const SizedBox.shrink()
          else
            assessmentsAsync!.when(
              loading: () => const MedNovaLoader(message: 'Analyse en cours...'),
              error: (e, _) => MedNovaErrorBanner(
                message: e.toString(),
                onRetry: () => ref.invalidate(riskAssessmentsProvider(_selectedPatientId!)),
              ),
              data: (assessments) {
                if (assessments.isEmpty) {
                  return const MedNovaEmptyState(
                    icon: Icons.insights,
                    message: 'Aucune évaluation pour ce patient',
                  );
                }
                return Column(
                  children: assessments.asMap().entries.map((entry) {
                    final a = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Staggered3DEntrance(
                        index: entry.key,
                        child: Floating3DCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Score ${a.riskScore}',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                                  ),
                                  RiskChip(level: a.riskLevel),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(a.recommendation, style: const TextStyle(color: AppColors.textMuted)),
                              if (a.factors.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: a.factors
                                      .map(
                                        (f) => Chip(
                                          label: Text(f, style: const TextStyle(fontSize: 11)),
                                          backgroundColor: AppColors.glassWhite,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                              if (a.triggerEventType != null) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.bolt, size: 14, color: AppColors.auroraGold),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Déclenché par : ${a.triggerEventType}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                a.assessedAt,
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
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
}

class _SelectedPatientBar extends StatelessWidget {
  const _SelectedPatientBar({
    required this.name,
    required this.onClear,
    required this.onOpenProfile,
  });

  final String name;
  final VoidCallback onClear;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Floating3DCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(onPressed: onClear, icon: const Icon(Icons.arrow_back), tooltip: 'Changer de patient'),
          Expanded(
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          TextButton.icon(
            onPressed: onOpenProfile,
            icon: const Icon(Icons.person_outline, size: 18),
            label: const Text('Fiche'),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
