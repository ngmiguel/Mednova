import { HttpClient } from '@angular/common/http';
import { Injectable, inject, signal } from '@angular/core';
import { catchError, forkJoin, of, tap } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ApiResponse } from '../models/api-response.model';
import { PageResponse } from '../models/page-response.model';

export interface NavCounts {
  patients: number;
  doctors: number;
  appointments: number;
  auditEvents: number;
}

@Injectable({ providedIn: 'root' })
export class NavStatsService {
  private readonly http = inject(HttpClient);

  readonly counts = signal<NavCounts>({ patients: 0, doctors: 0, appointments: 0, auditEvents: 0 });
  readonly loading = signal(false);
  readonly lastUpdated = signal<Date | null>(null);

  refresh(): void {
    this.loading.set(true);
    const base = environment.apiBaseUrl;
    const get = (url: string) =>
      this.http.get<ApiResponse<PageResponse<unknown>>>(url).pipe(catchError(() => of(null)));

    forkJoin({
      patients: get(`${base}/patients?size=1`),
      doctors: get(`${base}/doctors?size=1`),
      appointments: get(`${base}/appointments?size=1`),
      audit: get(`${base}/audit/events?size=1`),
    })
      .pipe(
        tap((res) => {
          this.counts.set({
            patients: res.patients?.data?.totalElements ?? 0,
            doctors: res.doctors?.data?.totalElements ?? 0,
            appointments: res.appointments?.data?.totalElements ?? 0,
            auditEvents: res.audit?.data?.totalElements ?? 0,
          });
          this.lastUpdated.set(new Date());
          this.loading.set(false);
        })
      )
      .subscribe({ error: () => this.loading.set(false) });
  }

  countFor(key: keyof NavCounts): number | null {
    if (this.loading() && !this.lastUpdated()) return null;
    return this.counts()[key];
  }
}
