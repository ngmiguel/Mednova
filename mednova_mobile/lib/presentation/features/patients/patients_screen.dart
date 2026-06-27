import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/animations/mednova_3d_scene.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/patient_model.dart';
import '../../providers/app_providers.dart';
import '../../providers/person_detail_provider.dart';
import '../../shared/mednova_page_scaffold.dart';
import '../../shared/person_detail_sheet.dart';

class PatientsScreen extends ConsumerWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(patientsProvider);

    return MedNovaPageScaffold(
      title: 'Patients',
      subtitle: 'Dossiers médicaux sécurisés',
      icon: Icons.people_alt_rounded,
      body: async.when(
        loading: () => const MedNovaLoader(message: 'Chargement des dossiers...'),
        error: (e, _) => MedNovaErrorBanner(
          message: e.toString(),
          onRetry: () => ref.invalidate(patientsProvider),
        ),
        data: (patients) {
          if (patients.isEmpty) {
            return const MedNovaEmptyState(
              icon: Icons.person_off,
              message: 'Aucun patient enregistré',
            );
          }
          return Column(
            children: patients.asMap().entries.map((entry) {
              final i = entry.key;
              final p = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Staggered3DEntrance(
                  index: i,
                  child: _PatientCard(
                    patient: p,
                    onTap: () => showPersonDetailSheet(
                      context,
                      ref,
                      kind: PersonDetailKind.patient,
                      id: p.id,
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
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient, required this.onTap});
  final PatientModel patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Floating3DCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.auroraTeal.withValues(alpha: 0.2),
            child: Text(
              patient.firstName[0] + patient.lastName[0],
              style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.auroraTeal),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.fullName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                Text(patient.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                if (patient.bloodType != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('Groupe ${patient.bloodType}', style: const TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
