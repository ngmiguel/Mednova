package com.mednova.notification.presentation.dto;

import com.mednova.notification.domain.model.NotificationChannel;
import com.mednova.notification.domain.model.NotificationStatus;
import com.mednova.notification.domain.model.NotificationType;

import java.time.Instant;
import java.util.UUID;

public record NotificationResponse(
        UUID id,
        UUID patientId,
        NotificationType type,
        NotificationChannel channel,
        String title,
        String message,
        NotificationStatus status,
        String targetRole,
        String sourceEventType,
        Instant createdAt,
        Instant readAt
) {
}
