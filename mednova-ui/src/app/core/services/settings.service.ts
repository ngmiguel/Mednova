import { Injectable, signal } from '@angular/core';

export type ThemeMode = 'light' | 'dark' | 'system';
export type UiDensity = 'comfortable' | 'compact';

export interface AppSettings {
  animationsEnabled: boolean;
  compactSidebar: boolean;
  emailNotifications: boolean;
  inAppNotifications: boolean;
  staySignedIn: boolean;
  rememberEmail: boolean;
  language: 'fr' | 'en';
  theme: ThemeMode;
  density: UiDensity;
}

const STORAGE_KEY = 'mednova_app_settings';

const DEFAULTS: AppSettings = {
  animationsEnabled: true,
  compactSidebar: false,
  emailNotifications: true,
  inAppNotifications: true,
  staySignedIn: true,
  rememberEmail: true,
  language: 'fr',
  theme: 'system',
  density: 'comfortable',
};

@Injectable({ providedIn: 'root' })
export class SettingsService {
  readonly settings = signal<AppSettings>(this.load());
  private mediaQuery = typeof window !== 'undefined' ? window.matchMedia('(prefers-color-scheme: dark)') : null;

  constructor() {
    this.mediaQuery?.addEventListener('change', () => {
      if (this.settings().theme === 'system') {
        this.applyToDocument();
      }
    });
  }

  get(): AppSettings {
    return this.settings();
  }

  update(partial: Partial<AppSettings>): void {
    const next = { ...this.settings(), ...partial };
    if (partial.density === 'compact') {
      next.compactSidebar = true;
    } else if (partial.density === 'comfortable') {
      next.compactSidebar = false;
    }
    this.settings.set(next);
    localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
    this.applyToDocument(next);
  }

  reset(): void {
    this.settings.set({ ...DEFAULTS });
    localStorage.setItem(STORAGE_KEY, JSON.stringify(DEFAULTS));
    this.applyToDocument(DEFAULTS);
  }

  resolvedTheme(settings: AppSettings = this.settings()): 'light' | 'dark' {
    if (settings.theme === 'system') {
      return this.mediaQuery?.matches ? 'dark' : 'light';
    }
    return settings.theme;
  }

  applyToDocument(settings: AppSettings = this.settings()): void {
    const root = document.documentElement;
    const resolved = this.resolvedTheme(settings);

    root.classList.toggle('no-animations', !settings.animationsEnabled);
    root.classList.toggle('compact-sidebar', settings.compactSidebar);
    root.classList.toggle('theme-dark', resolved === 'dark');
    root.classList.toggle('theme-light', resolved === 'light');
    root.classList.toggle('density-compact', settings.density === 'compact');
    root.setAttribute('lang', settings.language);
    root.setAttribute('data-theme', resolved);
  }

  init(): void {
    const loaded = this.load();
    if (loaded.density === 'compact') {
      loaded.compactSidebar = true;
    }
    this.settings.set(loaded);
    this.applyToDocument(loaded);
  }

  private load(): AppSettings {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (!raw) return { ...DEFAULTS };
      return { ...DEFAULTS, ...(JSON.parse(raw) as Partial<AppSettings>) };
    } catch {
      return { ...DEFAULTS };
    }
  }
}
