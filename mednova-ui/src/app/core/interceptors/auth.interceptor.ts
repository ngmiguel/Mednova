import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { TokenStorageService } from '../services/token-storage.service';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const tokenStorage = inject(TokenStorageService);
  const token = tokenStorage.getAccessToken();

  const isApiRequest =
    req.url.includes('/api/v1') || req.url.startsWith('/api/');

  if (token && isApiRequest) {
    return next(
      req.clone({
        setHeaders: { Authorization: `Bearer ${token}` },
      })
    );
  }

  return next(req);
};
