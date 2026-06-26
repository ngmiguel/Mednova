import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';
import { SettingsService } from '../../../core/services/settings.service';
import { TokenStorageService } from '../../../core/services/token-storage.service';
import { DEMO_ACCOUNTS, UserRole } from '../../../core/models/auth.model';
import { extractErrorMessage, passwordStrength } from '../../../core/utils/auth.utils';

type AuthView = 'login' | 'register' | 'forgot-email' | 'forgot-otp' | 'forgot-reset' | 'two-factor';

@Component({
  selector: 'app-auth-page',
  standalone: true,
  imports: [ReactiveFormsModule],
  templateUrl: './auth-page.component.html',
  styleUrl: './auth-page.component.scss',
})
export class AuthPageComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly authService = inject(AuthService);
  private readonly settingsService = inject(SettingsService);
  private readonly tokenStorage = inject(TokenStorageService);
  private readonly router = inject(Router);
  private readonly route = inject(ActivatedRoute);

  readonly demoAccounts = DEMO_ACCOUNTS;
  readonly roles: { value: UserRole; label: string }[] = [
    { value: 'ROLE_PATIENT', label: 'Patient' },
    { value: 'ROLE_DOCTOR', label: 'Médecin' },
  ];

  readonly view = signal<AuthView>('login');
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);
  readonly success = signal<string | null>(null);
  readonly showPassword = signal(false);
  readonly showNewPassword = signal(false);
  readonly showDemoPicker = signal(false);
  readonly challengeToken = signal('');
  readonly resetToken = signal('');
  readonly forgotEmail = signal('');

  readonly loginForm = this.fb.nonNullable.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', Validators.required],
    rememberMe: [true],
    code: [''],
  });

  readonly registerForm = this.fb.nonNullable.group({
    firstName: ['', Validators.required],
    lastName: ['', Validators.required],
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(8)]],
    confirmPassword: ['', Validators.required],
    role: ['ROLE_PATIENT' as UserRole],
    acceptTerms: [false, Validators.requiredTrue],
  });

  readonly forgotEmailForm = this.fb.nonNullable.group({
    email: ['', [Validators.required, Validators.email]],
  });

  readonly forgotOtpForm = this.fb.nonNullable.group({
    otp: ['', [Validators.required, Validators.pattern(/^\d{6}$/)]],
  });

  readonly forgotResetForm = this.fb.nonNullable.group({
    newPassword: ['', [Validators.required, Validators.minLength(8)]],
    confirmPassword: ['', Validators.required],
  });

  readonly registerPasswordStrength = computed(() =>
    passwordStrength(this.registerForm.controls.password.value)
  );

  readonly resetPasswordStrength = computed(() =>
    passwordStrength(this.forgotResetForm.controls.newPassword.value)
  );

  ngOnInit(): void {
    if (this.settingsService.get().rememberEmail) {
      const remembered = this.tokenStorage.getRememberedEmail();
      if (remembered) {
        this.loginForm.patchValue({ email: remembered, rememberMe: true });
      }
    }
    if (this.route.snapshot.queryParamMap.get('expired') === '1') {
      this.error.set('Session expirée — reconnectez-vous.');
    }
    if (this.tokenStorage.isLoggedIn()) {
      void this.router.navigate(['/dashboard']);
    }
  }

  setView(view: AuthView): void {
    this.view.set(view);
    this.error.set(null);
    this.success.set(null);
  }

  togglePassword(): void {
    this.showPassword.update((v) => !v);
  }

  toggleNewPassword(): void {
    this.showNewPassword.update((v) => !v);
  }

  toggleDemoPicker(): void {
    this.showDemoPicker.update((v) => !v);
  }

  fillDemo(email: string, password: string): void {
    this.loginForm.patchValue({ email, password });
    this.showDemoPicker.set(false);
    this.setView('login');
  }

  submitLogin(): void {
    if (this.loginForm.invalid) {
      this.loginForm.markAllAsTouched();
      return;
    }
    this.loading.set(true);
    this.error.set(null);

    if (this.view() === 'two-factor') {
      this.authService
        .verifyTwoFactor({
          challengeToken: this.challengeToken(),
          code: this.loginForm.controls.code.value,
        })
        .subscribe({
          next: () => this.finishLogin(),
          error: (err) => this.fail(extractErrorMessage(err, 'Code 2FA invalide')),
        });
      return;
    }

    const { email, password, rememberMe } = this.loginForm.getRawValue();
    this.settingsService.update({ staySignedIn: rememberMe });
    this.authService.login({ email, password }).subscribe({
      next: (response) => {
        if (response.data?.requiresTwoFactor) {
          this.challengeToken.set(response.data.challengeToken ?? '');
          this.view.set('two-factor');
          this.loading.set(false);
          return;
        }
        if (rememberMe && this.settingsService.get().rememberEmail) {
          this.tokenStorage.saveRememberedEmail(email);
        } else {
          this.tokenStorage.clearRememberedEmail();
        }
        this.finishLogin();
      },
      error: (err) => this.fail(extractErrorMessage(err, 'Email ou mot de passe incorrect')),
    });
  }

  submitRegister(): void {
    if (this.registerForm.invalid) {
      this.registerForm.markAllAsTouched();
      return;
    }
    const form = this.registerForm.getRawValue();
    if (form.password !== form.confirmPassword) {
      this.error.set('Les mots de passe ne correspondent pas');
      return;
    }
    this.loading.set(true);
    this.error.set(null);
    this.authService
      .register({
        email: form.email,
        password: form.password,
        firstName: form.firstName,
        lastName: form.lastName,
        role: form.role,
      })
      .subscribe({
        next: () => this.finishLogin(),
        error: (err) => this.fail(extractErrorMessage(err, 'Inscription impossible')),
      });
  }

  submitForgotEmail(): void {
    if (this.forgotEmailForm.invalid) {
      this.forgotEmailForm.markAllAsTouched();
      return;
    }
    const email = this.forgotEmailForm.controls.email.value;
    this.loading.set(true);
    this.error.set(null);
    this.authService.forgotPassword({ email }).subscribe({
      next: (res) => {
        this.forgotEmail.set(email);
        this.loading.set(false);
        this.success.set(res.message ?? 'Code envoyé par email');
        this.view.set('forgot-otp');
      },
      error: (err) => this.fail(extractErrorMessage(err, 'Envoi impossible')),
    });
  }

  submitForgotOtp(): void {
    if (this.forgotOtpForm.invalid) {
      this.forgotOtpForm.markAllAsTouched();
      return;
    }
    this.loading.set(true);
    this.error.set(null);
    this.authService
      .verifyPasswordOtp({ email: this.forgotEmail(), otp: this.forgotOtpForm.controls.otp.value })
      .subscribe({
        next: (res) => {
          this.resetToken.set(res.data.resetToken);
          this.loading.set(false);
          this.view.set('forgot-reset');
        },
        error: (err) => this.fail(extractErrorMessage(err, 'Code OTP invalide')),
      });
  }

  submitForgotReset(): void {
    if (this.forgotResetForm.invalid) {
      this.forgotResetForm.markAllAsTouched();
      return;
    }
    const { newPassword, confirmPassword } = this.forgotResetForm.getRawValue();
    if (newPassword !== confirmPassword) {
      this.error.set('Les mots de passe ne correspondent pas');
      return;
    }
    this.loading.set(true);
    this.error.set(null);
    this.authService.resetPassword({ resetToken: this.resetToken(), newPassword }).subscribe({
      next: () => {
        this.loading.set(false);
        this.success.set('Mot de passe mis à jour');
        this.loginForm.patchValue({ email: this.forgotEmail(), password: '' });
        this.view.set('login');
      },
      error: (err) => this.fail(extractErrorMessage(err, 'Réinitialisation impossible')),
    });
  }

  onSocialLogin(provider: string): void {
    this.error.set(`Connexion ${provider} — OAuth2 à configurer côté serveur`);
  }

  private finishLogin(): void {
    this.authService.loadProfile().subscribe({
      next: () => {
        this.loading.set(false);
        void this.router.navigate(['/dashboard']);
      },
      error: (err) => this.fail(extractErrorMessage(err, 'Impossible de charger le profil')),
    });
  }

  private fail(message: string): void {
    this.loading.set(false);
    this.error.set(message);
  }
}
