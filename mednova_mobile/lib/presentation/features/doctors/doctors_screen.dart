import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/animations/mednova_3d_scene.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/specialty_labels.dart';
import '../../../data/models/patient_model.dart';
import '../../providers/app_providers.dart';
import '../../providers/person_detail_provider.dart';
import '../../shared/mednova_page_scaffold.dart';
import '../../shared/person_detail_sheet.dart';

class DoctorsScreen extends ConsumerWidget {
  const DoctorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(doctorsProvider);

    return MedNovaPageScaffold(
      title: 'Corps médical',
      subtitle: 'Spécialistes & disponibilités',
      icon: Icons.medical_services_rounded,
      body: async.when(
        loading: () => const MedNovaLoader(message: 'Chargement des médecins...'),
        error: (e, _) => MedNovaErrorBanner(
          message: e.toString(),
          onRetry: () => ref.invalidate(doctorsProvider),
        ),
        data: (doctors) {
          if (doctors.isEmpty) {
            return const MedNovaEmptyState(
              icon: Icons.medical_information_outlined,
              message: 'Aucun médecin enregistré',
            );
          }
          return Column(
            children: doctors.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Staggered3DEntrance(
                  index: entry.key,
                  child: _DoctorCard(
                    doctor: entry.value,
                    onTap: () => showPersonDetailSheet(
                      context,
                      ref,
                      kind: PersonDetailKind.doctor,
                      id: entry.value.id,
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

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor, required this.onTap});
  final DoctorModel doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Floating3DCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.auroraGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.local_hospital, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.fullName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                if (doctor.specialty != null)
                  Text(SpecialtyLabels.label(doctor.specialty), style: const TextStyle(color: AppColors.auroraCyan)),
                Text(doctor.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: doctor.active ? AppColors.success : AppColors.danger,
              boxShadow: [
                BoxShadow(
                  color: (doctor.active ? AppColors.success : AppColors.danger).withValues(alpha: 0.6),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
