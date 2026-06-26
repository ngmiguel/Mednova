import { DatePipe } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { Component, inject, OnInit, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { environment } from '../../../environments/environment';
import { AiRiskService, RiskAssessment } from '../../core/services/ai-risk.service';
import { AuthService } from '../../core/services/auth.service';
import { ApiResponse } from '../../core/models/api-response.model';
import { PageResponse } from '../../core/models/page-response.model';
import { TokenStorageService } from '../../core/services/token-storage.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { AppIconComponent } from '../../shared/components/app-icon/app-icon.component';

interface PatientOption {
  id: string;
  firstName: string;
  lastName: string;
}

@Component({
  selector: 'app-ai-predictions',
  standalone: true,
  imports: [FormsModule, DatePipe, AppIconComponent, TranslatePipe],
  templateUrl: './ai-predictions.component.html',
  styleUrl: './ai-predictions.component.scss',
})
export class AiPredictionsComponent implements OnInit {
  private readonly aiRisk = inject(AiRiskService);
  private readonly http = inject(HttpClient);
  private readonly tokenStorage = inject(TokenStorageService);
  readonly authService = inject(AuthService);

  readonly assessments = signal<RiskAssessment[]>([]);
  readonly patients = signal<PatientOption[]>([]);
  readonly selectedPatientId = signal<string | null>(null);
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);

  readonly isStaff = () =>
    this.tokenStorage.hasRole('ROLE_ADMIN') ||
    this.tokenStorage.hasRole('ROLE_DOCTOR') ||
    this.tokenStorage.hasRole('ROLE_NURSE') ||
    this.tokenStorage.hasRole('ROLE_AUDITOR');

  ngOnInit(): void {
    if (this.isStaff()) {
      this.http
        .get<ApiResponse<PageResponse<PatientOption>>>(`${environment.apiBaseUrl}/patients?size=50`)
        .subscribe({
          next: (res) => {
            this.patients.set(res.data?.content ?? []);
            const first = res.data?.content?.[0];
            if (first) {
              this.selectedPatientId.set(first.id);
              this.loadAssessments(first.id);
            }
          },
        });
    } else if (this.authService.currentUser()) {
      const id = this.authService.currentUser()!.id;
      this.selectedPatientId.set(id);
      this.loadAssessments(id);
    } else {
      this.authService.loadProfile().subscribe({
        next: () => {
          const id = this.authService.currentUser()?.id;
          if (id) {
            this.selectedPatientId.set(id);
            this.loadAssessments(id);
          }
        },
      });
    }
  }

  onPatientChange(patientId: string): void {
    this.selectedPatientId.set(patientId);
    this.loadAssessments(patientId);
  }

  loadAssessments(patientId: string): void {
    this.loading.set(true);
    this.error.set(null);
    this.aiRisk.listByPatient(patientId).subscribe({
      next: (res) => {
        this.assessments.set(res.data?.content ?? []);
        this.loading.set(false);
      },
      error: () => {
        this.error.set('Impossible de charger les évaluations IA');
        this.loading.set(false);
      },
    });
  }

  levelClass(level: string): string {
    const map: Record<string, string> = {
      LOW: 'badge-success',
      MODERATE: 'badge-warning',
      HIGH: 'badge-danger',
      CRITICAL: 'badge-danger',
    };
    return map[level] ?? 'badge-neutral';
  }
}
