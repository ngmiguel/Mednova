package com.mednova.notification.application.service;

import com.mednova.common.exception.ResourceNotFoundException;
import com.mednova.notification.application.security.NotificationAccessGuard;
import com.mednova.notification.domain.model.Notification;
import com.mednova.notification.domain.port.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class NotificationCommandService {

    private final NotificationRepository notificationRepository;
    private final NotificationAccessGuard accessGuard;

    @Transactional
    public Notification markAsRead(UUID id) {
        accessGuard.checkCanList();
        Notification notification = notificationRepository.findById(id)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Notification", id));
        accessGuard.checkCanRead(notification);
        notification.markAsRead(Instant.now());
        return notificationRepository.save(notification);
    }
}
