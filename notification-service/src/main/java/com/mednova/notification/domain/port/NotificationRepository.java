package com.mednova.notification.domain.port;

import com.mednova.notification.domain.model.Notification;
import com.mednova.notification.domain.model.NotificationStatus;
import com.mednova.notification.domain.model.NotificationType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Optional;
import java.util.UUID;

public interface NotificationRepository {

    Notification save(Notification notification);

    Optional<Notification> findById(UUID id);

    Page<Notification> findForStaff(
            UUID patientId,
            NotificationStatus status,
            NotificationType type,
            Pageable pageable
    );

    Page<Notification> findForPatient(Pageable pageable);

    long countUnreadForStaff();

    long countUnreadForPatient();
}
