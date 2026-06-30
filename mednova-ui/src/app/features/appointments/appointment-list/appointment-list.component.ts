import { DatePipe } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { environment } from '../../../../environments/environment';
import { AuthService } from '../../../core/services/auth.service';
import { AppointmentService, CreateAppointmentPayload } from '../../../core/services/appointment.service';
import { ApiResponse } from '../../../core/models/api-response.model';
import { PageResponse } from '../../../core/models/page-response.model';
import { TokenStorageService } from '../../../core/services/token-storage.service';
import { TranslatePipe } from '../../../core/i18n/translate.pipe';
import { AppIconComponent } from '../../../shared/components/app-icon/app-icon.component';

interface AppointmentSummary {
  id: string;
  patientId?: string;
  doctorId?: string;
  patientUserId?: string;
  doctorUserId?: string;
  scheduledAt: string;
  durationMinutes: number;
  status: string;
  reason?: string;
  notes?: string;
  createdAt?: string;
  updatedAt?: string;
}

interface PersonOption {
  id: string;
  userId?: string;
  firstName: string;
  lastName: string;
}

@Component({
  selector: 'app-appointment-list',
  standalone: true,
  imports: [DatePipe, FormsModule, AppIconComponent, TranslatePipe],
  templateUrl: './appointment-list.component.html',
  styleUrl: './appointment-list.component.scss',
})
export class AppointmentListComponent implements OnInit {
  private readonly http = inject(HttpClient);
  private readonly appointmentService = inject(AppointmentService);
  private readonly tokenStorage = inject(TokenStorageService);
  private readonly authService = inject(AuthService);

  readonly patientSelfId = signal<string | null>(null);

  readonly appointments = signal<AppointmentSummary[]>([]);
  readonly patients = signal<PersonOption[]>([]);
  readonly doctors = signal<PersonOption[]>([]);
  readonly error = signal<string | null>(null);
  readonly loading = signal(true);
  readonly statusFilter = signal<string | null>(null);
  readonly showForm = signal(false);
  readonly saving = signal(false);
  readonly selectedAppointment = signal<AppointmentSummary | null>(null);

  form = {
    patientId: '',
    doctorId: '',
    scheduledAt: '',
    durationMinutes: 30,
    reason: '',
    notes: '',
  };

  readonly filtered = computed(() => {
    const status = this.statusFilter();
    if (!status) return this.appointments();
    return this.appointments().filter((a) => a.status === status);
  });

  readonly canBook = () =>
    this.tokenStorage.hasRole('ROLE_ADMIN') ||
    this.tokenStorage.hasRole('ROLE_NURSE') ||
    this.tokenStorage.hasRole('ROLE_PATIENT');

  ngOnInit(): void {
    this.loadAppointments();
    this.loadPeople();
  }

  loadAppointments(): void {
    this.appointmentService.list().subscribe({
      next: (res) => {
        this.appointments.set(res.data?.content ?? []);
        this.loading.set(false);
      },
      error: () => {
        this.error.set('Impossible de charger les rendez-vous');
        this.loading.set(false);
      },
    });
  }

  loadPeople(): void {
    const get = <T>(url: string) => this.http.get<ApiResponse<PageResponse<T>>>(url);
    if (this.tokenStorage.hasRole('ROLE_PATIENT') && this.canBook()) {
      const user = this.authService.currentUser();
      if (user) {
        this.setPatientSelf(user.id);
      } else {
        this.authService.loadProfile().subscribe({
          next: () => {
            const id = this.authService.currentUser()?.id;
            if (id) this.setPatientSelf(id);
          },
        });
      }
    } else if (!this.tokenStorage.hasRole('ROLE_PATIENT')) {
      get<PersonOption>(`${environment.apiBaseUrl}/patients?size=50`).subscribe({
        next: (res) => this.patients.set(res.data?.content ?? []),
      });
    }
    get<PersonOption & { userId?: string }>(`${environment.apiBaseUrl}/doctors?size=50`).subscribe({
      next: (res) => {
        const docs = (res.data?.content ?? []).map((d) => ({
          id: d.id,
          userId: (d as { userId?: string }).userId ?? d.id,
          firstName: d.firstName,
          lastName: d.lastName,
        }));
        this.doctors.set(docs);
      },
    });
  }

  toggleForm(): void {
    this.showForm.update((v) => !v);
  }

  submitBooking(): void {
    const isPatient = this.tokenStorage.hasRole('ROLE_PATIENT');
    const patientId = isPatient ? this.patientSelfId() : this.form.patientId;
    const patientUserId = isPatient
      ? this.authService.currentUser()?.id
      : this.patients().find((p) => p.id === this.form.patientId)?.userId;
    const doctor = this.doctors().find((d) => d.id === this.form.doctorId);
    if (!patientId || !doctor || !this.form.scheduledAt || !this.form.reason.trim()) {
      this.error.set('Veuillez remplir tous les champs obligatoires');
      return;
    }
    const payload: CreateAppointmentPayload = {
      patientId,
      doctorId: doctor.id,
      patientUserId: patientUserId ?? patientId,
      doctorUserId: doctor.userId ?? doctor.id,
      scheduledAt: new Date(this.form.scheduledAt).toISOString(),
      durationMinutes: this.form.durationMinutes,
      reason: this.form.reason.trim(),
      notes: this.form.notes.trim() || undefined,
    };
    this.saving.set(true);
    this.appointmentService.create(payload).subscribe({
      next: () => {
        this.saving.set(false);
        this.showForm.set(false);
        this.form = { patientId: '', doctorId: '', scheduledAt: '', durationMinutes: 30, reason: '', notes: '' };
        this.loadAppointments();
      },
      error: () => {
        this.saving.set(false);
        this.error.set('Impossible de créer le rendez-vous');
      },
    });
  }

  confirm(id: string): void {
    this.appointmentService.confirm(id).subscribe({ next: () => this.loadAppointments() });
  }

  cancel(id: string): void {
    this.appointmentService.cancel(id).subscribe({ next: () => this.loadAppointments() });
  }

  statusOf(status: string): { label: string; class: string } {
    const map: Record<string, { label: string; class: string }> = {
      SCHEDULED: { label: 'Planifié', class: 'badge-info' },
      CONFIRMED: { label: 'Confirmé', class: 'badge-success' },
      COMPLETED: { label: 'Terminé', class: 'badge-neutral' },
      CANCELLED: { label: 'Annulé', class: 'badge-danger' },
    };
    return map[status] ?? { label: status, class: 'badge-neutral' };
  }

  patientName(id?: string): string {
    if (!id) return 'Patient non renseigné';
    const p = this.patients().find((x) => x.id === id);
    return p ? `${p.firstName} ${p.lastName}` : `Patient ${id.slice(0, 8)}…`;
  }

  doctorName(id?: string): string {
    if (!id) return 'Médecin non renseigné';
    const d = this.doctors().find((x) => x.id === id);
    return d ? `Dr. ${d.firstName} ${d.lastName}` : `Médecin ${id.slice(0, 8)}…`;
  }

  openDetail(appointment: AppointmentSummary): void {
    this.selectedAppointment.set(appointment);
  }

  closeDetail(): void {
    this.selectedAppointment.set(null);
  }

  private setPatientSelf(userId: string): void {
    this.patientSelfId.set(userId);
    this.form.patientId = userId;
  }
}
