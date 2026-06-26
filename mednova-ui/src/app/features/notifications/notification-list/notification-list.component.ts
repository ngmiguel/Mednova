import { DatePipe } from '@angular/common';
import { Component, inject, OnInit, signal } from '@angular/core';
import { NotificationItem, NotificationService } from '../../../core/services/notification.service';
import { SettingsService } from '../../../core/services/settings.service';
import { AppIconComponent, AppIconName } from '../../../shared/components/app-icon/app-icon.component';

@Component({
  selector: 'app-notification-list',
  standalone: true,
  imports: [DatePipe, AppIconComponent],
  templateUrl: './notification-list.component.html',
  styleUrl: './notification-list.component.scss',
})
export class NotificationListComponent implements OnInit {
  readonly notificationService = inject(NotificationService);
  private readonly settingsService = inject(SettingsService);

  readonly filter = signal<'all' | 'unread'>('all');

  ngOnInit(): void {
    if (this.settingsService.get().inAppNotifications) {
      this.notificationService.refresh();
      this.notificationService.refreshUnreadCount();
    }
  }

  filtered(): NotificationItem[] {
    const list = this.notificationService.items();
    return this.filter() === 'unread' ? list.filter((n) => n.status === 'UNREAD') : list;
  }

  setFilter(value: 'all' | 'unread'): void {
    this.filter.set(value);
  }

  iconFor(type: string): AppIconName {
    const map: Record<string, AppIconName> = {
      HEALTH_ALERT: 'alert',
      VITALS_ANOMALY: 'activity',
      APPOINTMENT_SCHEDULED: 'appointments',
      APPOINTMENT_CANCELLED: 'x',
    };
    return map[type] ?? 'notifications';
  }

  typeLabel(type: string): string {
    const map: Record<string, string> = {
      HEALTH_ALERT: 'Alerte santé',
      VITALS_ANOMALY: 'Anomalie vitals',
      APPOINTMENT_SCHEDULED: 'RDV planifié',
      APPOINTMENT_CANCELLED: 'RDV annulé',
    };
    return map[type] ?? type;
  }

  markRead(id: string): void {
    this.notificationService.markAsRead(id);
  }

  markAllRead(): void {
    this.notificationService.markAllRead();
  }

  refresh(): void {
    this.notificationService.refresh();
    this.notificationService.refreshUnreadCount();
  }
}
