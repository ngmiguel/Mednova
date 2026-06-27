import 'platform_config.dart';

class AppConfig {
  AppConfig._();

  static const appName = 'MedNova AI';

  /// Gateway API — resolved per platform (see [PlatformConfig]).
  static String get apiBaseUrl => PlatformConfig.apiBaseUrl;

  static String get appEnv => PlatformConfig.appEnv;
  static String get platformLabel => PlatformConfig.platformLabel;
}

enum UserRole {
  admin('ROLE_ADMIN'),
  doctor('ROLE_DOCTOR'),
  nurse('ROLE_NURSE'),
  patient('ROLE_PATIENT'),
  auditor('ROLE_AUDITOR');

  const UserRole(this.value);
  final String value;

  static UserRole? fromString(String raw) {
    for (final role in UserRole.values) {
      if (role.value == raw) return role;
    }
    return null;
  }
}

enum AppModule {
  dashboard,
  patients,
  doctors,
  appointments,
  messaging,
  ai,
  notifications,
  audit,
  settings,
}

class ModuleRoles {
  ModuleRoles._();

  static const patients = [
    UserRole.admin,
    UserRole.doctor,
    UserRole.nurse,
    UserRole.auditor,
  ];
  static const doctors = UserRole.values;
  static const appointments = UserRole.values;
  static const messaging = [UserRole.doctor, UserRole.patient];
  static const ai = UserRole.values;
  static const notifications = UserRole.values;
  static const audit = [UserRole.admin, UserRole.auditor];
  static const settings = UserRole.values;

  static List<UserRole> rolesFor(AppModule module) => switch (module) {
        AppModule.dashboard => settings,
        AppModule.patients => patients,
        AppModule.doctors => doctors,
        AppModule.appointments => appointments,
        AppModule.messaging => messaging,
        AppModule.ai => ai,
        AppModule.notifications => notifications,
        AppModule.audit => audit,
        AppModule.settings => settings,
      };

  static bool canAccess(AppModule module, List<UserRole> userRoles) {
    final allowed = rolesFor(module);
    return userRoles.any(allowed.contains);
  }
}
