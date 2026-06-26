package com.mednova.notification.application.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.mednova.common.event.EventTypes;
import com.mednova.notification.domain.model.NotificationType;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class DomainEventHandlerTest {

    @Mock
    private NotificationApplicationService notificationApplicationService;

    private DomainEventHandler handler;

    @BeforeEach
    void setUp() {
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        handler = new DomainEventHandler(notificationApplicationService, objectMapper);
    }

    @Test
    void handle_healthAlertTriggered_createsStaffAlertWithEmail() {
        UUID patientId = UUID.randomUUID();
        String message = """
                {
                  "eventType": "HEALTH_ALERT_TRIGGERED",
                  "correlationId": "corr-1",
                  "payload": {
                    "assessmentId": "%s",
                    "patientId": "%s",
                    "riskLevel": "CRITICAL",
                    "riskScore": 100,
                    "message": "Alerte critique"
                  }
                }
                """.formatted(UUID.randomUUID(), patientId);

        handler.handle(message);

        verify(notificationApplicationService).createStaffAlert(
                eq(patientId),
                eq(NotificationType.HEALTH_ALERT),
                eq("Alerte santé CRITICAL"),
                contains("score 100/100"),
                eq(EventTypes.HEALTH_ALERT_TRIGGERED),
                eq("corr-1"),
                eq(true)
        );
    }

    @Test
    void handle_appointmentScheduled_createsStaffAndPatientNotifications() {
        UUID patientId = UUID.randomUUID();
        String message = """
                {
                  "eventType": "APPOINTMENT_SCHEDULED",
                  "correlationId": "corr-2",
                  "payload": {
                    "appointmentId": "%s",
                    "patientId": "%s",
                    "doctorId": "%s",
                    "scheduledAt": "2026-07-01T10:00:00Z",
                    "reason": "Contrôle"
                  }
                }
                """.formatted(UUID.randomUUID(), patientId, UUID.randomUUID());

        handler.handle(message);

        verify(notificationApplicationService).createStaffAlert(
                eq(patientId),
                eq(NotificationType.APPOINTMENT_SCHEDULED),
                eq("Nouveau rendez-vous"),
                contains("RDV planifié"),
                eq(EventTypes.APPOINTMENT_SCHEDULED),
                eq("corr-2"),
                eq(false)
        );
        verify(notificationApplicationService).createPatientNotification(
                eq(patientId),
                eq(NotificationType.APPOINTMENT_SCHEDULED),
                eq("Rendez-vous confirmé"),
                contains("confirmé"),
                eq(EventTypes.APPOINTMENT_SCHEDULED),
                eq("corr-2")
        );
    }

    @Test
    void handle_unknownEventType_isIgnored() {
        handler.handle("{\"eventType\":\"PATIENT_CREATED\",\"payload\":{}}");

        verifyNoInteractions(notificationApplicationService);
    }
}
