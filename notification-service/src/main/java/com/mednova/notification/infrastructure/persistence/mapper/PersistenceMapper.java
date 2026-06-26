package com.mednova.notification.infrastructure.persistence.mapper;

import com.mednova.notification.domain.model.Notification;
import com.mednova.notification.domain.model.NotificationChannel;
import com.mednova.notification.domain.model.NotificationStatus;
import com.mednova.notification.domain.model.NotificationType;
import com.mednova.notification.infrastructure.persistence.entity.NotificationEntity;
import org.springframework.stereotype.Component;

@Component
public class PersistenceMapper {

    public Notification toDomain(NotificationEntity entity) {
        return Notification.builder()
                .id(entity.getId())
                .patientId(entity.getPatientId())
                .type(NotificationType.valueOf(entity.getType()))
                .channel(NotificationChannel.valueOf(entity.getChannel()))
                .title(entity.getTitle())
                .message(entity.getMessage())
                .status(NotificationStatus.valueOf(entity.getStatus()))
                .targetRole(entity.getTargetRole())
                .sourceEventType(entity.getSourceEventType())
                .correlationId(entity.getCorrelationId())
                .createdAt(entity.getCreatedAt())
                .readAt(entity.getReadAt())
                .build();
    }

    public NotificationEntity toEntity(Notification notification) {
        return NotificationEntity.builder()
                .id(notification.getId())
                .patientId(notification.getPatientId())
                .type(notification.getType().name())
                .channel(notification.getChannel().name())
                .title(notification.getTitle())
                .message(notification.getMessage())
                .status(notification.getStatus().name())
                .targetRole(notification.getTargetRole())
                .sourceEventType(notification.getSourceEventType())
                .correlationId(notification.getCorrelationId())
                .createdAt(notification.getCreatedAt())
                .readAt(notification.getReadAt())
                .build();
    }
}
