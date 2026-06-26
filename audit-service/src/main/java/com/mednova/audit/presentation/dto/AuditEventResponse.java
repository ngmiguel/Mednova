package com.mednova.audit.presentation.dto;

import java.time.Instant;
import java.util.UUID;

public record AuditEventResponse(
        UUID id,
        String eventId,
        String eventType,
        String source,
        String correlationId,
        String payload,
        Instant receivedAt
) {
}
