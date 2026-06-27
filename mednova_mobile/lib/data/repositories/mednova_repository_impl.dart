import 'package:dio/dio.dart';

import '../../core/network/api_response.dart';
import '../../domain/repositories/mednova_repositories.dart';
import '../models/messaging_models.dart';
import '../models/patient_model.dart';
import '../models/user_admin_model.dart';

class PatientRepositoryImpl implements PatientRepository {
  PatientRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<PatientModel>> list({int size = 50}) async {
    final response = await _dio.get<Map<String, dynamic>>('/patients', queryParameters: {'size': size});
    final api = ApiResponse.fromJson(response.data!, (d) => d);
    final page = PageResponse.fromJson(
      api.data! as Map<String, dynamic>,
      PatientModel.fromJson,
    );
    return page.content;
  }

  @override
  Future<PatientModel> getById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/patients/$id');
    final api = ApiResponse.fromJson(
      response.data!,
      (d) => PatientModel.fromJson(d! as Map<String, dynamic>),
    );
    return api.data!;
  }
}

class DoctorRepositoryImpl implements DoctorRepository {
  DoctorRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<DoctorModel>> list({int size = 50}) async {
    final response = await _dio.get<Map<String, dynamic>>('/doctors', queryParameters: {'size': size});
    final api = ApiResponse.fromJson(response.data!, (d) => d);
    final page = PageResponse.fromJson(
      api.data! as Map<String, dynamic>,
      DoctorModel.fromJson,
    );
    return page.content;
  }

  @override
  Future<DoctorModel> getById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/doctors/$id');
    final api = ApiResponse.fromJson(
      response.data!,
      (d) => DoctorModel.fromJson(d! as Map<String, dynamic>),
    );
    return api.data!;
  }
}

class AiRepositoryImpl implements AiRepository {
  AiRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<RiskAssessmentModel>> listByPatient(String patientId, {int size = 50}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/ai/patients/$patientId/risk-assessments',
      queryParameters: {'size': size},
    );
    final api = ApiResponse.fromJson(response.data!, (d) => d);
    final page = PageResponse.fromJson(
      api.data! as Map<String, dynamic>,
      RiskAssessmentModel.fromJson,
    );
    return page.content;
  }
}

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<NotificationModel>> list({int size = 50}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/notifications',
      queryParameters: {'size': size},
    );
    final api = ApiResponse.fromJson(response.data!, (d) => d);
    final page = PageResponse.fromJson(
      api.data! as Map<String, dynamic>,
      NotificationModel.fromJson,
    );
    return page.content;
  }
}

class AppointmentRepositoryImpl implements AppointmentRepository {
  AppointmentRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<AppointmentModel>> list({int size = 50}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/appointments',
      queryParameters: {'size': size},
    );
    final api = ApiResponse.fromJson(response.data!, (d) => d);
    final page = PageResponse.fromJson(
      api.data! as Map<String, dynamic>,
      AppointmentModel.fromJson,
    );
    return page.content;
  }
}

class UserAdminRepositoryImpl implements UserAdminRepository {
  UserAdminRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<UserAccountModel> getById(String userId) async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/users/$userId');
    final api = ApiResponse.fromJson(
      response.data!,
      (d) => UserAccountModel.fromJson(d! as Map<String, dynamic>),
    );
    return api.data!;
  }

  @override
  Future<UserAccountModel> setAccess(String userId, bool enabled) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/auth/users/$userId/access',
      data: {'enabled': enabled},
    );
    final api = ApiResponse.fromJson(
      response.data!,
      (d) => UserAccountModel.fromJson(d! as Map<String, dynamic>),
    );
    return api.data!;
  }
}

class AuditRepositoryImpl implements AuditRepository {
  AuditRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<AuditEventModel>> list({int size = 50}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/audit/events',
      queryParameters: {'size': size},
    );
    final api = ApiResponse.fromJson(response.data!, (d) => d);
    final page = PageResponse.fromJson(
      api.data! as Map<String, dynamic>,
      AuditEventModel.fromJson,
    );
    return page.content;
  }
}

class MessagingRepositoryImpl implements MessagingRepository {
  MessagingRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<ConversationModel>> listConversations() async {
    final response = await _dio.get<Map<String, dynamic>>('/messaging/conversations');
    final api = ApiResponse.fromJson(response.data!, (d) => d);
    final raw = api.data as List<dynamic>? ?? [];
    return raw.whereType<Map<String, dynamic>>().map(ConversationModel.fromJson).toList();
  }

  @override
  Future<ConversationModel> createConversation({
    required String patientUserId,
    required String doctorUserId,
    String? patientId,
    String? doctorId,
    String? subject,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/messaging/conversations',
      data: {
        'patientUserId': patientUserId,
        'doctorUserId': doctorUserId,
        if (patientId != null) 'patientId': patientId,
        if (doctorId != null) 'doctorId': doctorId,
        if (subject != null) 'subject': subject,
      },
    );
    final api = ApiResponse.fromJson(
      response.data!,
      (d) => ConversationModel.fromJson(d! as Map<String, dynamic>),
    );
    return api.data!;
  }

  @override
  Future<List<ChatMessageModel>> listMessages(String conversationId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/messaging/conversations/$conversationId/messages',
    );
    final api = ApiResponse.fromJson(response.data!, (d) => d);
    final raw = api.data as List<dynamic>? ?? [];
    return raw.whereType<Map<String, dynamic>>().map(ChatMessageModel.fromJson).toList();
  }

  @override
  Future<ChatMessageModel> sendMessage(String conversationId, String content) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/messaging/conversations/$conversationId/messages',
      data: {'content': content},
    );
    final api = ApiResponse.fromJson(
      response.data!,
      (d) => ChatMessageModel.fromJson(d! as Map<String, dynamic>),
    );
    return api.data!;
  }

  @override
  Future<void> markRead(String conversationId) async {
    await _dio.patch('/messaging/conversations/$conversationId/read', data: {});
  }
}
