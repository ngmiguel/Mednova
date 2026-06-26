package com.mednova.notification.domain.model;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

@Getter
@Builder
public class Notification {

    private UUID id;
    private UUID patientId;
    private NotificationType type;
    private NotificationChannel channel;
    private String title;
    private String message;
    private NotificationStatus status;
    private String targetRole;
    private String sourceEventType;
    private String correlationId;
    private Instant createdAt;
    private Instant readAt;

    public void markAsRead(Instant readAt) {
        this.status = NotificationStatus.READ;
        this.readAt = readAt;
    }
}
