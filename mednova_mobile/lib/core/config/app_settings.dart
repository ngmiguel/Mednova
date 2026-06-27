enum ThemeMode { light, dark, system }

enum UiDensity { comfortable, compact }

enum AppLanguage { fr, en }

class AppSettings {
  const AppSettings({
    this.animationsEnabled = true,
    this.compactNav = false,
    this.emailNotifications = true,
    this.inAppNotifications = true,
    this.staySignedIn = true,
    this.rememberEmail = true,
    this.language = AppLanguage.fr,
    this.theme = ThemeMode.dark,
    this.density = UiDensity.comfortable,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        animationsEnabled: json['animationsEnabled'] as bool? ?? true,
        compactNav: json['compactNav'] as bool? ?? false,
        emailNotifications: json['emailNotifications'] as bool? ?? true,
        inAppNotifications: json['inAppNotifications'] as bool? ?? true,
        staySignedIn: json['staySignedIn'] as bool? ?? true,
        rememberEmail: json['rememberEmail'] as bool? ?? true,
        language: AppLanguage.values.byName(json['language'] as String? ?? 'fr'),
        theme: ThemeMode.values.byName(json['theme'] as String? ?? 'dark'),
        density: UiDensity.values.byName(json['density'] as String? ?? 'comfortable'),
      );

  final bool animationsEnabled;
  final bool compactNav;
  final bool emailNotifications;
  final bool inAppNotifications;
  final bool staySignedIn;
  final bool rememberEmail;
  final AppLanguage language;
  final ThemeMode theme;
  final UiDensity density;

  AppSettings copyWith({
    bool? animationsEnabled,
    bool? compactNav,
    bool? emailNotifications,
    bool? inAppNotifications,
    bool? staySignedIn,
    bool? rememberEmail,
    AppLanguage? language,
    ThemeMode? theme,
    UiDensity? density,
  }) {
    return AppSettings(
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      compactNav: compactNav ?? this.compactNav,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      inAppNotifications: inAppNotifications ?? this.inAppNotifications,
      staySignedIn: staySignedIn ?? this.staySignedIn,
      rememberEmail: rememberEmail ?? this.rememberEmail,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      density: density ?? this.density,
    );
  }

  Map<String, dynamic> toJson() => {
        'animationsEnabled': animationsEnabled,
        'compactNav': compactNav,
        'emailNotifications': emailNotifications,
        'inAppNotifications': inAppNotifications,
        'staySignedIn': staySignedIn,
        'rememberEmail': rememberEmail,
        'language': language.name,
        'theme': theme.name,
        'density': density.name,
      };

  static const defaults = AppSettings();
}
