import { DatePipe } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { forkJoin } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ApiResponse } from '../../core/models/api-response.model';
import { PageResponse } from '../../core/models/page-response.model';
import { AuthService } from '../../core/services/auth.service';
import { ChatMessage, Conversation, MessagingService } from '../../core/services/messaging.service';
import { TokenStorageService } from '../../core/services/token-storage.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { AppIconComponent } from '../../shared/components/app-icon/app-icon.component';

interface PersonRow {
  id: string;
  userId?: string;
  firstName: string;
  lastName: string;
  specialty?: string;
}

export interface ChatContact {
  id: string;
  userId: string;
  firstName: string;
  lastName: string;
  specialty?: string;
  preview?: string;
  conversationId?: string;
  lastActivity?: string;
}

@Component({
  selector: 'app-messaging',
  standalone: true,
  imports: [FormsModule, DatePipe, AppIconComponent, TranslatePipe],
  templateUrl: './messaging.component.html',
  styleUrl: './messaging.component.scss',
})
export class MessagingComponent implements OnInit {
  private readonly messaging = inject(MessagingService);
  private readonly http = inject(HttpClient);
  private readonly tokenStorage = inject(TokenStorageService);
  readonly authService = inject(AuthService);

  readonly contacts = signal<ChatContact[]>([]);
  readonly conversations = signal<Conversation[]>([]);
  readonly messages = signal<ChatMessage[]>([]);
  readonly selectedContact = signal<ChatContact | null>(null);
  readonly doctorSelfId = signal<string | null>(null);
  readonly loading = signal(true);
  readonly opening = signal(false);
  readonly sending = signal(false);
  readonly error = signal<string | null>(null);

  searchQuery = '';
  draft = '';

  readonly filteredContacts = computed(() => {
    const q = this.searchQuery.trim().toLowerCase();
    const list = this.contacts();
    if (!q) return list;
    return list.filter((c) => `${c.firstName} ${c.lastName}`.toLowerCase().includes(q));
  });

  readonly isPatient = () => this.tokenStorage.hasRole('ROLE_PATIENT');
  readonly isDoctor = () => this.tokenStorage.hasRole('ROLE_DOCTOR');

  ngOnInit(): void {
    if (!this.authService.currentUser()) {
      this.authService.loadProfile().subscribe({ next: () => this.loadData() });
    } else {
      this.loadData();
    }
  }

  loadData(): void {
    this.loading.set(true);
    this.error.set(null);

    const contacts$ = this.isPatient()
      ? this.http.get<ApiResponse<PageResponse<PersonRow>>>(`${environment.apiBaseUrl}/doctors?size=100`)
      : this.http.get<ApiResponse<PageResponse<PersonRow>>>(`${environment.apiBaseUrl}/patients?size=100`);

    const doctors$ = this.isDoctor()
      ? this.http.get<ApiResponse<PageResponse<PersonRow>>>(`${environment.apiBaseUrl}/doctors?size=100`)
      : null;

    const requests: {
      people: ReturnType<HttpClient['get']>;
      conversations: ReturnType<MessagingService['listConversations']>;
      doctors?: ReturnType<HttpClient['get']>;
    } = {
      people: contacts$,
      conversations: this.messaging.listConversations(),
    };
    if (doctors$) requests.doctors = doctors$;

    forkJoin(requests).subscribe({
      next: (result) => {
        const people = result.people as ApiResponse<PageResponse<PersonRow>>;
        const conversations = result.conversations as ApiResponse<Conversation[]>;
        const doctors = result.doctors as ApiResponse<PageResponse<PersonRow>> | undefined;

        if (doctors && this.isDoctor()) {
          const me = this.authService.currentUser()?.id;
          const self = doctors.data?.content?.find((d) => d.userId === me || d.id === me);
          this.doctorSelfId.set(self?.id ?? me ?? null);
        }

        this.conversations.set(conversations.data ?? []);
        this.contacts.set(this.buildContacts(people.data?.content ?? [], conversations.data ?? []));
        this.loading.set(false);
      },
      error: () => {
        this.error.set('Impossible de charger la messagerie');
        this.loading.set(false);
      },
    });
  }

  selectContact(contact: ChatContact): void {
    this.selectedContact.set(contact);
    if (contact.conversationId) {
      this.loadMessages(contact.conversationId);
      return;
    }
    this.messages.set([]);
    this.openConversation(contact);
  }

  send(): void {
    const contact = this.selectedContact();
    const content = this.draft.trim();
    if (!contact?.conversationId || !content) return;

    this.sending.set(true);
    this.messaging.sendMessage(contact.conversationId, content).subscribe({
      next: (res) => {
        if (res.data) {
          this.messages.update((m) => [...m, res.data!]);
          this.touchContact(contact.id, res.data.content, res.data.sentAt);
        }
        this.draft = '';
        this.sending.set(false);
      },
      error: () => this.sending.set(false),
    });
  }

  isMine(msg: ChatMessage): boolean {
    const user = this.authService.currentUser();
    return !!user && msg.senderUserId === user.id;
  }

  initials(contact: ChatContact): string {
    return `${contact.firstName.charAt(0)}${contact.lastName.charAt(0)}`.toUpperCase();
  }

  private buildContacts(people: PersonRow[], conversations: Conversation[]): ChatContact[] {
    const convByPeer = new Map<string, Conversation>();

    for (const c of conversations) {
      const peerUserId = this.isPatient() ? c.doctorUserId : c.patientUserId;
      convByPeer.set(peerUserId, c);
    }

    const contacts: ChatContact[] = people.map((p) => {
      const userId = p.userId ?? p.id;
      const conv = convByPeer.get(userId);
      return {
        id: p.id,
        userId,
        firstName: p.firstName,
        lastName: p.lastName,
        specialty: this.isPatient() ? p.specialty?.replace(/_/g, ' ') : undefined,
        conversationId: conv?.id,
        lastActivity: conv?.updatedAt,
      };
    });

    return contacts.sort((a, b) => {
      if (a.lastActivity && b.lastActivity) {
        return new Date(b.lastActivity).getTime() - new Date(a.lastActivity).getTime();
      }
      if (a.lastActivity) return -1;
      if (b.lastActivity) return 1;
      return a.lastName.localeCompare(b.lastName);
    });
  }

  private openConversation(contact: ChatContact): void {
    const me = this.authService.currentUser();
    if (!me) return;

    this.opening.set(true);
    const body = this.isPatient()
      ? {
          patientUserId: me.id,
          doctorUserId: contact.userId,
          patientId: me.id,
          doctorId: contact.id,
        }
      : {
          patientUserId: contact.userId,
          doctorUserId: me.id,
          patientId: contact.id,
          doctorId: this.doctorSelfId() ?? me.id,
        };

    this.messaging.createConversation(body).subscribe({
      next: (res) => {
        this.opening.set(false);
        if (!res.data) return;
        const conv = res.data;
        this.conversations.update((list) => [conv, ...list.filter((c) => c.id !== conv.id)]);
        this.patchContactConversation(contact.id, conv.id, conv.updatedAt);
        this.selectedContact.update((c) =>
          c?.id === contact.id ? { ...c, conversationId: conv.id, lastActivity: conv.updatedAt } : c
        );
        this.loadMessages(conv.id);
      },
      error: () => {
        this.opening.set(false);
        this.error.set('Impossible d\'ouvrir la conversation');
      },
    });
  }

  private loadMessages(conversationId: string): void {
    this.messaging.listMessages(conversationId).subscribe({
      next: (res) => {
        this.messages.set(res.data ?? []);
        this.messaging.markRead(conversationId).subscribe();
        const last = res.data?.at(-1);
        const contact = this.selectedContact();
        if (last && contact) {
          this.touchContact(contact.id, last.content, last.sentAt);
        }
      },
    });
  }

  private patchContactConversation(contactId: string, conversationId: string, lastActivity: string): void {
    this.contacts.update((list) =>
      list.map((c) => (c.id === contactId ? { ...c, conversationId, lastActivity } : c))
    );
  }

  private touchContact(contactId: string, preview: string, at: string): void {
    this.contacts.update((list) => {
      const updated = list.map((c) =>
        c.id === contactId ? { ...c, lastActivity: at, preview } : c
      );
      return updated.sort((a, b) => {
        if (a.lastActivity && b.lastActivity) {
          return new Date(b.lastActivity).getTime() - new Date(a.lastActivity).getTime();
        }
        return 0;
      });
    });
  }
}
