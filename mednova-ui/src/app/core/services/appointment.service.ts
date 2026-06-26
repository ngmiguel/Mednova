import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ApiResponse } from '../models/api-response.model';
import { PageResponse } from '../models/page-response.model';

export interface Appointment {
  id: string;
  patientId: string;
  doctorId: string;
  patientUserId: string;
  doctorUserId: string;
  scheduledAt: string;
  durationMinutes: number;
  reason?: string;
  notes?: string;
  status: string;
}

export interface CreateAppointmentPayload {
  patientId: string;
  doctorId: string;
  patientUserId: string;
  doctorUserId: string;
  scheduledAt: string;
  durationMinutes: number;
  reason: string;
  notes?: string;
}

@Injectable({ providedIn: 'root' })
export class AppointmentService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiBaseUrl}/appointments`;

  list(size = 50): Observable<ApiResponse<PageResponse<Appointment>>> {
    return this.http.get<ApiResponse<PageResponse<Appointment>>>(`${this.base}?size=${size}`);
  }

  create(payload: CreateAppointmentPayload): Observable<ApiResponse<Appointment>> {
    return this.http.post<ApiResponse<Appointment>>(this.base, payload);
  }

  confirm(id: string): Observable<ApiResponse<Appointment>> {
    return this.http.patch<ApiResponse<Appointment>>(`${this.base}/${id}/confirm`, {});
  }

  cancel(id: string): Observable<ApiResponse<Appointment>> {
    return this.http.patch<ApiResponse<Appointment>>(`${this.base}/${id}/cancel`, {});
  }
}
