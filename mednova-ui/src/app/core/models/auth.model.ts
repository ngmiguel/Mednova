export type UserRole =
  | 'ROLE_ADMIN'
  | 'ROLE_DOCTOR'
  | 'ROLE_NURSE'
  | 'ROLE_PATIENT'
  | 'ROLE_AUDITOR';

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  tokenType: string;
  expiresIn: number;
  roles: UserRole[];
  requiresTwoFactor?: boolean;
  challengeToken?: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  role?: UserRole;
}

export interface ForgotPasswordRequest {
  email: string;
}

export interface VerifyOtpRequest {
  email: string;
  otp: string;
}

export interface ResetPasswordRequest {
  resetToken: string;
  newPassword: string;
}

export interface UserProfile {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  roles: UserRole[];
  twoFactorEnabled: boolean;
}

export interface TwoFactorVerifyRequest {
  challengeToken: string;
  code: string;
}

export interface DemoAccount {
  label: string;
  email: string;
  password: string;
  role: string;
}

export const DEMO_ACCOUNTS: DemoAccount[] = [
  { label: 'Administrateur', email: 'admin@mednova.ai', password: 'password123', role: 'Admin' },
  { label: 'Médecin — Dr. Smith', email: 'dr.smith@mednova.ai', password: 'password123', role: 'Doctor' },
  { label: 'Médecin — Dr. Dubois', email: 'dr.dubois@mednova.ai', password: 'password123', role: 'Cardiologue' },
  { label: 'Infirmier(ère) — Emma', email: 'nurse@mednova.ai', password: 'password123', role: 'Nurse' },
  { label: 'Infirmier(ère) — Julie', email: 'nurse.martin@mednova.ai', password: 'password123', role: 'Nurse' },
  { label: 'Patient — Jean', email: 'patient.test@mednova.ai', password: 'password123', role: 'Patient' },
  { label: 'Patient — Marie', email: 'marie.curie@mednova.ai', password: 'password123', role: 'Patient' },
  { label: 'Auditeur', email: 'auditor@mednova.ai', password: 'password123', role: 'Auditor' },
];
