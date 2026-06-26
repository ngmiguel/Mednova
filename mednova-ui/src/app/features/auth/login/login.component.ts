import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [ReactiveFormsModule],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss',
})
export class LoginComponent {
  private readonly fb = inject(FormBuilder);
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);

  readonly loading = signal(false);
  readonly error = signal<string | null>(null);
  readonly twoFactorStep = signal(false);
  readonly challengeToken = signal('');

  readonly form = this.fb.nonNullable.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', Validators.required],
    code: [''],
  });

  submit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    this.loading.set(true);
    this.error.set(null);

    if (this.twoFactorStep()) {
      this.authService
        .verifyTwoFactor({
          challengeToken: this.challengeToken(),
          code: this.form.controls.code.value,
        })
        .subscribe({
          next: () => this.finishLogin(),
          error: (err) => this.handleError(err),
        });
      return;
    }

    const { email, password } = this.form.getRawValue();
    this.authService.login({ email, password }).subscribe({
      next: (response) => {
        if (response.data.requiresTwoFactor) {
          this.twoFactorStep.set(true);
          this.challengeToken.set(response.data.challengeToken ?? '');
          this.loading.set(false);
          return;
        }
        this.finishLogin();
      },
      error: (err) => this.handleError(err),
    });
  }

  private finishLogin(): void {
    this.authService.loadProfile().subscribe({
      next: () => {
        this.loading.set(false);
        void this.router.navigate(['/dashboard']);
      },
      error: (err) => this.handleError(err),
    });
  }

  private handleError(err: { error?: { message?: string } }): void {
    this.loading.set(false);
    this.error.set(err.error?.message ?? 'Connexion impossible');
  }
}
