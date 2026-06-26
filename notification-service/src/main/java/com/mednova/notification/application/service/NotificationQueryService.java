package com.mednova.notification.application.service;

import com.mednova.common.exception.ResourceNotFoundException;
import com.mednova.notification.application.security.NotificationAccessGuard;
import com.mednova.notification.domain.model.Notification;
import com.mednova.notification.domain.model.NotificationStatus;
import com.mednova.notification.domain.model.NotificationType;
import com.mednova.notification.domain.port.NotificationRepository;
import com.mednova.common.dto.PageResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class NotificationQueryService {

    private final NotificationRepository notificationRepository;
    private final NotificationAccessGuard accessGuard;

    @Transactional(readOnly = true)
    public PageResponse<Notification> list(
            UUID patientId,
            NotificationStatus status,
            NotificationType type,
            Pageable pageable
    ) {
        accessGuard.checkCanList();
        Page<Notification> page = accessGuard.isStaff()
                ? notificationRepository.findForStaff(patientId, status, type, pageable)
                : notificationRepository.findForPatient(pageable);
        return PageResponse.of(page.getContent(), page.getNumber(), page.getSize(), page.getTotalElements());
    }

    @Transactional(readOnly = true)
    public Notification getById(UUID id) {
        accessGuard.checkCanList();
        Notification notification = notificationRepository.findById(id)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Notification", id));
        accessGuard.checkCanRead(notification);
        return notification;
    }

    @Transactional(readOnly = true)
    public long countUnread() {
        accessGuard.checkCanList();
        return accessGuard.isStaff()
                ? notificationRepository.countUnreadForStaff()
                : notificationRepository.countUnreadForPatient();
    }
}
