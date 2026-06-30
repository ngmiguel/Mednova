import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/mednova_palette.dart';
import '../../domain/repositories/mednova_repositories.dart';

Future<void> showAuditDetailSheet(BuildContext context, AuditEventModel event) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _AuditDetailSheet(event: event),
  );
}

class _AuditDetailSheet extends StatelessWidget {
  const _AuditDetailSheet({required this.event});

  final AuditEventModel event;

  @override
  Widget build(BuildContext context) {
    final palette = MedNovaPalette.of(context);
    final payloadFields = _extractPayloadFields(event.payload);
    final prettyJson = _prettyJson(event.payload);

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
              Text(
                _eventLabel(event.eventType),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: palette.textPrimary,
                ),
              ),
              if (event.summary != null) ...[
                const SizedBox(height: 8),
                Text(event.summary!, style: TextStyle(color: palette.textMuted, height: 1.35)),
              ],
              const SizedBox(height: 20),
              _SectionTitle('Informations générales', palette: palette),
              _DetailRow(label: 'Type événement', value: event.eventType, palette: palette),
              _DetailRow(label: 'Libellé', value: _eventLabel(event.eventType), palette: palette),
              _DetailRow(label: 'Service source', value: event.source, palette: palette),
              _DetailRow(label: 'Identifiant événement', value: event.eventId, palette: palette),
              if (event.correlationId != null)
                _DetailRow(label: 'Correlation ID', value: event.correlationId!, palette: palette),
              if (event.actorLabel != null)
                _DetailRow(label: 'Acteur', value: event.actorLabel!, palette: palette),
              _DetailRow(label: 'Reçu le', value: _formatDate(event.receivedAt), palette: palette),
              if (payloadFields.isNotEmpty) ...[
                const SizedBox(height: 16),
                _SectionTitle('Détails métier (payload)', palette: palette),
                ...payloadFields.entries.map(
                  (e) => _DetailRow(label: _fieldLabel(e.key), value: e.value, palette: palette),
                ),
              ],
              if (prettyJson != null) ...[
                const SizedBox(height: 16),
                _SectionTitle('Données brutes (JSON)', palette: palette),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: palette.glassFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: palette.glassBorder),
                  ),
                  child: SelectableText(
                    prettyJson,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: palette.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
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

  static Map<String, String> _extractPayloadFields(String? raw) {
    if (raw == null || raw.trim().isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded.map((k, v) => MapEntry(k, _stringify(v)));
      }
      if (decoded is List) {
        return {'items': decoded.map(_stringify).join(', ')};
      }
    } catch (_) {}
    return {'contenu': raw};
  }

  static String? _prettyJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return raw;
    }
  }

  static String _stringify(Object? value) {
    if (value == null) return '—';
    if (value is Map || value is List) {
      return const JsonEncoder.withIndent('  ').convert(value);
    }
    return value.toString();
  }

  static String _fieldLabel(String key) => switch (key) {
        'userId' => 'Utilisateur',
        'email' => 'Email',
        'patientId' => 'Patient',
        'doctorId' => 'Médecin',
        'appointmentId' => 'Rendez-vous',
        'riskScore' => 'Score de risque',
        'riskLevel' => 'Niveau de risque',
        'triggerEventType' => 'Événement déclencheur',
        'createdBy' => 'Créé par',
        'ip' => 'Adresse IP',
        _ => key.replaceAll('_', ' '),
      };

  static String _formatDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(parsed.toLocal());
  }

  static String _eventLabel(String type) => switch (type) {
        'USER_LOGIN_SUCCESS' => 'Connexion utilisateur',
        'HEALTH_ALERT_TRIGGERED' => 'Alerte santé déclenchée',
        'PATIENT_RECORD_CREATED' => 'Dossier patient créé',
        'APPOINTMENT_SCHEDULED' => 'Rendez-vous planifié',
        _ => type.replaceAll('_', ' '),
      };
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.palette});

  final String text;
  final MedNovaPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          color: palette.textPrimary,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, required this.palette});

  final String label;
  final String value;
  final MedNovaPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: palette.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: TextStyle(fontWeight: FontWeight.w500, color: palette.textPrimary),
          ),
        ],
      ),
    );
  }
}
