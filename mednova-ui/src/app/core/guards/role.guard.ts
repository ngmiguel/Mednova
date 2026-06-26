import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { TokenStorageService } from '../services/token-storage.service';

export const roleGuard = (allowedRoles: string[]): CanActivateFn => {
  return () => {
    const tokenStorage = inject(TokenStorageService);
    const router = inject(Router);

    const hasRole = allowedRoles.some((role) => tokenStorage.hasRole(role));
    return hasRole ? true : router.createUrlTree(['/dashboard']);
  };
};
