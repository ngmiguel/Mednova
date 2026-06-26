import { Injectable } from '@angular/core';

const ACCESS_TOKEN_KEY = 'mednova_access_token';
const REFRESH_TOKEN_KEY = 'mednova_refresh_token';
const ROLES_KEY = 'mednova_roles';
const REMEMBER_EMAIL_KEY = 'mednova_remember_email';
const STAY_SIGNED_IN_KEY = 'mednova_stay_signed_in';

@Injectable({ providedIn: 'root' })
export class TokenStorageService {
  saveTokens(accessToken: string, refreshToken: string, roles: string[]): void {
    const storage = this.activeStorage();
    storage.setItem(ACCESS_TOKEN_KEY, accessToken);
    storage.setItem(REFRESH_TOKEN_KEY, refreshToken);
    storage.setItem(ROLES_KEY, JSON.stringify(roles));
    this.clearOtherStorage(storage);
  }

  getAccessToken(): string | null {
    return this.readFromStorages(ACCESS_TOKEN_KEY);
  }

  getRefreshToken(): string | null {
    return this.readFromStorages(REFRESH_TOKEN_KEY);
  }

  getRoles(): string[] {
    const raw = this.readFromStorages(ROLES_KEY);
    return raw ? (JSON.parse(raw) as string[]) : [];
  }

  hasRole(role: string): boolean {
    return this.getRoles().includes(role);
  }

  clear(): void {
    for (const storage of [localStorage, sessionStorage]) {
      storage.removeItem(ACCESS_TOKEN_KEY);
      storage.removeItem(REFRESH_TOKEN_KEY);
      storage.removeItem(ROLES_KEY);
    }
  }

  isLoggedIn(): boolean {
    return !!this.getAccessToken();
  }

  saveRememberedEmail(email: string): void {
    localStorage.setItem(REMEMBER_EMAIL_KEY, email);
  }

  getRememberedEmail(): string | null {
    return localStorage.getItem(REMEMBER_EMAIL_KEY);
  }

  clearRememberedEmail(): void {
    localStorage.removeItem(REMEMBER_EMAIL_KEY);
  }

  setStaySignedIn(enabled: boolean): void {
    localStorage.setItem(STAY_SIGNED_IN_KEY, enabled ? '1' : '0');
    if (this.isLoggedIn()) {
      this.migrateSessionStorage(enabled);
    }
  }

  isStaySignedIn(): boolean {
    return localStorage.getItem(STAY_SIGNED_IN_KEY) !== '0';
  }

  private activeStorage(): Storage {
    return this.isStaySignedIn() ? localStorage : sessionStorage;
  }

  private readFromStorages(key: string): string | null {
    return localStorage.getItem(key) ?? sessionStorage.getItem(key);
  }

  private clearOtherStorage(active: Storage): void {
    const other = active === localStorage ? sessionStorage : localStorage;
    for (const key of [ACCESS_TOKEN_KEY, REFRESH_TOKEN_KEY, ROLES_KEY]) {
      other.removeItem(key);
    }
  }

  private migrateSessionStorage(toLocal: boolean): void {
    const from = toLocal ? sessionStorage : localStorage;
    const to = toLocal ? localStorage : sessionStorage;
    for (const key of [ACCESS_TOKEN_KEY, REFRESH_TOKEN_KEY, ROLES_KEY]) {
      const value = from.getItem(key);
      if (value !== null) {
        to.setItem(key, value);
        from.removeItem(key);
      }
    }
  }
}
