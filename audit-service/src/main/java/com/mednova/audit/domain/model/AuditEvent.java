package com.mednova.audit.domain.model;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

@Getter
@Builder
public class AuditEvent {

    private final UUID id;
    private final String eventId;
    private final String eventType;
    private final String source;
    private final String correlationId;
    private final String payload;
    private final Instant receivedAt;
}
