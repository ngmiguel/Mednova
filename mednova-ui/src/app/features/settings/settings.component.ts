import { DatePipe } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { Component, inject, OnInit, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { environment } from '../../../environments/environment';
import { ApiResponse } from '../../core/models/api-response.model';
import { AuthService } from '../../core/services/auth.service';
import { NavStatsService } from '../../core/services/nav-stats.service';
import { NotificationService } from '../../core/services/notification.service';
import { SettingsService, ThemeMode, UiDensity } from '../../core/services/settings.service';
import { I18nService } from '../../core/i18n/i18n.service';
import { TokenStorageService } from '../../core/services/token-storage.service';
import { AppIconComponent } from '../../shared/components/app-icon/app-icon.component';

interface TwoFactorStatus {
  enabled: boolean;
}

interface GatewayHealth {
  status: string;
}

@Component({
  selector: 'app-settings',
  standalone: true,
  imports: [FormsModule, RouterLink, DatePipe, AppIconComponent],
  templateUrl: './settings.component.html',
  styleUrl: './settings.component.scss',
})
export class SettingsComponent implements OnInit {
  private readonly http = inject(HttpClient);
  private readonly settingsService = inject(SettingsService);
  private readonly tokenStorage = inject(TokenStorageService);
  private readonly notificationService = inject(NotificationService);
  private readonly i18n = inject(I18nService);
  readonly authService = inject(AuthService);
  readonly navStats = inject(NavStatsService);

  readonly twoFactorEnabled = signal<boolean | null>(null);
  readonly gatewayStatus = signal<string | null>(null);
  readonly saved = signal(false);
  readonly checking = signal(false);

  settings = { ...this.settingsService.get() };

  readonly isAdmin = () => this.tokenStorage.hasRole('ROLE_ADMIN');
  readonly resolvedTheme = () => this.settingsService.resolvedTheme(this.settings);

  ngOnInit(): void {
    this.settings = {
      ...this.settingsService.get(),
      staySignedIn: this.tokenStorage.isStaySignedIn(),
    };
    if (!this.authService.currentUser()) {
      this.authService.loadProfile().subscribe();
    }
    if (!this.navStats.lastUpdated()) {
      this.navStats.refresh();
    }
    this.loadTwoFactorStatus();
    this.checkGatewayHealth();
  }

  previewTheme(theme: ThemeMode): void {
    this.settings.theme = theme;
    this.settingsService.applyToDocument(this.settings);
  }

  onLanguageChange(lang: 'fr' | 'en'): void {
    this.settings.language = lang;
    this.i18n.setLanguage(lang);
  }

  previewDensity(density: UiDensity): void {
    this.settings.density = density;
    this.settings.compactSidebar = density === 'compact';
    this.settingsService.applyToDocument(this.settings);
  }

  save(): void {
    if (this.settings.density === 'compact') {
      this.settings.compactSidebar = true;
    }
    this.settingsService.update(this.settings);
    this.i18n.setLanguage(this.settings.language);
    this.tokenStorage.setStaySignedIn(this.settings.staySignedIn);
    if (!this.settings.rememberEmail) {
      this.tokenStorage.clearRememberedEmail();
    }
    if (this.settings.inAppNotifications) {
      this.notificationService.refreshUnreadCount();
    }
    this.saved.set(true);
    setTimeout(() => this.saved.set(false), 2500);
  }

  reset(): void {
    this.settingsService.reset();
    this.settings = { ...this.settingsService.get() };
    this.saved.set(true);
    setTimeout(() => this.saved.set(false), 2500);
  }

  refreshStats(): void {
    this.navStats.refresh();
  }

  checkGatewayHealth(): void {
    this.checking.set(true);
    this.http
      .get<GatewayHealth>(`${environment.apiBaseUrl.replace('/api/v1', '')}/actuator/health`)
      .subscribe({
        next: (res) => {
          this.gatewayStatus.set(res.status ?? 'UP');
          this.checking.set(false);
        },
        error: () => {
          this.gatewayStatus.set('DOWN');
          this.checking.set(false);
        },
      });
  }

  logout(): void {
    this.authService.logout();
  }

  openSwagger(): void {
    window.open('/swagger-ui.html', '_blank');
  }

  private loadTwoFactorStatus(): void {
    this.http.get<ApiResponse<TwoFactorStatus>>(`${environment.apiBaseUrl}/auth/2fa/status`).subscribe({
      next: (res) => this.twoFactorEnabled.set(res.data?.enabled ?? false),
      error: () => this.twoFactorEnabled.set(false),
    });
  }
}
