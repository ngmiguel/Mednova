package com.mednova.messaging.presentation.dto;

import lombok.Builder;

import java.time.Instant;
import java.util.UUID;

@Builder
public record ConversationResponse(
        UUID id,
        UUID patientUserId,
        UUID doctorUserId,
        UUID patientId,
        UUID doctorId,
        String subject,
        Instant createdAt,
        Instant updatedAt
) {
}
