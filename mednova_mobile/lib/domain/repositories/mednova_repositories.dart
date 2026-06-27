import '../../data/models/auth_models.dart';
import '../../data/models/messaging_models.dart';
import '../../data/models/patient_model.dart';
import '../../data/models/user_admin_model.dart';

abstract class AuthRepository {
  Future<AuthTokens> login(LoginRequest request);
  Future<UserProfile> loadProfile();
  Future<void> logout();
  Future<bool> hasSession();
}

abstract class PatientRepository {
  Future<List<PatientModel>> list({int size = 50});
  Future<PatientModel> getById(String id);
}

abstract class DoctorRepository {
  Future<List<DoctorModel>> list({int size = 50});
  Future<DoctorModel> getById(String id);
}

abstract class AiRepository {
  Future<List<RiskAssessmentModel>> listByPatient(String patientId, {int size = 50});
}

abstract class NotificationRepository {
  Future<List<NotificationModel>> list({int size = 50});
}

abstract class AppointmentRepository {
  Future<List<AppointmentModel>> list({int size = 50});
}

abstract class UserAdminRepository {
  Future<UserAccountModel> getById(String userId);
  Future<UserAccountModel> setAccess(String userId, bool enabled);
}

abstract class MessagingRepository {
  Future<List<ConversationModel>> listConversations();
  Future<ConversationModel> createConversation({
    required String patientUserId,
    required String doctorUserId,
    String? patientId,
    String? doctorId,
    String? subject,
  });
  Future<List<ChatMessageModel>> listMessages(String conversationId);
  Future<ChatMessageModel> sendMessage(String conversationId, String content);
  Future<void> markRead(String conversationId);
}

abstract class AuditRepository {
  Future<List<AuditEventModel>> list({int size = 50});
}

class AuditEventModel {
  const AuditEventModel({
    required this.eventId,
    required this.eventType,
    required this.source,
    required this.receivedAt,
  });

  factory AuditEventModel.fromJson(Map<String, dynamic> json) => AuditEventModel(
        eventId: json['eventId'] as String,
        eventType: json['eventType'] as String,
        source: json['source'] as String,
        receivedAt: json['receivedAt'] as String,
      );

  final String eventId;
  final String eventType;
  final String source;
  final String receivedAt;
}
