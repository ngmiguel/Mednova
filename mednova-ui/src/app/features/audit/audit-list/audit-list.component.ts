import { DatePipe } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { Component, inject, OnInit, signal } from '@angular/core';
import { environment } from '../../../../environments/environment';
import { ApiResponse } from '../../../core/models/api-response.model';
import { PageResponse } from '../../../core/models/page-response.model';
import { apiErrorMessage } from '../../../core/utils/api-error.utils';
import { AppIconComponent, AppIconName } from '../../../shared/components/app-icon/app-icon.component';

interface AuditEventSummary {
  eventId: string;
  eventType: string;
  source: string;
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

  eventIcon(type: string): AppIconName {
    if (type.includes('HEALTH')) return 'alert';
    if (type.includes('LOGIN') || type.includes('AUTH')) return 'lock';
    if (type.includes('CREATE')) return 'plus';
    if (type.includes('DELETE')) return 'x';
    return 'audit';
  }
}
