package com.mednova.common.event;

import java.time.Instant;
import java.util.UUID;

public record BaseEvent<T>(
        String eventId,
        String eventType,
        String version,
        Instant timestamp,
        String source,
        String correlationId,
        T payload
) {

    public static final String DEFAULT_VERSION = "1.0";

    public static <T> BaseEvent<T> of(String eventType, String source, String correlationId, T payload) {
        return new BaseEvent<>(
                UUID.randomUUID().toString(),
                eventType,
                DEFAULT_VERSION,
                Instant.now(),
                source,
                correlationId,
                payload
        );
    }
}
