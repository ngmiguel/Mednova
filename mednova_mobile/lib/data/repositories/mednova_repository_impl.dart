import 'package:dio/dio.dart';

import '../../core/network/api_response.dart';
import '../../domain/repositories/mednova_repositories.dart';
import '../demo/demo_catalog.dart';
import '../models/messaging_models.dart';
import '../models/patient_model.dart';
import '../models/user_admin_model.dart';

typedef IsDemoFn = bool Function();

class PatientRepositoryImpl implements PatientRepository {
  PatientRepositoryImpl(this._dio, this._isDemo);
  final Dio _dio;
  final IsDemoFn _isDemo;

  @override
  Future<List<PatientModel>> list({int size = 50}) async {
    if (_isDemo()) return DemoCatalog.patients;
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
    if (_isDemo()) {
      final p = DemoCatalog.patientById(id);
      if (p == null) throw Exception('Patient introuvable');
      return p;
    }
    final response = await _dio.get<Map<String, dynamic>>('/patients/$id');
    final api = ApiResponse.fromJson(
      response.data!,
      (d) => PatientModel.fromJson(d! as Map<String, dynamic>),
    );
    return api.data!;
  }
}

class DoctorRepositoryImpl implements DoctorRepository {
  DoctorRepositoryImpl(this._dio, this._isDemo);
  final Dio _dio;
  final IsDemoFn _isDemo;

  @override
  Future<List<DoctorModel>> list({int size = 50}) async {
    if (_isDemo()) return DemoCatalog.doctors;
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
    if (_isDemo()) {
      final d = DemoCatalog.doctorById(id);
      if (d == null) throw Exception('Médecin introuvable');
      return d;
    }
    final response = await _dio.get<Map<String, dynamic>>('/doctors/$id');
    final api = ApiResponse.fromJson(
      response.data!,
      (d) => DoctorModel.fromJson(d! as Map<String, dynamic>),
    );
    return api.data!;
  }
}

class AiRepositoryImpl implements AiRepository {
  AiRepositoryImpl(this._dio, this._isDemo);
  final Dio _dio;
  final IsDemoFn _isDemo;

  @override
  Future<List<RiskAssessmentModel>> listByPatient(String patientId, {int size = 50}) async {
    if (_isDemo()) return DemoCatalog.risksForPatient(patientId);
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
  NotificationRepositoryImpl(this._dio, this._isDemo);
  final Dio _dio;
  final IsDemoFn _isDemo;

  @override
  Future<List<NotificationModel>> list({int size = 50}) async {
    if (_isDemo()) return DemoCatalog.notifications;
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
  AppointmentRepositoryImpl(this._dio, this._isDemo);
  final Dio _dio;
  final IsDemoFn _isDemo;

  @override
  Future<List<AppointmentModel>> list({int size = 50}) async {
    if (_isDemo()) return DemoCatalog.appointments;
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
  UserAdminRepositoryImpl(this._dio, this._isDemo);
  final Dio _dio;
  final IsDemoFn _isDemo;

  @override
  Future<UserAccountModel> getById(String userId) async {
    if (_isDemo()) {
      final a = DemoCatalog.accountById(userId);
      if (a == null) throw Exception('Compte introuvable');
      return a;
    }
    final response = await _dio.get<Map<String, dynamic>>('/auth/users/$userId');
    final api = ApiResponse.fromJson(
      response.data!,
      (d) => UserAccountModel.fromJson(d! as Map<String, dynamic>),
    );
    return api.data!;
  }

  @override
  Future<UserAccountModel> setAccess(String userId, bool enabled) async {
    if (_isDemo()) return DemoCatalog.setAccountAccess(userId, enabled);
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

  Future<List<UserAccountModel>> listNurses() async {
    if (_isDemo()) return DemoCatalog.nurses;
    throw UnimplementedError('API list nurses not exposed');
  }
}

class AuditRepositoryImpl implements AuditRepository {
  AuditRepositoryImpl(this._dio, this._isDemo);
  final Dio _dio;
  final IsDemoFn _isDemo;

  @override
  Future<List<AuditEventModel>> list({int size = 50}) async {
    if (_isDemo()) return DemoCatalog.auditEvents;
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
  MessagingRepositoryImpl(this._dio, this._isDemo);
  final Dio _dio;
  final IsDemoFn _isDemo;

  @override
  Future<List<ConversationModel>> listConversations() async {
    if (_isDemo()) return DemoCatalog.allConversations;
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
    if (_isDemo()) {
      return DemoCatalog.createConversation(
        patientUserId: patientUserId,
        doctorUserId: doctorUserId,
        patientId: patientId,
        doctorId: doctorId,
      );
    }
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
    if (_isDemo()) return DemoCatalog.messagesFor(conversationId);
    final response = await _dio.get<Map<String, dynamic>>(
      '/messaging/conversations/$conversationId/messages',
    );
    final api = ApiResponse.fromJson(response.data!, (d) => d);
    final raw = api.data as List<dynamic>? ?? [];
    return raw.whereType<Map<String, dynamic>>().map(ChatMessageModel.fromJson).toList();
  }

  @override
  Future<ChatMessageModel> sendMessage(String conversationId, String content) async {
    if (_isDemo()) {
      return DemoCatalog.addMessage(conversationId, 'demo-sender', content);
    }
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
    if (_isDemo()) return;
    await _dio.patch('/messaging/conversations/$conversationId/read', data: {});
  }
}
