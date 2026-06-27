import { Component, inject, OnInit } from '@angular/core';
import { RouterLink } from '@angular/router';
import { MODULE_ROLES } from '../../core/config/module-roles';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { AuthService } from '../../core/services/auth.service';
import { NavStatsService } from '../../core/services/nav-stats.service';
import { TokenStorageService } from '../../core/services/token-storage.service';
import { AppIconComponent, AppIconName } from '../../shared/components/app-icon/app-icon.component';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [RouterLink, AppIconComponent, TranslatePipe],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss',
})
export class DashboardComponent implements OnInit {
  readonly authService = inject(AuthService);
  readonly navStats = inject(NavStatsService);
  readonly tokenStorage = inject(TokenStorageService);
  readonly i18n = inject(I18nService);

  readonly modules: {
    icon: AppIconName;
    titleKey: string;
    descKey: string;
    link: string;
    color: string;
    roles?: string[];
  }[] = [
    {
      icon: 'patients',
      titleKey: 'module.patients.title',
      descKey: 'module.patients.desc',
      link: '/patients',
      color: '#0d9488',
      roles: [...MODULE_ROLES.patients],
    },
    {
      icon: 'doctors',
      titleKey: 'module.doctors.title',
      descKey: 'module.doctors.desc',
      link: '/doctors',
      color: '#6366f1',
      roles: [...MODULE_ROLES.doctors],
    },
    {
      icon: 'appointments',
      titleKey: 'module.appointments.title',
      descKey: 'module.appointments.desc',
      link: '/appointments',
      color: '#8b5cf6',
      roles: [...MODULE_ROLES.appointments],
    },
    {
      icon: 'monitoring',
      titleKey: 'module.monitoring.title',
      descKey: 'module.monitoring.desc',
      link: '/appointments',
      color: '#f59e0b',
      roles: [...MODULE_ROLES.monitoring],
    },
    {
      icon: 'ai',
      titleKey: 'module.ai.title',
      descKey: 'module.ai.desc',
      link: '/ai',
      color: '#ec4899',
      roles: [...MODULE_ROLES.ai],
    },
    {
      icon: 'messages',
      titleKey: 'module.messages.title',
      descKey: 'module.messages.desc',
      link: '/messaging',
      color: '#0ea5e9',
      roles: [...MODULE_ROLES.messaging],
    },
    {
      icon: 'audit',
      titleKey: 'module.audit.title',
      descKey: 'module.audit.desc',
      link: '/audit',
      color: '#64748b',
      roles: [...MODULE_ROLES.audit],
    },
    {
      icon: 'notifications',
      titleKey: 'module.notifications.title',
      descKey: 'module.notifications.desc',
      link: '/notifications',
      color: '#ef4444',
      roles: [...MODULE_ROLES.notifications],
    },
    {
      icon: 'settings',
      titleKey: 'module.settings.title',
      descKey: 'module.settings.desc',
      link: '/settings',
      color: '#475569',
    },
  ];

  ngOnInit(): void {
    if (!this.authService.currentUser()) {
      this.authService.loadProfile().subscribe();
    }
    if (!this.navStats.lastUpdated()) {
      this.navStats.refresh();
    }
  }

  canSee(roles?: string[]): boolean {
    if (!roles) return true;
    return roles.some((r) => this.tokenStorage.hasRole(r));
  }

  roleLabel(): string {
    const map: Record<string, string> = {
      ROLE_ADMIN: 'role.admin',
      ROLE_DOCTOR: 'role.doctor',
      ROLE_NURSE: 'role.nurse',
      ROLE_PATIENT: 'role.patient',
      ROLE_AUDITOR: 'role.auditor',
    };
    const roles = this.tokenStorage.getRoles();
    const key = map[roles[0] ?? ''];
    return key ? this.i18n.t(key) : 'Utilisateur MedNova';
  }
}
