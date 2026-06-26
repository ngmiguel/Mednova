package com.mednova.notification.application.service;

import com.mednova.common.event.EventTypes;
import com.mednova.common.event.payload.NotificationSentPayload;
import com.mednova.notification.domain.model.*;
import com.mednova.notification.domain.port.NotificationRepository;
import com.mednova.notification.infrastructure.kafka.DomainEventPublisher;
import com.mednova.notification.infrastructure.notification.EmailNotificationSender;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationApplicationService {

    private static final String STAFF_TARGET = "STAFF";
    private static final String PATIENT_TARGET = "ROLE_PATIENT";

    private final NotificationRepository notificationRepository;
    private final DomainEventPublisher domainEventPublisher;
    private final EmailNotificationSender emailNotificationSender;

    @Transactional
    public void createStaffAlert(
            UUID patientId,
            NotificationType type,
            String title,
            String message,
            String sourceEventType,
            String correlationId,
            boolean sendEmail
    ) {
        createAndPublish(patientId, type, title, message, STAFF_TARGET, sourceEventType, correlationId, sendEmail);
    }

    @Transactional
    public void createPatientNotification(
            UUID patientId,
            NotificationType type,
            String title,
            String message,
            String sourceEventType,
            String correlationId
    ) {
        createAndPublish(patientId, type, title, message, PATIENT_TARGET, sourceEventType, correlationId, false);
    }

    private void createAndPublish(
            UUID patientId,
            NotificationType type,
            String title,
            String message,
            String targetRole,
            String sourceEventType,
            String correlationId,
            boolean sendEmail
    ) {
        var notification = Notification.builder()
                .id(UUID.randomUUID())
                .patientId(patientId)
                .type(type)
                .channel(NotificationChannel.IN_APP)
                .title(title)
                .message(message)
                .status(NotificationStatus.UNREAD)
                .targetRole(targetRole)
                .sourceEventType(sourceEventType)
                .correlationId(correlationId)
                .createdAt(Instant.now())
                .build();

        var saved = notificationRepository.save(notification);
        log.info("Notification créée : {} [{}] → {}", type, saved.getId(), targetRole);

        if (sendEmail) {
            emailNotificationSender.sendHealthAlertEmail(saved);
        }

        domainEventPublisher.publish(
                EventTypes.NOTIFICATION_SENT,
                correlationId,
                new NotificationSentPayload(
                        saved.getId(),
                        saved.getPatientId(),
                        saved.getType().name(),
                        sendEmail ? NotificationChannel.EMAIL.name() : NotificationChannel.IN_APP.name(),
                        saved.getTitle()
                )
        );
    }
}
