package com.mednova.messaging.presentation.dto;

import lombok.Builder;

import java.time.Instant;
import java.util.UUID;

@Builder
public record MessageResponse(
        UUID id,
        UUID conversationId,
        UUID senderUserId,
        String content,
        Instant sentAt,
        Instant readAt
) {
}
