import { HttpErrorResponse } from '@angular/common/http';
import { ApiResponse } from '../models/api-response.model';

interface ErrorBody {
  message?: string;
  success?: boolean;
  details?: { field: string; message: string }[];
}

export function extractErrorMessage(error: unknown, fallback = 'Une erreur est survenue'): string {
  if (!(error instanceof HttpErrorResponse)) {
    return fallback;
  }

  const body = error.error as ErrorBody | null;
  if (!body) {
    return fallback;
  }

  if (body.details?.length) {
    return body.details.map((d) => d.message).join(' · ');
  }

  if (body.message) {
    return body.message;
  }

  const apiBody = body as ApiResponse<unknown>;
  if (apiBody.success === false && apiBody.message) {
    return apiBody.message;
  }

  return fallback;
}

export function passwordStrength(password: string): { score: number; label: string; color: string } {
  let score = 0;
  if (password.length >= 8) score++;
  if (password.length >= 12) score++;
  if (/[A-Z]/.test(password)) score++;
  if (/[0-9]/.test(password)) score++;
  if (/[^A-Za-z0-9]/.test(password)) score++;

  if (score <= 1) return { score, label: 'Faible', color: '#dc2626' };
  if (score <= 3) return { score, label: 'Moyen', color: '#d97706' };
  return { score, label: 'Fort', color: '#059669' };
}
