import { Component, Input } from '@angular/core';

export type AppIconName =
  | 'dashboard'
  | 'patients'
  | 'doctors'
  | 'appointments'
  | 'audit'
  | 'settings'
  | 'notifications'
  | 'search'
  | 'mail'
  | 'phone'
  | 'logout'
  | 'plus'
  | 'check'
  | 'alert'
  | 'clock'
  | 'notes'
  | 'user'
  | 'palette'
  | 'lock'
  | 'refresh'
  | 'shield'
  | 'monitoring'
  | 'ai'
  | 'activity'
  | 'moon'
  | 'sun'
  | 'monitor'
  | 'bell-off'
  | 'chevron-right'
  | 'x'
  | 'droplet'
  | 'gender'
  | 'messages'
  | 'send';

const ICON_PATHS: Record<AppIconName, string> = {
  dashboard:
    'M3 3h8v8H3zM13 3h8v5h-8zM13 10h8v11h-8zM3 13h8v8H3z',
  patients: 'M19.5 13.5c-1.2-1.1-2.8-1.7-4.5-1.7s-3.3.6-4.5 1.7M12 20.5a7 7 0 1 0 0-14 7 7 0 0 0 0 14z',
  doctors:
    'M11 2v2M9 4h4M10 14v8M6 22h8M7 10h6a2 2 0 0 0 2-2V6a4 4 0 0 0-8 0v2a2 2 0 0 0 2 2z',
  appointments:
    'M8 2v4M16 2v4M3 10h18M5 4h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2z',
  audit:
    'M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10zM9 12l2 2 4-4',
  settings:
    'M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z',
  notifications:
    'M15 17h5l-1.4-1.4A2 2 0 0 1 18 14.2V11a6 6 0 1 0-12 0v3.2c0 .5-.2 1-.6 1.4L4 17h5m6 0a3 3 0 0 1-6 0',
  search: 'M11 19a8 8 0 1 0 0-16 8 8 0 0 0 0 16zM21 21l-4.3-4.3',
  mail: 'M4 4h16a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2zM22 6l-10 7L2 6',
  phone:
    'M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.5 19.5 0 0 1-6-6A19.8 19.8 0 0 1 2.1 4.2 2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1.9.3 1.8.6 2.6a2 2 0 0 1-.5 2.1L8 9.9a16 16 0 0 0 6.1 6.1l1.5-1.2a2 2 0 0 1 2.1-.5c.8.3 1.7.5 2.6.6A2 2 0 0 1 22 16.9z',
  logout:
    'M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9',
  plus: 'M12 5v14M5 12h14',
  check: 'M20 6L9 17l-5-5',
  alert: 'M10.3 3.6L1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.6a2 2 0 0 0-3.4 0zM12 9v4M12 17h.01',
  clock: 'M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20zM12 6v6l4 2',
  notes: 'M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8zM14 2v6h6',
  user: 'M20 21a8 8 0 1 0-16 0M12 13a4 4 0 1 0 0-8 4 4 0 0 0 0 8z',
  palette:
    'M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20zM7 12h.01M12 7h.01M17 12h.01M12 17h.01',
  lock: 'M7 11V7a5 5 0 0 1 10 0v4M5 11h14a2 2 0 0 1 2 2v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2z',
  refresh:
    'M21 2v6h-6M3 12a9 9 0 0 1 15.5-6.4L21 8M3 22v-6h6M21 12a9 9 0 0 1-15.5 6.4L3 16',
  shield: 'M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z',
  monitoring:
    'M22 12h-4l-3 9L9 3l-3 9H2',
  ai: 'M12 2a4 4 0 0 1 4 4v1a4 4 0 0 1-8 0V6a4 4 0 0 1 4-4zM6 21v-2a6 6 0 0 1 12 0v2',
  activity: 'M22 12h-4l-3 9L9 3l-3 9H2',
  moon: 'M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z',
  sun:
    'M12 18a6 6 0 1 0 0-12 6 6 0 0 0 0 12zM12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4',
  monitor: 'M20 3H4a2 2 0 0 0-2 2v11a2 2 0 0 0 2 2h6l-2 3h8l-2-3h6a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2z',
  'bell-off':
    'M13.7 17.3A6 6 0 0 1 12 18a3 3 0 0 1-3-3M18 17H4l1.4-1.4A2 2 0 0 0 6 14.2V11a6 6 0 0 1 9.3-5M22 2L2 22',
  'chevron-right': 'M9 18l6-6-6-6',
  x: 'M18 6L6 18M6 6l12 12',
  droplet:
    'M12 2.7c-3.5 4.5-6 7.8-6 11.3a6 6 0 0 0 12 0c0-3.5-2.5-6.8-6-11.3z',
  gender: 'M12 14a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM12 14v8M9 19h6',
  messages:
    'M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z',
  send: 'M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z',
};

@Component({
  selector: 'app-icon',
  standalone: true,
  template: `
    <svg
      class="app-icon"
      [class]="'icon-' + name"
      [attr.width]="size"
      [attr.height]="size"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      aria-hidden="true"
    >
      <path [attr.d]="path" />
    </svg>
  `,
  styles: `
    :host {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      line-height: 0;
      flex-shrink: 0;
    }
    .app-icon {
      display: block;
    }
  `,
})
export class AppIconComponent {
  @Input({ required: true }) name!: AppIconName;
  @Input() size = 18;

  get path(): string {
    return ICON_PATHS[this.name];
  }
}
