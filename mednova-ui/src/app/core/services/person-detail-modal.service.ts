import { Injectable, inject, signal } from '@angular/core';
import { forkJoin, of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { I18nService } from '../i18n/i18n.service';
import { DoctorDetail, DoctorService } from './doctor.service';
import { PatientDetail, PatientService } from './patient.service';
import { TokenStorageService } from './token-storage.service';
import { UserAccountDetail, UserAdminService } from './user-admin.service';
import { AuthService } from './auth.service';

export type PersonDetailKind = 'patient' | 'doctor' | 'staff';

export interface PersonDetailField {
  labelKey: string;
  value: string;
}

export interface PersonDetailViewModel {
  kind: PersonDetailKind;
  id: string;
  userId?: string;
  title: string;
  subtitle?: string;
  initials: string;
  avatarColor: string;
  fields: PersonDetailField[];
  account?: UserAccountDetail;
}

@Injectable({ providedIn: 'root' })
export class PersonDetailModalService {
  private readonly patientService = inject(PatientService);
  private readonly doctorService = inject(DoctorService);
  private readonly userAdminService = inject(UserAdminService);
  private readonly tokenStorage = inject(TokenStorageService);
  private readonly authService = inject(AuthService);
  private readonly i18n = inject(I18nService);

  readonly open = signal(false);
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly error = signal<string | null>(null);
  readonly view = signal<PersonDetailViewModel | null>(null);

  readonly canBlockAccess = () => this.tokenStorage.hasRole('ROLE_ADMIN');

  openPatient(id: string): void {
    this.load('patient', id);
  }

  openDoctor(id: string): void {
    this.load('doctor', id);
  }

  openStaff(userId: string): void {
    this.loadStaff(userId);
  }

  close(): void {
    this.open.set(false);
    this.loading.set(false);
    this.saving.set(false);
    this.error.set(null);
    this.view.set(null);
  }

  toggleAccess(): void {
    const current = this.view();
    if (!current?.account || !this.canBlockAccess()) return;

    const nextEnabled = !current.account.enabled;
    const userId = current.account.id;
    this.saving.set(true);
    this.error.set(null);

    this.userAdminService.setAccess(userId, nextEnabled).subscribe({
      next: (res) => {
        if (res.data) {
          this.view.update((v) => (v ? { ...v, account: res.data! } : v));
        }
        this.saving.set(false);
      },
      error: () => {
        this.error.set(this.i18n.t('modal.error.access'));
        this.saving.set(false);
      },
    });
  }

  private load(kind: PersonDetailKind, id: string): void {
    this.open.set(true);
    this.loading.set(true);
    this.error.set(null);
    this.view.set(null);

    const handleDetail = (detail: PatientDetail | DoctorDetail | undefined) => {
      if (!detail) {
        this.error.set(this.i18n.t('modal.error.load'));
        this.loading.set(false);
        return;
      }
      this.attachAccountIfAdmin(detail, kind);
    };

    if (kind === 'patient') {
      this.patientService.getById(id).subscribe({
        next: (res) => handleDetail(res.data),
        error: () => {
          this.error.set(this.i18n.t('modal.error.load'));
          this.loading.set(false);
        },
      });
      return;
    }

    this.doctorService.getById(id).subscribe({
      next: (res) => handleDetail(res.data),
      error: () => {
        this.error.set(this.i18n.t('modal.error.load'));
        this.loading.set(false);
      },
    });
  }

  private loadStaff(userId: string): void {
    if (!this.canBlockAccess()) {
      return;
    }
    this.open.set(true);
    this.loading.set(true);
    this.error.set(null);
    this.view.set(null);

    this.userAdminService.getById(userId).subscribe({
      next: (res) => {
        if (!res.data) {
          this.error.set(this.i18n.t('modal.error.load'));
          this.loading.set(false);
          return;
        }
        this.view.set(this.mapStaff(res.data));
        this.loading.set(false);
      },
      error: () => {
        this.error.set(this.i18n.t('modal.error.load'));
        this.loading.set(false);
      },
    });
  }

  private attachAccountIfAdmin(
    detail: PatientDetail | DoctorDetail,
    kind: PersonDetailKind
  ): void {
    const userId = detail.userId;
    if (this.canBlockAccess() && userId) {
      forkJoin({
        account: this.userAdminService.getById(userId).pipe(catchError(() => of(null))),
      }).subscribe({
        next: ({ account }) => {
          this.view.set(this.mapEntity(detail, kind, account?.data ?? undefined));
          this.loading.set(false);
        },
      });
      return;
    }

    this.view.set(this.mapEntity(detail, kind));
    this.loading.set(false);
  }

  private mapEntity(
    detail: PatientDetail | DoctorDetail,
    kind: PersonDetailKind,
    account?: UserAccountDetail
  ): PersonDetailViewModel {
    const name = `${detail.firstName} ${detail.lastName}`;
    const fields: PersonDetailField[] = [
      { labelKey: 'modal.field.email', value: detail.email },
    ];

    if (detail.phone) {
      fields.push({ labelKey: 'modal.field.phone', value: detail.phone });
    }

    if (kind === 'patient') {
      const patient = detail as PatientDetail;
      if (patient.dateOfBirth) {
        fields.push({ labelKey: 'modal.field.birthDate', value: patient.dateOfBirth });
      }
      if (patient.gender) {
        fields.push({
          labelKey: 'modal.field.gender',
          value: patient.gender === 'M' ? this.i18n.t('modal.gender.male') : this.i18n.t('modal.gender.female'),
        });
      }
      if (patient.bloodType) {
        fields.push({ labelKey: 'modal.field.bloodType', value: patient.bloodType.replace('_', ' ') });
      }
      if (patient.address) {
        fields.push({ labelKey: 'modal.field.address', value: patient.address });
      }
      if (patient.emergencyContact) {
        fields.push({ labelKey: 'modal.field.emergency', value: patient.emergencyContact });
      }
    } else {
      const doctor = detail as DoctorDetail;
      if (doctor.specialty) {
        fields.push({ labelKey: 'modal.field.specialty', value: this.specialtyLabel(doctor.specialty) });
      }
      if (doctor.licenseNumber) {
        fields.push({ labelKey: 'modal.field.license', value: doctor.licenseNumber });
      }
      if (doctor.bio) {
        fields.push({ labelKey: 'modal.field.bio', value: doctor.bio });
      }
      fields.push({
        labelKey: 'modal.field.profileStatus',
        value: doctor.active !== false ? this.i18n.t('modal.status.available') : this.i18n.t('modal.status.inactive'),
      });
    }

    if (detail.createdAt) {
      fields.push({
        labelKey: 'modal.field.createdAt',
        value: new Date(detail.createdAt).toLocaleString(),
      });
    }

    return {
      kind,
      id: detail.id,
      userId: detail.userId,
      title: kind === 'doctor' ? `Dr. ${name}` : name,
      subtitle: kind === 'patient' ? this.i18n.t('modal.subtitle.patient') : this.i18n.t('modal.subtitle.doctor'),
      initials: `${detail.firstName.charAt(0)}${detail.lastName.charAt(0)}`.toUpperCase(),
      avatarColor: this.avatarColor(detail.firstName),
      fields,
      account,
    };
  }

  private mapStaff(account: UserAccountDetail): PersonDetailViewModel {
    const role = account.roles[0]?.replace('ROLE_', '') ?? 'USER';
    return {
      kind: 'staff',
      id: account.id,
      userId: account.id,
      title: `${account.firstName} ${account.lastName}`,
      subtitle: this.i18n.t('modal.subtitle.staff'),
      initials: `${account.firstName.charAt(0)}${account.lastName.charAt(0)}`.toUpperCase(),
      avatarColor: this.avatarColor(account.firstName),
      fields: [
        { labelKey: 'modal.field.email', value: account.email },
        { labelKey: 'modal.field.role', value: role },
        {
          labelKey: 'modal.field.twoFactor',
          value: account.twoFactorEnabled ? this.i18n.t('modal.status.enabled') : this.i18n.t('modal.status.disabled'),
        },
        {
          labelKey: 'modal.field.createdAt',
          value: account.createdAt ? new Date(account.createdAt).toLocaleString() : '—',
        },
      ],
      account,
    };
  }

  isSelfAccount(): boolean {
    const view = this.view();
    const me = this.authService.currentUser()?.id;
    return !!view?.userId && !!me && view.userId === me;
  }

  private specialtyLabel(spec: string): string {
    const map: Record<string, string> = {
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
    return map[spec] ?? spec.replace(/_/g, ' ');
  }

  private avatarColor(name: string): string {
    const colors = ['#0d9488', '#6366f1', '#8b5cf6', '#ec4899', '#f59e0b'];
    return colors[name.charCodeAt(0) % colors.length];
  }
}
