import { DatePipe } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { Component, inject, OnInit, signal } from '@angular/core';
import { environment } from '../../../../environments/environment';
import { ApiResponse } from '../../../core/models/api-response.model';
import { PageResponse } from '../../../core/models/page-response.model';
import { apiErrorMessage } from '../../../core/utils/api-error.utils';
import { AppIconComponent, AppIconName } from '../../../shared/components/app-icon/app-icon.component';

interface AuditEventSummary {
  id?: string;
  eventId: string;
  eventType: string;
  source: string;
  correlationId?: string;
  payload?: string;
  receivedAt: string;
}

@Component({
  selector: 'app-audit-list',
  standalone: true,
  imports: [DatePipe, AppIconComponent],
  templateUrl: './audit-list.component.html',
  styleUrl: './audit-list.component.scss',
})
export class AuditListComponent implements OnInit {
  private readonly http = inject(HttpClient);

  readonly events = signal<AuditEventSummary[]>([]);
  readonly error = signal<string | null>(null);
  readonly loading = signal(true);
  readonly selectedEvent = signal<AuditEventSummary | null>(null);

  ngOnInit(): void {
    this.http
      .get<ApiResponse<PageResponse<AuditEventSummary>>>(`${environment.apiBaseUrl}/audit/events?size=50`)
      .subscribe({
        next: (res) => {
          this.events.set(res.data?.content ?? []);
          this.loading.set(false);
        },
        error: (err) => {
          this.error.set(apiErrorMessage(err, 'Accès audit refusé ou service indisponible'));
          this.loading.set(false);
        },
      });
  }

  openDetail(event: AuditEventSummary): void {
    this.selectedEvent.set(event);
  }

  closeDetail(): void {
    this.selectedEvent.set(null);
  }

  eventLabel(type: string): string {
    const map: Record<string, string> = {
      USER_LOGIN_SUCCESS: 'Connexion utilisateur',
      HEALTH_ALERT_TRIGGERED: 'Alerte santé déclenchée',
      PATIENT_RECORD_CREATED: 'Dossier patient créé',
      APPOINTMENT_SCHEDULED: 'Rendez-vous planifié',
    };
    return map[type] ?? type.replaceAll('_', ' ');
  }

  actorFromPayload(event: AuditEventSummary): string | null {
    if (!event.payload) return null;
    try {
      const data = JSON.parse(event.payload) as Record<string, unknown>;
      if (typeof data['createdBy'] === 'string') return data['createdBy'];
      if (typeof data['email'] === 'string') return data['email'];
      if (typeof data['patientId'] === 'string') return `Patient ${data['patientId']}`;
    } catch {
      return null;
    }
    return null;
  }

  prettyPayload(raw?: string): string {
    if (!raw) return '—';
    try {
      return JSON.stringify(JSON.parse(raw), null, 2);
    } catch {
      return raw;
    }
  }

  eventIcon(type: string): AppIconName {
    if (type.includes('HEALTH')) return 'alert';
    if (type.includes('LOGIN') || type.includes('AUTH')) return 'lock';
    if (type.includes('APPOINTMENT')) return 'appointments';
    if (type.includes('CREATE')) return 'plus';
    if (type.includes('DELETE')) return 'x';
    return 'audit';
  }
}
