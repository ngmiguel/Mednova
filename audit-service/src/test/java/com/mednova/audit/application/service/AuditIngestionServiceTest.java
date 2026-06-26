package com.mednova.audit.application.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mednova.audit.domain.model.AuditEvent;
import com.mednova.audit.domain.port.AuditEventRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AuditIngestionServiceTest {

    @Mock
    private AuditEventRepository auditEventRepository;

    private AuditIngestionService service;

    @BeforeEach
    void setUp() {
        service = new AuditIngestionService(auditEventRepository, new ObjectMapper());
    }

    @Test
    void ingest_validMessage_persistsEvent() {
        String eventId = UUID.randomUUID().toString();
        when(auditEventRepository.findByEventId(eventId)).thenReturn(Optional.empty());

        service.ingest("""
                {
                  "eventId": "%s",
                  "eventType": "PATIENT_CREATED",
                  "source": "patient-service",
                  "correlationId": "corr-1",
                  "payload": {"patientId": "abc"}
                }
                """.formatted(eventId));

        ArgumentCaptor<AuditEvent> captor = ArgumentCaptor.forClass(AuditEvent.class);
        verify(auditEventRepository).save(captor.capture());
        assertThat(captor.getValue().getEventId()).isEqualTo(eventId);
        assertThat(captor.getValue().getEventType()).isEqualTo("PATIENT_CREATED");
    }

    @Test
    void ingest_missingEventId_isSkipped() {
        service.ingest("{\"eventType\":\"PATIENT_CREATED\"}");

        verify(auditEventRepository, never()).save(any());
    }

    @Test
    void ingest_duplicateEventId_isSkipped() {
        String eventId = UUID.randomUUID().toString();
        when(auditEventRepository.findByEventId(eventId))
                .thenReturn(Optional.of(AuditEvent.builder().eventId(eventId).build()));

        service.ingest("{\"eventId\":\"%s\",\"eventType\":\"PATIENT_CREATED\"}".formatted(eventId));

        verify(auditEventRepository, never()).save(any());
    }

    @Test
    void ingest_malformedJson_doesNotThrow() {
        service.ingest("{not-json");

        verify(auditEventRepository, never()).save(any());
    }
}
