import '../../domain/repositories/mednova_repositories.dart';
import '../models/auth_models.dart';
import '../models/messaging_models.dart';
import '../models/patient_model.dart';
import '../models/user_admin_model.dart';

/// Données locales pour le mode démo (sans backend).
class DemoCatalog {
  DemoCatalog._();

  static final Map<String, UserAccountModel> _accounts = {
    'user-admin': const UserAccountModel(
      id: 'user-admin',
      email: 'admin@mednova.ai',
      firstName: 'Alice',
      lastName: 'Admin',
      enabled: true,
      twoFactorEnabled: true,
      roles: ['ROLE_ADMIN'],
      createdAt: '2024-01-15T10:00:00Z',
    ),
    'user-doctor': const UserAccountModel(
      id: 'user-doctor',
      email: 'dr.smith@mednova.ai',
      firstName: 'John',
      lastName: 'Smith',
      enabled: true,
      twoFactorEnabled: false,
      roles: ['ROLE_DOCTOR'],
      createdAt: '2024-02-01T09:00:00Z',
    ),
    'user-nurse': const UserAccountModel(
      id: 'user-nurse',
      email: 'nurse@mednova.ai',
      firstName: 'Emma',
      lastName: 'Wilson',
      enabled: true,
      twoFactorEnabled: false,
      roles: ['ROLE_NURSE'],
      createdAt: '2024-03-10T08:00:00Z',
    ),
    'user-nurse-2': const UserAccountModel(
      id: 'user-nurse-2',
      email: 'nurse2@mednova.ai',
      firstName: 'Lucas',
      lastName: 'Bernard',
      enabled: true,
      twoFactorEnabled: false,
      roles: ['ROLE_NURSE'],
      createdAt: '2024-04-05T11:00:00Z',
    ),
    'user-patient': const UserAccountModel(
      id: 'user-patient',
      email: 'patient.test@mednova.ai',
      firstName: 'Marie',
      lastName: 'Dupont',
      enabled: true,
      twoFactorEnabled: false,
      roles: ['ROLE_PATIENT'],
      createdAt: '2024-05-20T14:00:00Z',
    ),
    'user-auditor': const UserAccountModel(
      id: 'user-auditor',
      email: 'auditor@mednova.ai',
      firstName: 'Paul',
      lastName: 'Audit',
      enabled: true,
      twoFactorEnabled: true,
      roles: ['ROLE_AUDITOR'],
      createdAt: '2024-06-01T16:00:00Z',
    ),
  };

  static UserProfile profileFor(DemoAccount account) => UserProfile(
        id: account.userId,
        email: account.email,
        firstName: account.firstName,
        lastName: account.lastName,
        roles: [account.role.value],
        twoFactorEnabled: account.twoFactorEnabled,
      );

  static DemoAccount? accountByEmail(String email) {
    for (final a in demoAccounts) {
      if (a.email == email) return a;
    }
    return null;
  }

  static const patients = [
    PatientModel(
      id: 'pat-001',
      userId: 'user-patient',
      firstName: 'Marie',
      lastName: 'Dupont',
      email: 'patient.test@mednova.ai',
      phone: '+33 6 12 34 56 78',
      bloodType: 'A_POSITIVE',
      gender: 'F',
      dateOfBirth: '1985-06-12',
      address: '12 rue de la Santé, Paris',
      emergencyContact: 'Jean Dupont — +33 6 98 76 54 32',
      createdAt: '2024-05-20T14:00:00Z',
    ),
    PatientModel(
      id: 'pat-002',
      userId: 'user-patient-2',
      firstName: 'Thomas',
      lastName: 'Martin',
      email: 'thomas.m@email.com',
      phone: '+33 6 55 44 33 22',
      bloodType: 'O_NEGATIVE',
      gender: 'M',
      dateOfBirth: '1978-03-22',
      address: '45 av. Victor Hugo, Lyon',
      createdAt: '2024-07-01T10:00:00Z',
    ),
    PatientModel(
      id: 'pat-003',
      userId: 'user-patient-3',
      firstName: 'Sophie',
      lastName: 'Laurent',
      email: 'sophie.l@email.com',
      bloodType: 'B_POSITIVE',
      gender: 'F',
      dateOfBirth: '1992-11-08',
      createdAt: '2024-08-15T09:30:00Z',
    ),
  ];

  static const doctors = [
    DoctorModel(
      id: 'doc-001',
      userId: 'user-doctor',
      firstName: 'John',
      lastName: 'Smith',
      email: 'dr.smith@mednova.ai',
      specialty: 'CARDIOLOGY',
      phone: '+33 1 44 55 66 77',
      licenseNumber: 'MED-FR-12345',
      bio: 'Cardiologue — 15 ans d\'expérience',
      active: true,
      createdAt: '2024-02-01T09:00:00Z',
    ),
    DoctorModel(
      id: 'doc-002',
      userId: 'user-doctor-2',
      firstName: 'Sarah',
      lastName: 'Chen',
      email: 'dr.chen@mednova.ai',
      specialty: 'NEUROLOGY',
      licenseNumber: 'MED-FR-67890',
      active: true,
      createdAt: '2024-03-15T11:00:00Z',
    ),
    DoctorModel(
      id: 'doc-003',
      userId: 'user-doctor-3',
      firstName: 'Ahmed',
      lastName: 'Benali',
      email: 'dr.benali@mednova.ai',
      specialty: 'GENERAL_PRACTICE',
      active: true,
      createdAt: '2024-04-20T08:00:00Z',
    ),
  ];

  static PatientModel? patientById(String id) {
    for (final p in patients) {
      if (p.id == id) return p;
    }
    return null;
  }

  static DoctorModel? doctorById(String id) {
    for (final d in doctors) {
      if (d.id == id) return d;
    }
    return null;
  }

  static const appointments = [
    AppointmentModel(
      id: 'appt-001',
      scheduledAt: '2026-06-28T09:00:00Z',
      status: 'CONFIRMED',
      reason: 'Consultation cardiologie',
      durationMinutes: 30,
    ),
    AppointmentModel(
      id: 'appt-002',
      scheduledAt: '2026-06-29T14:30:00Z',
      status: 'SCHEDULED',
      reason: 'Suivi post-opératoire',
      durationMinutes: 45,
    ),
    AppointmentModel(
      id: 'appt-003',
      scheduledAt: '2026-06-25T11:00:00Z',
      status: 'COMPLETED',
      reason: 'Bilan annuel',
      durationMinutes: 30,
    ),
  ];

  static const notifications = [
    NotificationModel(
      id: 'notif-001',
      title: 'Alerte clinique',
      message: 'Score de risque MODERATE pour Marie Dupont',
      type: 'HEALTH',
      status: 'UNREAD',
      createdAt: '2026-06-27T08:15:00Z',
    ),
    NotificationModel(
      id: 'notif-002',
      title: 'Rendez-vous confirmé',
      message: 'RDV du 28/06 à 09:00 confirmé',
      type: 'APPOINTMENT',
      status: 'READ',
      createdAt: '2026-06-26T16:00:00Z',
    ),
    NotificationModel(
      id: 'notif-003',
      title: 'Nouveau message',
      message: 'Dr. Smith vous a envoyé un message',
      type: 'INFO',
      status: 'UNREAD',
      createdAt: '2026-06-27T10:30:00Z',
    ),
  ];

  static const auditEvents = [
    AuditEventModel(
      eventId: 'evt-001',
      eventType: 'USER_LOGIN_SUCCESS',
      source: 'auth-service',
      receivedAt: '2026-06-27T09:00:00Z',
    ),
    AuditEventModel(
      eventId: 'evt-002',
      eventType: 'HEALTH_ALERT_TRIGGERED',
      source: 'ai-prediction-service',
      receivedAt: '2026-06-27T08:15:00Z',
    ),
    AuditEventModel(
      eventId: 'evt-003',
      eventType: 'PATIENT_RECORD_CREATED',
      source: 'patient-service',
      receivedAt: '2026-06-26T14:22:00Z',
    ),
  ];

  static final List<ConversationModel> _conversationList = [
    ConversationModel(
      id: 'conv-001',
      patientUserId: 'user-patient',
      doctorUserId: 'user-doctor',
      patientId: 'pat-001',
      doctorId: 'doc-001',
      subject: 'Suivi cardiologique',
      createdAt: '2026-06-20T10:00:00Z',
      updatedAt: '2026-06-27T10:30:00Z',
    ),
  ];

  static final Map<String, List<ChatMessageModel>> _messages = {
    'conv-001': [
      const ChatMessageModel(
        id: 'msg-001',
        conversationId: 'conv-001',
        senderUserId: 'user-doctor',
        content: 'Bonjour Marie, comment allez-vous depuis la dernière consultation ?',
        sentAt: '2026-06-27T09:00:00Z',
      ),
      const ChatMessageModel(
        id: 'msg-002',
        conversationId: 'conv-001',
        senderUserId: 'user-patient',
        content: 'Bonjour Docteur, je me sens mieux. Moins de fatigue.',
        sentAt: '2026-06-27T09:15:00Z',
      ),
      const ChatMessageModel(
        id: 'msg-003',
        conversationId: 'conv-001',
        senderUserId: 'user-doctor',
        content: 'Excellent. Continuez le traitement prescrit et prenez rendez-vous dans 3 semaines.',
        sentAt: '2026-06-27T10:30:00Z',
      ),
    ],
  };

  static List<ChatMessageModel> messagesFor(String conversationId) =>
      List.unmodifiable(_messages[conversationId] ?? []);

  static ChatMessageModel addMessage(String conversationId, String senderUserId, String content) {
    final msg = ChatMessageModel(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderUserId: senderUserId,
      content: content,
      sentAt: DateTime.now().toUtc().toIso8601String(),
    );
    _messages.putIfAbsent(conversationId, () => []).add(msg);
    return msg;
  }

  static ConversationModel createConversation({
    required String patientUserId,
    required String doctorUserId,
    String? patientId,
    String? doctorId,
  }) {
    final conv = ConversationModel(
      id: 'conv-${DateTime.now().millisecondsSinceEpoch}',
      patientUserId: patientUserId,
      doctorUserId: doctorUserId,
      patientId: patientId,
      doctorId: doctorId,
      createdAt: DateTime.now().toUtc().toIso8601String(),
      updatedAt: DateTime.now().toUtc().toIso8601String(),
    );
    _messages[conv.id] = [];
    _conversationList.insert(0, conv);
    return conv;
  }

  static List<ConversationModel> get allConversations => List.unmodifiable(_conversationList);

  static const riskAssessments = {
    'pat-001': [
      RiskAssessmentModel(
        id: 'risk-001',
        patientId: 'pat-001',
        riskScore: 72,
        riskLevel: 'HIGH',
        factors: ['Tension élevée', 'Antécédents familiaux', 'Sédentarité'],
        recommendation: 'Consultation cardiologique sous 48h recommandée.',
        assessedAt: '2026-06-27T08:00:00Z',
      ),
      RiskAssessmentModel(
        id: 'risk-002',
        patientId: 'pat-001',
        riskScore: 45,
        riskLevel: 'MODERATE',
        factors: ['Légère élévation glycémie'],
        recommendation: 'Surveillance biologique dans 3 mois.',
        assessedAt: '2026-06-15T08:00:00Z',
      ),
    ],
    'pat-002': [
      RiskAssessmentModel(
        id: 'risk-003',
        patientId: 'pat-002',
        riskScore: 22,
        riskLevel: 'LOW',
        factors: ['Mode de vie actif'],
        recommendation: 'Poursuivre le suivi habituel.',
        assessedAt: '2026-06-20T08:00:00Z',
      ),
    ],
  };

  static List<RiskAssessmentModel> risksForPatient(String patientId) =>
      List.unmodifiable(riskAssessments[patientId] ?? []);

  static List<UserAccountModel> get nurses => _accounts.values
      .where((a) => a.roles.contains('ROLE_NURSE'))
      .toList();

  static UserAccountModel? accountById(String id) => _accounts[id];

  static UserAccountModel setAccountAccess(String id, bool enabled) {
    final current = _accounts[id]!;
    final updated = UserAccountModel(
      id: current.id,
      email: current.email,
      firstName: current.firstName,
      lastName: current.lastName,
      enabled: enabled,
      twoFactorEnabled: current.twoFactorEnabled,
      roles: current.roles,
      createdAt: current.createdAt,
    );
    _accounts[id] = updated;
    return updated;
  }

  static NavStats get stats => NavStats(
        patients: patients.length,
        doctors: doctors.length,
        appointments: appointments.length,
        auditEvents: auditEvents.length,
        lastUpdated: DateTime.now(),
      );
}

class NavStats {
  const NavStats({
    required this.patients,
    required this.doctors,
    required this.appointments,
    required this.auditEvents,
    required this.lastUpdated,
  });

  final int patients;
  final int doctors;
  final int appointments;
  final int auditEvents;
  final DateTime lastUpdated;
}
