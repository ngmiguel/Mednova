import { DatePipe } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { environment } from '../../../environments/environment';
import { MODULE_ROLES } from '../../core/config/module-roles';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { ApiResponse } from '../../core/models/api-response.model';
import { PageResponse } from '../../core/models/page-response.model';
import { AiRiskService, RiskAssessment } from '../../core/services/ai-risk.service';
import { AuthService } from '../../core/services/auth.service';
import { PersonDetailModalService } from '../../core/services/person-detail-modal.service';
import { TokenStorageService } from '../../core/services/token-storage.service';
import { AppIconComponent } from '../../shared/components/app-icon/app-icon.component';

interface PatientOption {
  id: string;
  firstName: string;
  lastName: string;
}

type LevelFilter = 'ALL' | RiskAssessment['riskLevel'] | 'ALERT';

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
  private readonly i18n = inject(I18nService);
  private readonly personModal = inject(PersonDetailModalService);
  readonly authService = inject(AuthService);

  readonly assessments = signal<RiskAssessment[]>([]);
  readonly patients = signal<PatientOption[]>([]);
  readonly selectedPatientId = signal<string | null>(null);
  readonly patientSearch = signal('');
  readonly levelFilter = signal<LevelFilter>('ALL');
  readonly loading = signal(false);
  readonly loadingPatients = signal(false);
  readonly error = signal<string | null>(null);

  readonly isStaff = () =>
    MODULE_ROLES.ai.some((role) => role !== 'ROLE_PATIENT' && this.tokenStorage.hasRole(role));

  readonly isPatient = () => this.tokenStorage.hasRole('ROLE_PATIENT');

  readonly filteredPatients = computed(() => {
    const query = this.patientSearch().trim().toLowerCase();
    const list = this.patients();
    if (!query) return list;
    return list.filter((p) => `${p.firstName} ${p.lastName}`.toLowerCase().includes(query));
  });

  readonly selectedPatientLabel = computed(() => {
    const id = this.selectedPatientId();
    if (!id) return '';
    const patient = this.patients().find((p) => p.id === id);
    if (patient) return `${patient.firstName} ${patient.lastName}`;
    const user = this.authService.currentUser();
    if (user && this.isPatient()) return `${user.firstName} ${user.lastName}`;
    return '';
  });

  readonly sortedAssessments = computed(() =>
    [...this.assessments()].sort(
      (a, b) => new Date(b.assessedAt).getTime() - new Date(a.assessedAt).getTime()
    )
  );

  readonly latestAssessment = computed(() => this.sortedAssessments()[0] ?? null);

  readonly displayedAssessments = computed(() => {
    const filter = this.levelFilter();
    const list = this.sortedAssessments();
    if (filter === 'ALL') return list;
    if (filter === 'ALERT') {
      return list.filter((a) => a.riskLevel === 'HIGH' || a.riskLevel === 'CRITICAL');
    }
    return list.filter((a) => a.riskLevel === filter);
  });

  readonly alertCount = computed(
    () =>
      this.assessments().filter((a) => a.riskLevel === 'HIGH' || a.riskLevel === 'CRITICAL').length
  );

  ngOnInit(): void {
    if (this.isStaff()) {
      this.loadPatients();
      return;
    }
    this.initPatientView();
  }

  onPatientChange(patientId: string): void {
    this.selectedPatientId.set(patientId);
    this.levelFilter.set('ALL');
    this.loadAssessments(patientId);
  }

  setLevelFilter(filter: LevelFilter): void {
    this.levelFilter.set(filter);
  }

  refresh(): void {
    const id = this.selectedPatientId();
    if (id) this.loadAssessments(id);
  }

  openSelectedPatientDetail(): void {
    const id = this.selectedPatientId();
    if (id && this.isStaff()) {
      this.personModal.openPatient(id);
    }
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

  levelLabel(level: string): string {
    const key = `ai.level.${level}`;
    const translated = this.i18n.t(key);
    return translated === key ? level : translated;
  }

  private initPatientView(): void {
    const user = this.authService.currentUser();
    if (user) {
      this.selectedPatientId.set(user.id);
      this.loadAssessments(user.id);
      return;
    }
    this.authService.loadProfile().subscribe({
      next: () => {
        const profile = this.authService.currentUser();
        if (profile) {
          this.selectedPatientId.set(profile.id);
          this.loadAssessments(profile.id);
        }
      },
    });
  }

  private loadPatients(): void {
    this.loadingPatients.set(true);
    this.http
      .get<ApiResponse<PageResponse<PatientOption>>>(`${environment.apiBaseUrl}/patients?size=100`)
      .subscribe({
        next: (res) => {
          const list = res.data?.content ?? [];
          this.patients.set(list);
          this.loadingPatients.set(false);
          const first = list[0];
          if (first) {
            this.selectedPatientId.set(first.id);
            this.loadAssessments(first.id);
          }
        },
        error: () => {
          this.loadingPatients.set(false);
          this.error.set(this.i18n.t('ai.error.loadPatients'));
        },
      });
  }

  loadAssessments(patientId: string): void {
    this.loading.set(true);
    this.error.set(null);
    this.aiRisk.listByPatient(patientId, 50).subscribe({
      next: (res) => {
        this.assessments.set(res.data?.content ?? []);
        this.loading.set(false);
      },
      error: () => {
        this.error.set(this.i18n.t('ai.error.loadAssessments'));
        this.loading.set(false);
      },
    });
  }
}
