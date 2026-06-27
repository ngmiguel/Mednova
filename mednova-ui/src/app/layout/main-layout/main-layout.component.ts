import { Component, inject, OnInit } from '@angular/core';

import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';

import { MODULE_ROLES } from '../../core/config/module-roles';

import { I18nService } from '../../core/i18n/i18n.service';

import { TranslatePipe } from '../../core/i18n/translate.pipe';

import { AuthService } from '../../core/services/auth.service';

import { NavStatsService } from '../../core/services/nav-stats.service';

import { NotificationService } from '../../core/services/notification.service';

import { SettingsService } from '../../core/services/settings.service';

import { TokenStorageService } from '../../core/services/token-storage.service';

import { AppIconComponent, AppIconName } from '../../shared/components/app-icon/app-icon.component';
import { PersonDetailModalComponent } from '../../shared/components/person-detail-modal/person-detail-modal.component';

interface NavItem {
  path: string;

  labelKey: string;

  icon: AppIconName;

  countKey?: keyof import('../../core/services/nav-stats.service').NavCounts;

  badgeKey?: 'notifications';

  roles?: string[];

}



@Component({

  selector: 'app-main-layout',

  standalone: true,

  imports: [RouterOutlet, RouterLink, RouterLinkActive, AppIconComponent, TranslatePipe, PersonDetailModalComponent],

  templateUrl: './main-layout.component.html',

  styleUrl: './main-layout.component.scss',

})

export class MainLayoutComponent implements OnInit {

  readonly authService = inject(AuthService);

  readonly navStats = inject(NavStatsService);

  readonly notificationService = inject(NotificationService);

  readonly settingsService = inject(SettingsService);

  readonly i18n = inject(I18nService);

  private readonly tokenStorage = inject(TokenStorageService);



  readonly mainNav: NavItem[] = [

    { path: '/dashboard', labelKey: 'nav.dashboard', icon: 'dashboard' },

    {

      path: '/patients',

      labelKey: 'nav.patients',

      icon: 'patients',

      countKey: 'patients',

      roles: [...MODULE_ROLES.patients],

    },

    {

      path: '/doctors',

      labelKey: 'nav.doctors',

      icon: 'doctors',

      countKey: 'doctors',

      roles: [...MODULE_ROLES.doctors],

    },

    {

      path: '/appointments',

      labelKey: 'nav.appointments',

      icon: 'appointments',

      countKey: 'appointments',

      roles: [...MODULE_ROLES.appointments],

    },

    {

      path: '/messaging',

      labelKey: 'nav.messaging',

      icon: 'messages',

      roles: [...MODULE_ROLES.messaging],

    },

    {

      path: '/ai',

      labelKey: 'nav.ai',

      icon: 'ai',

      roles: [...MODULE_ROLES.ai],

    },

    {

      path: '/notifications',

      labelKey: 'nav.notifications',

      icon: 'notifications',

      badgeKey: 'notifications',

      roles: [...MODULE_ROLES.notifications],

    },

    {

      path: '/audit',

      labelKey: 'nav.audit',

      icon: 'audit',

      countKey: 'auditEvents',

      roles: [...MODULE_ROLES.audit],

    },

  ];



  readonly settingsNav: NavItem[] = [

    { path: '/settings', labelKey: 'nav.settings', icon: 'settings' },

  ];



  readonly adminNav: NavItem[] = [

    { path: '/patients', labelKey: 'nav.patients', icon: 'patients', roles: ['ROLE_ADMIN'] },

    { path: '/doctors', labelKey: 'nav.doctors', icon: 'doctors', roles: ['ROLE_ADMIN'] },

    { path: '/audit', labelKey: 'nav.audit', icon: 'audit', roles: ['ROLE_ADMIN'] },

  ];



  ngOnInit(): void {

    this.i18n.init();

    if (!this.authService.currentUser()) {

      this.authService.loadProfile().subscribe();

    }

    this.navStats.refresh();

    if (this.settingsService.get().inAppNotifications) {

      this.notificationService.refreshUnreadCount();

    }

  }



  visibleNav(item: NavItem): boolean {

    if (!item.roles) return true;

    return item.roles.some((r) => this.tokenStorage.hasRole(r));

  }



  badgeCount(item: NavItem): number | null {

    if (item.badgeKey === 'notifications') {

      const count = this.notificationService.unreadCount();

      return count > 0 ? count : null;

    }

    if (!item.countKey) return null;

    if (this.navStats.loading() && !this.navStats.lastUpdated()) return null;

    return this.navStats.counts()[item.countKey];

  }



  isAdmin(): boolean {

    return this.tokenStorage.hasRole('ROLE_ADMIN');

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

    return key ? this.i18n.t(key) : 'Utilisateur';

  }



  logout(): void {

    this.authService.logout();

  }

}

