import { HttpErrorResponse } from '@angular/common/http';

export function apiErrorMessage(err: unknown, fallback: string): string {
  if (!(err instanceof HttpErrorResponse)) {
    return fallback;
  }
  if (err.status === 0) {
    return 'Service indisponible — vérifiez que le backend est démarré';
  }
  const body = err.error as { message?: string } | null;
  if (body?.message) {
    return body.message;
  }
  if (err.status === 401) return 'Session expirée — reconnectez-vous';
  if (err.status === 403) return 'Accès refusé pour votre rôle';
  if (err.status === 503) return 'Service temporairement indisponible';
  return fallback;
}
