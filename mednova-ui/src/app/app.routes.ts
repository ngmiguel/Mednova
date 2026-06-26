import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';
import { roleGuard } from './core/guards/role.guard';

export const routes: Routes = [
  { path: '', pathMatch: 'full', redirectTo: 'dashboard' },
  {
    path: 'auth/login',
    loadComponent: () =>
      import('./features/auth/auth-page/auth-page.component').then((m) => m.AuthPageComponent),
  },
  {
    path: '',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./layout/main-layout/main-layout.component').then((m) => m.MainLayoutComponent),
    children: [
      {
        path: 'dashboard',
        loadComponent: () =>
          import('./features/dashboard/dashboard.component').then((m) => m.DashboardComponent),
      },
      {
        path: 'patients',
        canActivate: [roleGuard(['ROLE_ADMIN', 'ROLE_DOCTOR', 'ROLE_NURSE', 'ROLE_AUDITOR'])],
        loadComponent: () =>
          import('./features/patients/patient-list/patient-list.component').then(
            (m) => m.PatientListComponent
          ),
      },
      {
        path: 'doctors',
        canActivate: [roleGuard(['ROLE_ADMIN', 'ROLE_DOCTOR', 'ROLE_NURSE', 'ROLE_AUDITOR'])],
        loadComponent: () =>
          import('./features/doctors/doctor-list/doctor-list.component').then(
            (m) => m.DoctorListComponent
          ),
      },
      {
        path: 'appointments',
        loadComponent: () =>
          import('./features/appointments/appointment-list/appointment-list.component').then(
            (m) => m.AppointmentListComponent
          ),
      },
      {
        path: 'notifications',
        loadComponent: () =>
          import('./features/notifications/notification-list/notification-list.component').then(
            (m) => m.NotificationListComponent
          ),
      },
      {
        path: 'messaging',
        canActivate: [roleGuard(['ROLE_DOCTOR', 'ROLE_PATIENT'])],
        loadComponent: () =>
          import('./features/messaging/messaging.component').then((m) => m.MessagingComponent),
      },
      {
        path: 'ai',
        loadComponent: () =>
          import('./features/ai/ai-predictions.component').then((m) => m.AiPredictionsComponent),
      },
      {
        path: 'audit',
        canActivate: [roleGuard(['ROLE_ADMIN', 'ROLE_AUDITOR'])],
        loadComponent: () =>
          import('./features/audit/audit-list/audit-list.component').then(
            (m) => m.AuditListComponent
          ),
      },
      {
        path: 'settings',
        loadComponent: () =>
          import('./features/settings/settings.component').then((m) => m.SettingsComponent),
      },
    ],
  },
  { path: '**', redirectTo: 'dashboard' },
];
