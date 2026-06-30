class PatientModel {
  const PatientModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.bloodType,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.emergencyContact,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) => PatientModel(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        bloodType: json['bloodType'] as String?,
        gender: json['gender'] as String?,
        dateOfBirth: json['dateOfBirth'] as String?,
        address: json['address'] as String?,
        emergencyContact: json['emergencyContact'] as String?,
        userId: json['userId'] as String?,
        createdAt: json['createdAt'] as String?,
        updatedAt: json['updatedAt'] as String?,
      );

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? bloodType;
  final String? gender;
  final String? dateOfBirth;
  final String? address;
  final String? emergencyContact;
  final String? userId;
  final String? createdAt;
  final String? updatedAt;

  String get fullName => '$firstName $lastName';
}

class DoctorModel {
  const DoctorModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.specialty,
    this.phone,
    this.licenseNumber,
    this.bio,
    this.active = true,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) => DoctorModel(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        email: json['email'] as String,
        specialty: json['specialty'] as String?,
        phone: json['phone'] as String?,
        licenseNumber: json['licenseNumber'] as String?,
        bio: json['bio'] as String?,
        active: json['active'] as bool? ?? true,
        userId: json['userId'] as String?,
        createdAt: json['createdAt'] as String?,
        updatedAt: json['updatedAt'] as String?,
      );

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? specialty;
  final String? phone;
  final String? licenseNumber;
  final String? bio;
  final bool active;
  final String? userId;
  final String? createdAt;
  final String? updatedAt;

  String get fullName => 'Dr. $firstName $lastName';
}

class RiskAssessmentModel {
  const RiskAssessmentModel({
    required this.id,
    required this.patientId,
    required this.riskScore,
    required this.riskLevel,
    required this.factors,
    required this.recommendation,
    required this.assessedAt,
    this.triggerEventType,
    this.correlationId,
  });

  factory RiskAssessmentModel.fromJson(Map<String, dynamic> json) =>
      RiskAssessmentModel(
        id: json['id'] as String,
        patientId: json['patientId'] as String,
        riskScore: json['riskScore'] as int,
        riskLevel: json['riskLevel'] as String,
        factors: (json['factors'] as List<dynamic>?)?.cast<String>() ?? [],
        recommendation: json['recommendation'] as String? ?? '',
        assessedAt: json['assessedAt'] as String,
        triggerEventType: json['triggerEventType'] as String?,
        correlationId: json['correlationId'] as String?,
      );

  final String id;
  final String patientId;
  final int riskScore;
  final String riskLevel;
  final List<String> factors;
  final String recommendation;
  final String assessedAt;
  final String? triggerEventType;
  final String? correlationId;
}

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.status,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String,
        title: json['title'] as String? ?? 'Notification',
        message: json['message'] as String? ?? '',
        type: json['type'] as String? ?? 'INFO',
        status: json['status'] as String? ?? 'UNREAD',
        createdAt: json['createdAt'] as String? ?? '',
      );

  final String id;
  final String title;
  final String message;
  final String type;
  final String status;
  final String createdAt;
}

class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.scheduledAt,
    required this.status,
    this.patientId,
    this.doctorId,
    this.patientUserId,
    this.doctorUserId,
    this.reason,
    this.notes,
    this.durationMinutes = 30,
    this.createdAt,
    this.updatedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) => AppointmentModel(
        id: json['id'] as String,
        scheduledAt: json['scheduledAt'] as String,
        status: json['status'] as String,
        patientId: json['patientId'] as String?,
        doctorId: json['doctorId'] as String?,
        patientUserId: json['patientUserId'] as String?,
        doctorUserId: json['doctorUserId'] as String?,
        reason: json['reason'] as String?,
        notes: json['notes'] as String?,
        durationMinutes: json['durationMinutes'] as int? ?? 30,
        createdAt: json['createdAt'] as String?,
        updatedAt: json['updatedAt'] as String?,
      );

  final String id;
  final String scheduledAt;
  final String status;
  final String? patientId;
  final String? doctorId;
  final String? patientUserId;
  final String? doctorUserId;
  final String? reason;
  final String? notes;
  final int durationMinutes;
  final String? createdAt;
  final String? updatedAt;
}
