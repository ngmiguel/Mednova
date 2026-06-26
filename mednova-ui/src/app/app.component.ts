import { Component, inject, OnInit } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { I18nService } from './core/i18n/i18n.service';
import { SettingsService } from './core/services/settings.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet],
  template: '<router-outlet />',
})
export class AppComponent implements OnInit {
  private readonly settingsService = inject(SettingsService);
  private readonly i18n = inject(I18nService);

  ngOnInit(): void {
    this.settingsService.init();
    this.i18n.init();
  }
}
