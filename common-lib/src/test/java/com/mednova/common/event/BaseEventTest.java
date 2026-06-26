package com.mednova.common.event;

import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

class BaseEventTest {

    @Test
    void of_createsEventWithDefaults() {
        BaseEvent<Map<String, String>> event = BaseEvent.of(
                EventTypes.VITALS_RECORDED,
                "monitoring-service",
                "corr-123",
                Map.of("patientId", "abc")
        );

        assertThat(event.eventId()).isNotBlank();
        assertThat(event.eventType()).isEqualTo(EventTypes.VITALS_RECORDED);
        assertThat(event.version()).isEqualTo(BaseEvent.DEFAULT_VERSION);
        assertThat(event.timestamp()).isNotNull();
        assertThat(event.source()).isEqualTo("monitoring-service");
        assertThat(event.correlationId()).isEqualTo("corr-123");
        assertThat(event.payload()).containsEntry("patientId", "abc");
    }
}
