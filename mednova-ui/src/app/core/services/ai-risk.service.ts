import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ApiResponse } from '../models/api-response.model';
import { PageResponse } from '../models/page-response.model';

export interface RiskAssessment {
  id: string;
  patientId: string;
  patientUserId: string;
  readingId?: string;
  riskScore: number;
  riskLevel: 'LOW' | 'MODERATE' | 'HIGH' | 'CRITICAL';
  factors: string[];
  recommendation: string;
  triggerEventType?: string;
  assessedAt: string;
  createdAt: string;
}

@Injectable({ providedIn: 'root' })
export class AiRiskService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiBaseUrl}/ai`;

  listByPatient(patientId: string, size = 20): Observable<ApiResponse<PageResponse<RiskAssessment>>> {
    return this.http.get<ApiResponse<PageResponse<RiskAssessment>>>(
      `${this.base}/patients/${patientId}/risk-assessments?size=${size}`
    );
  }

  getLatest(patientId: string): Observable<ApiResponse<RiskAssessment>> {
    return this.http.get<ApiResponse<RiskAssessment>>(`${this.base}/patients/${patientId}/risk-assessments/latest`);
  }
}
