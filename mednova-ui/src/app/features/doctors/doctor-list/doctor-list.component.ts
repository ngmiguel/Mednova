import { HttpClient } from '@angular/common/http';
import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { environment } from '../../../../environments/environment';
import { ApiResponse } from '../../../core/models/api-response.model';
import { PageResponse } from '../../../core/models/page-response.model';
import { apiErrorMessage } from '../../../core/utils/api-error.utils';
import { AppIconComponent } from '../../../shared/components/app-icon/app-icon.component';

interface DoctorSummary {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  specialty?: string;
  phone?: string;
  active?: boolean;
}

const SPECIALTY_LABELS: Record<string, string> = {
  GENERAL_PRACTICE: 'Médecine générale',
  CARDIOLOGY: 'Cardiologie',
  NEUROLOGY: 'Neurologie',
  PEDIATRICS: 'Pédiatrie',
  ONCOLOGY: 'Oncologie',
  DERMATOLOGY: 'Dermatologie',
  ORTHOPEDICS: 'Orthopédie',
  PSYCHIATRY: 'Psychiatrie',
  RADIOLOGY: 'Radiologie',
  SURGERY: 'Chirurgie',
};

@Component({
  selector: 'app-doctor-list',
  standalone: true,
  imports: [AppIconComponent],
  templateUrl: './doctor-list.component.html',
  styleUrl: './doctor-list.component.scss',
})
export class DoctorListComponent implements OnInit {
  private readonly http = inject(HttpClient);

  readonly doctors = signal<DoctorSummary[]>([]);
  readonly error = signal<string | null>(null);
  readonly loading = signal(true);
  readonly search = signal('');
  readonly specialtyFilter = signal<string | null>(null);

  readonly specialties = computed(() => [...new Set(this.doctors().map((d) => d.specialty).filter(Boolean))] as string[]);

  readonly filtered = computed(() => {
    let list = this.doctors();
    const spec = this.specialtyFilter();
    if (spec) list = list.filter((d) => d.specialty === spec);
    const q = this.search().toLowerCase();
    if (q) {
      list = list.filter(
        (d) =>
          d.firstName.toLowerCase().includes(q) ||
          d.lastName.toLowerCase().includes(q) ||
          d.email.toLowerCase().includes(q)
      );
    }
    return list;
  });

  ngOnInit(): void {
    this.load();
  }

  retry(): void {
    this.loading.set(true);
    this.error.set(null);
    this.load();
  }

  private load(): void {
    this.http
      .get<ApiResponse<PageResponse<DoctorSummary>>>(`${environment.apiBaseUrl}/doctors?size=50`)
      .subscribe({
        next: (res) => {
          this.doctors.set(res.data?.content ?? []);
          this.loading.set(false);
        },
        error: (err) => {
          this.error.set(apiErrorMessage(err, 'Impossible de charger les médecins'));
          this.loading.set(false);
        },
      });
  }

  specialtyLabel(spec?: string): string {
    if (!spec) return '—';
    return SPECIALTY_LABELS[spec] ?? spec;
  }

  avatarColor(name: string): string {
    const colors = ['#6366f1', '#0d9488', '#8b5cf6', '#ec4899'];
    return colors[name.charCodeAt(0) % colors.length];
  }
}
