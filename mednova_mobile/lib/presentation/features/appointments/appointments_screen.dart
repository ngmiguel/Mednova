import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/animations/mednova_3d_scene.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/demo/demo_catalog.dart';
import '../../../data/models/patient_model.dart';
import '../../providers/app_providers.dart';
import '../../providers/person_detail_provider.dart';
import '../../shared/appointment_detail_sheet.dart';
import '../../shared/mednova_page_scaffold.dart';
import '../../shared/person_detail_sheet.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(appointmentsProvider);
    final patientsAsync = ref.watch(patientsProvider);
    final doctorsAsync = ref.watch(doctorsProvider);

    return MedNovaPageScaffold(
      title: 'Rendez-vous',
      subtitle: 'Planning patient ↔ médecin',
      icon: Icons.event_rounded,
      body: async.when(
        loading: () => const MedNovaLoader(message: 'Chargement du planning...'),
        error: (e, _) => MedNovaErrorBanner(
          message: e.toString(),
          onRetry: () => ref.invalidate(appointmentsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const MedNovaEmptyState(
              icon: Icons.event_busy,
              message: 'Aucun rendez-vous planifié',
            );
          }

          final patients = patientsAsync.valueOrNull ?? DemoCatalog.patients;
          final doctors = doctorsAsync.valueOrNull ?? DemoCatalog.doctors;

          return Column(
            children: items.asMap().entries.map((entry) {
              final appt = entry.value;
              final patientName = _resolvePatientName(patients, appt.patientId);
              final doctorName = _resolveDoctorName(doctors, appt.doctorId);
              final scheduled = _formatShort(appt.scheduledAt);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Staggered3DEntrance(
                  index: entry.key,
                  child: Floating3DCard(
                    onTap: () => showAppointmentDetailSheet(
                      context,
                      appointment: appt,
                      patientName: patientName,
                      doctorName: doctorName,
                      onOpenPatient: appt.patientId == null
                          ? null
                          : () {
                              Navigator.pop(context);
                              showPersonDetailSheet(
                                context,
                                ref,
                                kind: PersonDetailKind.patient,
                                id: appt.patientId!,
                              );
                            },
                      onOpenDoctor: appt.doctorId == null
                          ? null
                          : () {
                              Navigator.pop(context);
                              showPersonDetailSheet(
                                context,
                                ref,
                                kind: PersonDetailKind.doctor,
                                id: appt.doctorId!,
                              );
                            },
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _statusColor(appt.status).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.schedule, color: _statusColor(appt.status)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appt.reason ?? 'Consultation',
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 6),
                              _ParticipantChip(
                                icon: Icons.person_outline,
                                label: patientName,
                                color: AppColors.auroraPink,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.arrow_forward, size: 14, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: _ParticipantChip(
                                      icon: Icons.medical_services_outlined,
                                      label: doctorName,
                                      color: AppColors.auroraTeal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                scheduled,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              Text(
                                '${appt.durationMinutes} min · ${_statusLabel(appt.status)}',
                                style: TextStyle(
                                  color: _statusColor(appt.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.textMuted),
                      ],
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

  static String _resolvePatientName(List<PatientModel> patients, String? id) {
    if (id == null) return 'Patient non renseigné';
    for (final p in patients) {
      if (p.id == id) return p.fullName;
    }
    return DemoCatalog.patientById(id)?.fullName ?? 'Patient $id';
  }

  static String _resolveDoctorName(List<DoctorModel> doctors, String? id) {
    if (id == null) return 'Médecin non renseigné';
    for (final d in doctors) {
      if (d.id == id) return d.fullName;
    }
    return DemoCatalog.doctorById(id)?.fullName ?? 'Médecin $id';
  }

  static String _formatShort(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('EEE d MMM · HH:mm').format(parsed.toLocal());
  }

  static String _statusLabel(String status) => switch (status.toUpperCase()) {
        'CONFIRMED' => 'Confirmé',
        'CANCELLED' => 'Annulé',
        'COMPLETED' => 'Terminé',
        'SCHEDULED' => 'Planifié',
        _ => status,
      };

  Color _statusColor(String status) => switch (status.toUpperCase()) {
        'CONFIRMED' => AppColors.success,
        'CANCELLED' => AppColors.danger,
        'COMPLETED' => AppColors.auroraViolet,
        _ => AppColors.auroraGold,
      };
}

class _ParticipantChip extends StatelessWidget {
  const _ParticipantChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
