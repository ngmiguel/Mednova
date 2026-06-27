import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../providers/auth_notifier.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/patients/patients_screen.dart';
import '../features/doctors/doctors_screen.dart';
import '../features/appointments/appointments_screen.dart';
import '../features/ai/ai_screen.dart';
import '../features/messaging/messaging_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/audit/audit_screen.dart';
import '../features/settings/settings_screen.dart';
import '../shell/mednova_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _AuthRefreshListenable(ref),
    redirect: (context, state) {
      final auth = authListenable.valueOrNull;
      final loading = authListenable.isLoading;
      final onLogin = state.matchedLocation == '/login';

      if (loading) return null;
      if (auth?.isAuthenticated != true && !onLogin) return '/login';
      if (auth?.isAuthenticated == true && onLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MedNovaShell(navigationShell: navigationShell),
        branches: [
          _branch('/dashboard', const DashboardScreen()),
          _branch('/patients', const PatientsScreen(), AppModule.patients),
          _branch('/doctors', const DoctorsScreen(), AppModule.doctors),
          _branch('/appointments', const AppointmentsScreen(), AppModule.appointments),
          _branch('/ai', const AiScreen(), AppModule.ai),
          _branch('/messaging', const MessagingScreen(), AppModule.messaging),
          _branch('/notifications', const NotificationsScreen(), AppModule.notifications),
          _branch('/audit', const AuditScreen(), AppModule.audit),
          _branch('/settings', const SettingsScreen(), AppModule.settings),
        ],
      ),
    ],
  );
});

StatefulShellBranch _branch(String path, Widget screen, [AppModule? module]) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        redirect: module == null
            ? null
            : (context, state) {
                final container = ProviderScope.containerOf(context);
                final auth = container.read(authProvider).valueOrNull;
                if (auth == null) return '/login';
                if (!auth.canAccess(module)) return '/dashboard';
                return null;
              },
        builder: (_, __) => screen,
      ),
    ],
  );
}

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this.ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
  final Ref ref;
}
