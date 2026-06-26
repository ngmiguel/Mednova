import { Injectable, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Observable, tap } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ApiResponse } from '../models/api-response.model';
import {
  AuthTokens,
  ForgotPasswordRequest,
  LoginRequest,
  RegisterRequest,
  ResetPasswordRequest,
  TwoFactorVerifyRequest,
  UserProfile,
  VerifyOtpRequest,
} from '../models/auth.model';
import { TokenStorageService } from './token-storage.service';
import { SettingsService } from './settings.service';
import { extractRolesFromToken } from '../utils/jwt.utils';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly http = inject(HttpClient);
  private readonly router = inject(Router);
  private readonly tokenStorage = inject(TokenStorageService);
  private readonly settingsService = inject(SettingsService);

  readonly currentUser = signal<UserProfile | null>(null);

  login(credentials: LoginRequest): Observable<ApiResponse<AuthTokens>> {
    return this.http.post<ApiResponse<AuthTokens>>(`${environment.apiBaseUrl}/auth/login`, credentials).pipe(
      tap((response) => {
        if (response.data && !response.data.requiresTwoFactor) {
          this.persistSession(response.data);
        }
      })
    );
  }

  register(payload: RegisterRequest): Observable<ApiResponse<AuthTokens>> {
    return this.http
      .post<ApiResponse<AuthTokens>>(`${environment.apiBaseUrl}/auth/register`, payload)
      .pipe(tap((response) => this.persistSession(response.data)));
  }

  verifyTwoFactor(request: TwoFactorVerifyRequest): Observable<ApiResponse<AuthTokens>> {
    return this.http
      .post<ApiResponse<AuthTokens>>(`${environment.apiBaseUrl}/auth/2fa/verify-login`, request)
      .pipe(tap((response) => this.persistSession(response.data)));
  }

  forgotPassword(request: ForgotPasswordRequest): Observable<ApiResponse<void>> {
    return this.http.post<ApiResponse<void>>(`${environment.apiBaseUrl}/auth/password/forgot`, request);
  }

  verifyPasswordOtp(request: VerifyOtpRequest): Observable<ApiResponse<{ resetToken: string }>> {
    return this.http.post<ApiResponse<{ resetToken: string }>>(
      `${environment.apiBaseUrl}/auth/password/verify-otp`,
      request
    );
  }

  resetPassword(request: ResetPasswordRequest): Observable<ApiResponse<void>> {
    return this.http.post<ApiResponse<void>>(`${environment.apiBaseUrl}/auth/password/reset`, request);
  }

  loadProfile(): Observable<ApiResponse<UserProfile>> {
    return this.http
      .get<ApiResponse<UserProfile>>(`${environment.apiBaseUrl}/auth/me`)
      .pipe(
        tap((response) => {
          this.currentUser.set(response.data);
          const accessToken = this.tokenStorage.getAccessToken();
          const refreshToken = this.tokenStorage.getRefreshToken();
          if (!accessToken || !refreshToken) return;
          const roles =
            response.data?.roles?.length
              ? response.data.roles
              : extractRolesFromToken(accessToken);
          if (roles.length) {
            this.tokenStorage.saveTokens(accessToken, refreshToken, roles);
          }
        })
      );
  }

  logout(): void {
    const refreshToken = this.tokenStorage.getRefreshToken();
    if (refreshToken) {
      this.http
        .post(`${environment.apiBaseUrl}/auth/logout`, { refreshToken })
        .subscribe({ complete: () => this.clearSession() });
    } else {
      this.clearSession();
    }
  }

  clearSession(): void {
    this.tokenStorage.clear();
    this.currentUser.set(null);
    void this.router.navigate(['/auth/login']);
  }

  private persistSession(tokens: AuthTokens | null | undefined, staySignedIn?: boolean): void {
    if (!tokens?.accessToken || !tokens.refreshToken) {
      return;
    }
    const persist = staySignedIn ?? this.settingsService.get().staySignedIn;
    localStorage.setItem('mednova_stay_signed_in', persist ? '1' : '0');
    this.tokenStorage.setStaySignedIn(persist);
    const roles =
      tokens.roles?.length ? tokens.roles : extractRolesFromToken(tokens.accessToken);
    this.tokenStorage.saveTokens(tokens.accessToken, tokens.refreshToken, roles);
  }
}
