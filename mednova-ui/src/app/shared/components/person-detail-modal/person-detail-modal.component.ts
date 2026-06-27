import { Component, HostListener, inject } from '@angular/core';
import { PersonDetailModalService } from '../../../core/services/person-detail-modal.service';
import { TranslatePipe } from '../../../core/i18n/translate.pipe';
import { AppIconComponent } from '../app-icon/app-icon.component';

@Component({
  selector: 'app-person-detail-modal',
  standalone: true,
  imports: [AppIconComponent, TranslatePipe],
  templateUrl: './person-detail-modal.component.html',
  styleUrl: './person-detail-modal.component.scss',
})
export class PersonDetailModalComponent {
  readonly modal = inject(PersonDetailModalService);

  @HostListener('document:keydown.escape')
  onEscape(): void {
    if (this.modal.open()) {
      this.modal.close();
    }
  }

  onBackdropClick(event: MouseEvent): void {
    if ((event.target as HTMLElement).classList.contains('modal-backdrop')) {
      this.modal.close();
    }
  }
}
