import { HttpClient } from '@angular/common/http';
import { Injectable, inject, signal } from '@angular/core';
import { catchError, of, tap } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ApiResponse } from '../models/api-response.model';
import { PageResponse } from '../models/page-response.model';

export type NotificationType =
  | 'HEALTH_ALERT'
  | 'VITALS_ANOMALY'
  | 'APPOINTMENT_SCHEDULED'
  | 'APPOINTMENT_CANCELLED';

export type NotificationStatus = 'UNREAD' | 'READ';

export interface NotificationItem {
  id: string;
  patientId?: string;
  type: NotificationType;
  channel: string;
  title: string;
  message: string;
  status: NotificationStatus;
  targetRole?: string;
  sourceEventType?: string;
  createdAt: string;
  readAt?: string;
}

@Injectable({ providedIn: 'root' })
export class NotificationService {
  private readonly http = inject(HttpClient);

  readonly items = signal<NotificationItem[]>([]);
  readonly unreadCount = signal(0);
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);

  refresh(status?: NotificationStatus): void {
    this.loading.set(true);
    this.error.set(null);
    let url = `${environment.apiBaseUrl}/notifications?size=50`;
    if (status) url += `&status=${status}`;

    this.http
      .get<ApiResponse<PageResponse<NotificationItem>>>(url)
      .pipe(
        tap((res) => {
          this.items.set(res.data?.content ?? []);
          this.loading.set(false);
        }),
        catchError(() => {
          this.error.set('Impossible de charger les notifications');
          this.loading.set(false);
          return of(null);
        })
      )
      .subscribe();
  }

  refreshUnreadCount(): void {
    this.http
      .get<ApiResponse<{ unreadCount: number }>>(`${environment.apiBaseUrl}/notifications/unread-count`)
      .pipe(catchError(() => of(null)))
      .subscribe((res) => {
        this.unreadCount.set(res?.data?.unreadCount ?? 0);
      });
  }

  markAsRead(id: string): void {
    this.http
      .patch<ApiResponse<NotificationItem>>(`${environment.apiBaseUrl}/notifications/${id}/read`, {})
      .subscribe({
        next: (res) => {
          const updated = res.data;
          if (!updated) return;
          this.items.update((list) => list.map((n) => (n.id === id ? updated : n)));
          this.refreshUnreadCount();
        },
      });
  }

  markAllRead(): void {
    const unread = this.items().filter((n) => n.status === 'UNREAD');
    unread.forEach((n) => this.markAsRead(n.id));
  }
}
