import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { UserRole } from '../models/auth.model';
import { ApiResponse } from '../models/api-response.model';
import { PageResponse } from '../models/page-response.model';

export interface UserAccountDetail {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  enabled: boolean;
  twoFactorEnabled: boolean;
  roles: UserRole[];
  createdAt?: string;
}

@Injectable({ providedIn: 'root' })
export class UserAdminService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiBaseUrl}/auth/users`;

  getById(id: string): Observable<ApiResponse<UserAccountDetail>> {
    return this.http.get<ApiResponse<UserAccountDetail>>(`${this.base}/${id}`);
  }

  listByRole(role: UserRole, size = 50): Observable<ApiResponse<PageResponse<UserAccountDetail>>> {
    return this.http.get<ApiResponse<PageResponse<UserAccountDetail>>>(
      `${this.base}?role=${role}&size=${size}`
    );
  }

  setAccess(userId: string, enabled: boolean): Observable<ApiResponse<UserAccountDetail>> {
    return this.http.patch<ApiResponse<UserAccountDetail>>(`${this.base}/${userId}/access`, { enabled });
  }
}
