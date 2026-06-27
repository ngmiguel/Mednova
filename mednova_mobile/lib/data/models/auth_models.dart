import '../../core/config/app_config.dart';

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.roles = const [],
    this.requiresTwoFactor = false,
    this.challengeToken,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        roles: (json['roles'] as List<dynamic>?)?.cast<String>() ?? [],
        requiresTwoFactor: json['requiresTwoFactor'] as bool? ?? false,
        challengeToken: json['challengeToken'] as String?,
      );

  final String accessToken;
  final String refreshToken;
  final List<String> roles;
  final bool requiresTwoFactor;
  final String? challengeToken;
}

class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roles,
    this.twoFactorEnabled = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        email: json['email'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        roles: (json['roles'] as List<dynamic>?)?.cast<String>() ?? [],
        twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      );

  factory UserProfile.fromStorage(Map<String, dynamic> json) => UserProfile.fromJson(json);

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final List<String> roles;
  final bool twoFactorEnabled;

  String get fullName => '$firstName $lastName';

  List<UserRole> get parsedRoles =>
      roles.map(UserRole.fromString).whereType<UserRole>().toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'roles': roles,
        'twoFactorEnabled': twoFactorEnabled,
      };
}

class DemoAccount {
  const DemoAccount({
    required this.label,
    required this.email,
    required this.password,
    required this.role,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.twoFactorEnabled = false,
  });

  final String label;
  final String email;
  final String password;
  final UserRole role;
  final String userId;
  final String firstName;
  final String lastName;
  final bool twoFactorEnabled;
}

const demoAccounts = [
  DemoAccount(
    label: 'Admin',
    email: 'admin@mednova.ai',
    password: 'password123',
    role: UserRole.admin,
    userId: 'user-admin',
    firstName: 'Alice',
    lastName: 'Admin',
    twoFactorEnabled: true,
  ),
  DemoAccount(
    label: 'Médecin',
    email: 'dr.smith@mednova.ai',
    password: 'password123',
    role: UserRole.doctor,
    userId: 'user-doctor',
    firstName: 'John',
    lastName: 'Smith',
  ),
  DemoAccount(
    label: 'Infirmier',
    email: 'nurse@mednova.ai',
    password: 'password123',
    role: UserRole.nurse,
    userId: 'user-nurse',
    firstName: 'Emma',
    lastName: 'Wilson',
  ),
  DemoAccount(
    label: 'Patient',
    email: 'patient.test@mednova.ai',
    password: 'password123',
    role: UserRole.patient,
    userId: 'user-patient',
    firstName: 'Marie',
    lastName: 'Dupont',
  ),
  DemoAccount(
    label: 'Auditeur',
    email: 'auditor@mednova.ai',
    password: 'password123',
    role: UserRole.auditor,
    userId: 'user-auditor',
    firstName: 'Paul',
    lastName: 'Audit',
    twoFactorEnabled: true,
  ),
];
