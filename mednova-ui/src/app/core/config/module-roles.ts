import { UserRole } from '../models/auth.model';

/** Rôles autorisés par module — alignés sur la matrice RBAC backend (README). */
export const MODULE_ROLES = {
  patients: ['ROLE_ADMIN', 'ROLE_DOCTOR', 'ROLE_NURSE', 'ROLE_AUDITOR'] as UserRole[],
  doctors: ['ROLE_ADMIN', 'ROLE_DOCTOR', 'ROLE_NURSE', 'ROLE_PATIENT', 'ROLE_AUDITOR'] as UserRole[],
  appointments: ['ROLE_ADMIN', 'ROLE_DOCTOR', 'ROLE_NURSE', 'ROLE_PATIENT', 'ROLE_AUDITOR'] as UserRole[],
  messaging: ['ROLE_DOCTOR', 'ROLE_PATIENT'] as UserRole[],
  ai: ['ROLE_ADMIN', 'ROLE_DOCTOR', 'ROLE_NURSE', 'ROLE_AUDITOR', 'ROLE_PATIENT'] as UserRole[],
  notifications: ['ROLE_ADMIN', 'ROLE_DOCTOR', 'ROLE_NURSE', 'ROLE_AUDITOR', 'ROLE_PATIENT'] as UserRole[],
  audit: ['ROLE_ADMIN', 'ROLE_AUDITOR'] as UserRole[],
  monitoring: ['ROLE_ADMIN', 'ROLE_DOCTOR', 'ROLE_NURSE', 'ROLE_PATIENT', 'ROLE_AUDITOR'] as UserRole[],
} as const;
