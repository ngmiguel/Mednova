import { HttpClient } from '@angular/common/http';
import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { environment } from '../../../../environments/environment';
import { ApiResponse } from '../../../core/models/api-response.model';
import { PageResponse } from '../../../core/models/page-response.model';
import { apiErrorMessage } from '../../../core/utils/api-error.utils';
import { AppIconComponent } from '../../../shared/components/app-icon/app-icon.component';

interface PatientSummary {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  phone?: string;
  bloodType?: string;
  gender?: string;
  dateOfBirth?: string;
}

@Component({
  selector: 'app-patient-list',
  standalone: true,
  imports: [AppIconComponent],
  templateUrl: './patient-list.component.html',
  styleUrl: './patient-list.component.scss',
})
export class PatientListComponent implements OnInit {
  private readonly http = inject(HttpClient);

  readonly patients = signal<PatientSummary[]>([]);
  readonly error = signal<string | null>(null);
  readonly loading = signal(true);
  readonly search = signal('');

  readonly filtered = computed(() => {
    const q = this.search().toLowerCase();
    if (!q) return this.patients();
    return this.patients().filter(
      (p) =>
        p.firstName.toLowerCase().includes(q) ||
        p.lastName.toLowerCase().includes(q) ||
        p.email?.toLowerCase().includes(q)
    );
  });

  ngOnInit(): void {
    this.http
      .get<ApiResponse<PageResponse<PatientSummary>>>(`${environment.apiBaseUrl}/patients?size=50`)
      .subscribe({
        next: (res) => {
          this.patients.set(res.data?.content ?? []);
          this.loading.set(false);
        },
        error: (err) => {
          this.error.set(apiErrorMessage(err, 'Impossible de charger les patients'));
          this.loading.set(false);
        },
      });
  }

  avatarColor(name: string): string {
    const colors = ['#0d9488', '#6366f1', '#8b5cf6', '#ec4899', '#f59e0b'];
    return colors[name.charCodeAt(0) % colors.length];
  }

  bloodLabel(type?: string): string {
    if (!type) return '—';
    return type.replace('_', ' ');
  }
}
