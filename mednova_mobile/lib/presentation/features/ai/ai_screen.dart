import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/animations/mednova_3d_scene.dart';
import '../../../core/theme/app_theme.dart';
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuroraText('Health Risk Engine'),
                const SizedBox(height: 8),
                const Text(
                  'Sélectionnez un patient pour visualiser son historique d\'évaluations IA.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                patientsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Impossible de charger les patients'),
                  data: (patients) => DropdownButtonFormField<String>(
                    value: _selectedPatientId,
                    decoration: const InputDecoration(labelText: 'Patient'),
                    items: patients
                        .map((p) => DropdownMenuItem(value: p.id, child: Text(p.fullName)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedPatientId = v),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_selectedPatientId != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => showPersonDetailSheet(
                  context,
                  ref,
                  kind: PersonDetailKind.patient,
                  id: _selectedPatientId!,
                ),
                icon: const Icon(Icons.person_search),
                label: const Text('Voir la fiche patient'),
              ),
            ),
          if (_selectedPatientId == null)
            const MedNovaEmptyState(
              icon: Icons.biotech,
              message: 'Choisissez un patient pour l\'analyse',
            )
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
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
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
                                      .map((f) => Chip(
                                            label: Text(f, style: const TextStyle(fontSize: 11)),
                                            backgroundColor:
                                                AppColors.glassWhite,
                                          ))
                                      .toList(),
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
