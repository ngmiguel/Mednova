package com.mednova.notification.application.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mednova.common.event.EventTypes;
import com.mednova.common.event.payload.*;
import com.mednova.notification.domain.model.NotificationType;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Set;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class DomainEventHandler {

    private static final Set<String> HANDLED_EVENTS = Set.of(
            EventTypes.HEALTH_ALERT_TRIGGERED,
            EventTypes.VITALS_ANOMALY_DETECTED,
            EventTypes.APPOINTMENT_SCHEDULED,
            EventTypes.APPOINTMENT_CANCELLED
    );

    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")
            .withZone(ZoneId.systemDefault());

    private final NotificationApplicationService notificationApplicationService;
    private final ObjectMapper objectMapper;

    public void handle(String rawMessage) {
        try {
            JsonNode root = objectMapper.readTree(rawMessage);
            String eventType = text(root, "eventType");
            String correlationId = text(root, "correlationId");

            if (eventType == null || !HANDLED_EVENTS.contains(eventType)) {
                return;
            }

            JsonNode payload = root.path("payload");
            switch (eventType) {
                case EventTypes.HEALTH_ALERT_TRIGGERED -> handleHealthAlert(payload, eventType, correlationId);
                case EventTypes.VITALS_ANOMALY_DETECTED -> handleVitalsAnomaly(payload, eventType, correlationId);
                case EventTypes.APPOINTMENT_SCHEDULED -> handleAppointmentScheduled(payload, eventType, correlationId);
                case EventTypes.APPOINTMENT_CANCELLED -> handleAppointmentCancelled(payload, eventType, correlationId);
                default -> { }
            }
        } catch (Exception ex) {
            log.error("Erreur traitement événement notification : {}", ex.getMessage());
        }
    }

    private void handleHealthAlert(JsonNode payload, String eventType, String correlationId) {
        HealthAlertTriggeredPayload alert = objectMapper.convertValue(payload, HealthAlertTriggeredPayload.class);
        String title = "Alerte santé %s".formatted(alert.riskLevel());
        String message = "Patient %s — score %d/100 : %s".formatted(
                alert.patientId(), alert.riskScore(), alert.message()
        );
        notificationApplicationService.createStaffAlert(
                alert.patientId(),
                NotificationType.HEALTH_ALERT,
                title,
                message,
                eventType,
                correlationId,
                true
        );
    }

    private void handleVitalsAnomaly(JsonNode payload, String eventType, String correlationId) {
        VitalsAnomalyDetectedPayload anomaly = objectMapper.convertValue(payload, VitalsAnomalyDetectedPayload.class);
        String title = "Anomalie signes vitaux";
        String message = "Patient %s — %s".formatted(anomaly.patientId(), anomaly.anomalyDetails());
        notificationApplicationService.createStaffAlert(
                anomaly.patientId(),
                NotificationType.VITALS_ANOMALY,
                title,
                message,
                eventType,
                correlationId,
                false
        );
    }

    private void handleAppointmentScheduled(JsonNode payload, String eventType, String correlationId) {
        AppointmentScheduledPayload appointment = objectMapper.convertValue(payload, AppointmentScheduledPayload.class);
        String date = DATE_FORMAT.format(appointment.scheduledAt());
        String staffMessage = "RDV planifié le %s — patient %s, médecin %s. Motif : %s".formatted(
                date, appointment.patientId(), appointment.doctorId(), appointment.reason()
        );
        String patientMessage = "Votre rendez-vous est confirmé pour le %s. Motif : %s".formatted(
                date, appointment.reason()
        );

        notificationApplicationService.createStaffAlert(
                appointment.patientId(),
                NotificationType.APPOINTMENT_SCHEDULED,
                "Nouveau rendez-vous",
                staffMessage,
                eventType,
                correlationId,
                false
        );
        notificationApplicationService.createPatientNotification(
                appointment.patientId(),
                NotificationType.APPOINTMENT_SCHEDULED,
                "Rendez-vous confirmé",
                patientMessage,
                eventType,
                correlationId
        );
    }

    private void handleAppointmentCancelled(JsonNode payload, String eventType, String correlationId) {
        AppointmentCancelledPayload appointment = objectMapper.convertValue(payload, AppointmentCancelledPayload.class);
        String staffMessage = "RDV annulé — patient %s, médecin %s. Raison : %s".formatted(
                appointment.patientId(), appointment.doctorId(), appointment.reason()
        );
        String patientMessage = "Votre rendez-vous a été annulé. Raison : %s".formatted(appointment.reason());

        notificationApplicationService.createStaffAlert(
                appointment.patientId(),
                NotificationType.APPOINTMENT_CANCELLED,
                "Rendez-vous annulé",
                staffMessage,
                eventType,
                correlationId,
                false
        );
        notificationApplicationService.createPatientNotification(
                appointment.patientId(),
                NotificationType.APPOINTMENT_CANCELLED,
                "Rendez-vous annulé",
                patientMessage,
                eventType,
                correlationId
        );
    }

    private String text(JsonNode node, String field) {
        JsonNode value = node.path(field);
        return value.isMissingNode() || value.isNull() ? null : value.asText();
    }
}
