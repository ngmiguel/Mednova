import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ApiResponse } from '../models/api-response.model';

export interface Conversation {
  id: string;
  patientUserId: string;
  doctorUserId: string;
  patientId?: string;
  doctorId?: string;
  subject?: string;
  createdAt: string;
  updatedAt: string;
}

export interface ChatMessage {
  id: string;
  conversationId: string;
  senderUserId: string;
  content: string;
  sentAt: string;
  readAt?: string;
}

@Injectable({ providedIn: 'root' })
export class MessagingService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiBaseUrl}/messaging`;

  listConversations(): Observable<ApiResponse<Conversation[]>> {
    return this.http.get<ApiResponse<Conversation[]>>(`${this.base}/conversations`);
  }

  createConversation(body: {
    patientUserId: string;
    doctorUserId: string;
    patientId?: string;
    doctorId?: string;
    subject?: string;
  }): Observable<ApiResponse<Conversation>> {
    return this.http.post<ApiResponse<Conversation>>(`${this.base}/conversations`, body);
  }

  listMessages(conversationId: string): Observable<ApiResponse<ChatMessage[]>> {
    return this.http.get<ApiResponse<ChatMessage[]>>(`${this.base}/conversations/${conversationId}/messages`);
  }

  sendMessage(conversationId: string, content: string): Observable<ApiResponse<ChatMessage>> {
    return this.http.post<ApiResponse<ChatMessage>>(`${this.base}/conversations/${conversationId}/messages`, { content });
  }

  markRead(conversationId: string): Observable<ApiResponse<{ status: string }>> {
    return this.http.patch<ApiResponse<{ status: string }>>(`${this.base}/conversations/${conversationId}/read`, {});
  }
}
