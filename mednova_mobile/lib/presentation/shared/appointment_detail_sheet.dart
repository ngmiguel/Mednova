import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/animations/mednova_3d_scene.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/mednova_palette.dart';
import '../../data/models/patient_model.dart';

Future<void> showAppointmentDetailSheet(
  BuildContext context, {
  required AppointmentModel appointment,
  required String patientName,
  required String doctorName,
  VoidCallback? onOpenPatient,
  VoidCallback? onOpenDoctor,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _AppointmentDetailSheet(
      appointment: appointment,
      patientName: patientName,
      doctorName: doctorName,
      onOpenPatient: onOpenPatient,
      onOpenDoctor: onOpenDoctor,
    ),
  );
}

class _AppointmentDetailSheet extends StatelessWidget {
  const _AppointmentDetailSheet({
    required this.appointment,
    required this.patientName,
    required this.doctorName,
    this.onOpenPatient,
    this.onOpenDoctor,
  });

  final AppointmentModel appointment;
  final String patientName;
  final String doctorName;
  final VoidCallback? onOpenPatient;
  final VoidCallback? onOpenDoctor;

  @override
  Widget build(BuildContext context) {
    final palette = MedNovaPalette.of(context);
    final scheduled = _formatDate(appointment.scheduledAt);
    final statusColor = _statusColor(appointment.status);

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            gradient: palette.cardGradient,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: palette.glassBorder)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: palette.glassBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.event_available, color: statusColor),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.reason ?? 'Consultation',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                        Text(
                          _statusLabel(appointment.status),
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _ParticipantRow(
                icon: Icons.person_outline,
                label: 'Patient',
                name: patientName,
                onTap: onOpenPatient,
              ),
              const SizedBox(height: 10),
              _ParticipantRow(
                icon: Icons.medical_services_outlined,
                label: 'Médecin',
                name: doctorName,
                onTap: onOpenDoctor,
              ),
              const Divider(height: 32, color: Colors.transparent),
              _DetailRow(label: 'Date & heure', value: scheduled),
              _DetailRow(label: 'Durée', value: '${appointment.durationMinutes} minutes'),
              if (appointment.notes != null && appointment.notes!.isNotEmpty)
                _DetailRow(label: 'Notes', value: appointment.notes!),
              _DetailRow(label: 'Identifiant', value: appointment.id),
              if (appointment.createdAt != null)
                _DetailRow(label: 'Créé le', value: _formatDate(appointment.createdAt!)),
              if (appointment.updatedAt != null)
                _DetailRow(label: 'Mis à jour', value: _formatDate(appointment.updatedAt!)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _formatDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('EEEE d MMMM yyyy · HH:mm').format(parsed.toLocal());
  }

  static Color _statusColor(String status) => switch (status.toUpperCase()) {
        'CONFIRMED' => AppColors.success,
        'CANCELLED' => AppColors.danger,
        'COMPLETED' => AppColors.auroraViolet,
        _ => AppColors.auroraGold,
      };

  static String _statusLabel(String status) => switch (status.toUpperCase()) {
        'CONFIRMED' => 'Confirmé',
        'CANCELLED' => 'Annulé',
        'COMPLETED' => 'Terminé',
        'SCHEDULED' => 'Planifié',
        _ => status,
      };
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({
    required this.icon,
    required this.label,
    required this.name,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Floating3DCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.auroraTeal, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          if (onTap != null) const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
