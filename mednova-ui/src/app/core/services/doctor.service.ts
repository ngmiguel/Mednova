import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ApiResponse } from '../models/api-response.model';
import { PageResponse } from '../models/page-response.model';

export interface DoctorDetail {
  id: string;
  userId?: string;
  firstName: string;
  lastName: string;
  email: string;
  phone?: string;
  specialty?: string;
  licenseNumber?: string;
  bio?: string;
  active?: boolean;
  createdAt?: string;
  updatedAt?: string;
}

@Injectable({ providedIn: 'root' })
export class DoctorService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiBaseUrl}/doctors`;

  getById(id: string): Observable<ApiResponse<DoctorDetail>> {
    return this.http.get<ApiResponse<DoctorDetail>>(`${this.base}/${id}`);
  }

  list(size = 50): Observable<ApiResponse<PageResponse<DoctorDetail>>> {
    return this.http.get<ApiResponse<PageResponse<DoctorDetail>>>(`${this.base}?size=${size}`);
  }
}
