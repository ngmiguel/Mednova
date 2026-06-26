package com.mednova.notification.presentation.mapper;

import com.mednova.notification.domain.model.Notification;
import com.mednova.notification.presentation.dto.NotificationResponse;
import org.springframework.stereotype.Component;

@Component
public class NotificationMapper {

    public NotificationResponse toResponse(Notification notification) {
        return new NotificationResponse(
                notification.getId(),
                notification.getPatientId(),
                notification.getType(),
                notification.getChannel(),
                notification.getTitle(),
                notification.getMessage(),
                notification.getStatus(),
                notification.getTargetRole(),
                notification.getSourceEventType(),
                notification.getCreatedAt(),
                notification.getReadAt()
        );
    }
}
