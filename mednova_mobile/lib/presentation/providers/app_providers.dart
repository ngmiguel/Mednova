import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';
import '../../data/models/patient_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/mednova_repository_impl.dart';
import '../../domain/repositories/mednova_repositories.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(apiClientProvider), ref.watch(tokenStorageProvider)),
);

final patientRepositoryProvider = Provider<PatientRepository>(
  (ref) => PatientRepositoryImpl(ref.watch(apiClientProvider)),
);

final doctorRepositoryProvider = Provider<DoctorRepository>(
  (ref) => DoctorRepositoryImpl(ref.watch(apiClientProvider)),
);

final aiRepositoryProvider = Provider<AiRepository>(
  (ref) => AiRepositoryImpl(ref.watch(apiClientProvider)),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(ref.watch(apiClientProvider)),
);

final appointmentRepositoryProvider = Provider<AppointmentRepository>(
  (ref) => AppointmentRepositoryImpl(ref.watch(apiClientProvider)),
);

final userAdminRepositoryProvider = Provider<UserAdminRepository>(
  (ref) => UserAdminRepositoryImpl(ref.watch(apiClientProvider)),
);

final auditRepositoryProvider = Provider<AuditRepository>(
  (ref) => AuditRepositoryImpl(ref.watch(apiClientProvider)),
);

final messagingRepositoryProvider = Provider<MessagingRepository>(
  (ref) => MessagingRepositoryImpl(ref.watch(apiClientProvider)),
);

final patientsProvider = FutureProvider.autoDispose((ref) async {
  return ref.watch(patientRepositoryProvider).list();
});

final doctorsProvider = FutureProvider.autoDispose((ref) async {
  return ref.watch(doctorRepositoryProvider).list();
});

final appointmentsProvider = FutureProvider.autoDispose((ref) async {
  return ref.watch(appointmentRepositoryProvider).list();
});

final notificationsProvider = FutureProvider.autoDispose((ref) async {
  return ref.watch(notificationRepositoryProvider).list();
});

final auditEventsProvider = FutureProvider.autoDispose((ref) async {
  return ref.watch(auditRepositoryProvider).list();
});

final riskAssessmentsProvider = FutureProvider.autoDispose
    .family<List<RiskAssessmentModel>, String>((ref, patientId) async {
  return ref.watch(aiRepositoryProvider).listByPatient(patientId);
});
