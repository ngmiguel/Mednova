import '../../core/config/app_settings.dart';

class AppStrings {
  AppStrings(this.language);

  final AppLanguage language;

  bool get isFr => language == AppLanguage.fr;

  String get settingsTitle => isFr ? 'Paramètres' : 'Settings';
  String get settingsSubtitle =>
      isFr ? 'Préférences, session et administration' : 'Preferences, session and admin';
  String get profile => isFr ? 'Profil' : 'Profile';
  String get appearance => isFr ? 'Apparence' : 'Appearance';
  String get sessionSecurity => isFr ? 'Session & sécurité' : 'Session & security';
  String get notifications => isFr ? 'Notifications' : 'Notifications';
  String get dataSync => isFr ? 'Données & synchronisation' : 'Data & sync';
  String get adminSection => isFr ? 'Administration système' : 'System administration';
  String get save => isFr ? 'Enregistrer' : 'Save';
  String get reset => isFr ? 'Réinitialiser' : 'Reset';
  String get saved => isFr ? 'Paramètres enregistrés' : 'Settings saved';
  String get logout => isFr ? 'Déconnexion' : 'Log out';
  String get demoMode => isFr ? 'Mode démo (sans backend)' : 'Demo mode (no backend)';
  String get demoModeHint =>
      isFr ? 'Données locales — aucune API requise' : 'Local data — no API required';
  String get staySignedIn => isFr ? 'Rester connecté' : 'Stay signed in';
  String get rememberEmail => isFr ? 'Mémoriser l\'email' : 'Remember email';
  String get animations => isFr ? 'Animations 3D' : '3D animations';
  String get compactNav => isFr ? 'Navigation compacte' : 'Compact navigation';
  String get inAppNotif => isFr ? 'Notifications in-app' : 'In-app notifications';
  String get emailNotif => isFr ? 'Notifications email' : 'Email notifications';
  String get themeLight => isFr ? 'Clair' : 'Light';
  String get themeDark => isFr ? 'Sombre' : 'Dark';
  String get themeSystem => isFr ? 'Système' : 'System';
  String get densityComfortable => isFr ? 'Confortable' : 'Comfortable';
  String get densityCompact => isFr ? 'Compacte' : 'Compact';
  String get refreshStats => isFr ? 'Rafraîchir les compteurs' : 'Refresh counters';
  String get openNotifications => isFr ? 'Centre de notifications' : 'Notification center';
  String get gateway => 'API Gateway';
  String get checkGateway => isFr ? 'Vérifier la gateway' : 'Check gateway';
  String get nurses => isFr ? 'Infirmier(ère)s' : 'Nurses';
  String get languageLabel => isFr ? 'Langue' : 'Language';
  String get french => 'Français';
  String get english => 'English';
}
