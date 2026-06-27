import 'dart:io';

import 'package:flutter/foundation.dart';

/// Runtime platform detection and environment-specific configuration.
enum AppPlatform { web, android, ios, desktop, unknown }

class PlatformConfig {
  PlatformConfig._();

  /// Override at build time: `--dart-define=API_BASE_URL=http://192.168.1.10:8080/api/v1`
  static const apiBaseUrlEnv = String.fromEnvironment('API_BASE_URL');

  /// `dev` | `prod` — `--dart-define=APP_ENV=prod`
  static const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  static AppPlatform get current {
    if (kIsWeb) return AppPlatform.web;
    if (Platform.isAndroid) return AppPlatform.android;
    if (Platform.isIOS) return AppPlatform.ios;
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return AppPlatform.desktop;
    }
    return AppPlatform.unknown;
  }

  static bool get isAndroid => current == AppPlatform.android;
  static bool get isIOS => current == AppPlatform.ios;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDev => appEnv == 'dev';

  static String get platformLabel => switch (current) {
        AppPlatform.android => 'Android',
        AppPlatform.ios => 'iOS',
        AppPlatform.web => 'Web',
        AppPlatform.desktop => 'Desktop',
        AppPlatform.unknown => 'Unknown',
      };

  /// Resolves the MedNova Gateway base URL for the current runtime.
  static String get apiBaseUrl {
    if (apiBaseUrlEnv.isNotEmpty) return apiBaseUrlEnv;

    return switch (current) {
      // Android emulator maps host localhost to 10.0.2.2
      AppPlatform.android => 'http://10.0.2.2:8080/api/v1',
      // iOS simulator shares host network stack
      AppPlatform.ios => 'http://localhost:8080/api/v1',
      AppPlatform.web => 'http://localhost:8080/api/v1',
      AppPlatform.desktop => 'http://localhost:8080/api/v1',
      AppPlatform.unknown => 'http://localhost:8080/api/v1',
    };
  }
}
