import { Injectable, computed, inject, signal } from '@angular/core';
import { SettingsService } from '../services/settings.service';
import { Lang, TRANSLATIONS } from './translations';

@Injectable({ providedIn: 'root' })
export class I18nService {
  private readonly settings = inject(SettingsService);
  private readonly lang = signal<Lang>('fr');

  readonly currentLang = computed(() => this.lang());

  init(): void {
    this.lang.set(this.settings.get().language);
  }

  setLanguage(lang: Lang): void {
    this.lang.set(lang);
    this.settings.update({ language: lang });
  }

  t(key: string, params?: Record<string, string | number>): string {
    const dict = TRANSLATIONS[this.lang()] ?? TRANSLATIONS.fr;
    let text = dict[key] ?? TRANSLATIONS.fr[key] ?? key;
    if (params) {
      for (const [k, v] of Object.entries(params)) {
        text = text.replace(`{{${k}}}`, String(v));
      }
    }
    return text;
  }
}
