class UserAccountModel {
  const UserAccountModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.enabled,
    required this.twoFactorEnabled,
    required this.roles,
    this.createdAt,
  });

  factory UserAccountModel.fromJson(Map<String, dynamic> json) => UserAccountModel(
        id: json['id'] as String,
        email: json['email'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        enabled: json['enabled'] as bool? ?? true,
        twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
        roles: (json['roles'] as List<dynamic>?)?.cast<String>() ?? [],
        createdAt: json['createdAt'] as String?,
      );

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool enabled;
  final bool twoFactorEnabled;
  final List<String> roles;
  final String? createdAt;

  String get fullName => '$firstName $lastName';
}
