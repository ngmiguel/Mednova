import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ApiResponse } from '../models/api-response.model';
import { PageResponse } from '../models/page-response.model';

export interface PatientDetail {
  id: string;
  userId?: string;
  firstName: string;
  lastName: string;
  email: string;
  phone?: string;
  dateOfBirth?: string;
  bloodType?: string;
  gender?: string;
  address?: string;
  emergencyContact?: string;
  createdAt?: string;
  updatedAt?: string;
}

@Injectable({ providedIn: 'root' })
export class PatientService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiBaseUrl}/patients`;

  getById(id: string): Observable<ApiResponse<PatientDetail>> {
    return this.http.get<ApiResponse<PatientDetail>>(`${this.base}/${id}`);
  }

  list(size = 50): Observable<ApiResponse<PageResponse<PatientDetail>>> {
    return this.http.get<ApiResponse<PageResponse<PatientDetail>>>(`${this.base}?size=${size}`);
  }
}
