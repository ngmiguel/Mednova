import 'dart:io';

import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const appName = 'MedNova AI';

  /// Gateway API — Android emulator uses 10.0.2.2 for host localhost.
  static String get apiBaseUrl {
    if (kIsWeb) return 'http://localhost:8080/api/v1';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080/api/v1';
    return 'http://localhost:8080/api/v1';
  }
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
