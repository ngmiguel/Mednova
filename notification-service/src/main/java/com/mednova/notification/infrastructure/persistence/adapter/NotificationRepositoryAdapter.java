package com.mednova.notification.infrastructure.persistence.adapter;

import com.mednova.notification.domain.model.Notification;
import com.mednova.notification.domain.model.NotificationStatus;
import com.mednova.notification.domain.model.NotificationType;
import com.mednova.notification.domain.port.NotificationRepository;
import com.mednova.notification.infrastructure.persistence.mapper.PersistenceMapper;
import com.mednova.notification.infrastructure.persistence.repository.NotificationJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Component;

import java.util.Optional;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class NotificationRepositoryAdapter implements NotificationRepository {

    private static final String STAFF_TARGET = "STAFF";
    private static final String PATIENT_TARGET = "ROLE_PATIENT";

    private final NotificationJpaRepository jpaRepository;
    private final PersistenceMapper persistenceMapper;

    @Override
    public Notification save(Notification notification) {
        var saved = jpaRepository.save(persistenceMapper.toEntity(notification));
        return persistenceMapper.toDomain(saved);
    }

    @Override
    public Optional<Notification> findById(UUID id) {
        return jpaRepository.findById(id).map(persistenceMapper::toDomain);
    }

    @Override
    public Page<Notification> findForStaff(
            UUID patientId,
            NotificationStatus status,
            NotificationType type,
            Pageable pageable
    ) {
        return jpaRepository.findStaffNotifications(
                patientId,
                status != null ? status.name() : null,
                type != null ? type.name() : null,
                pageable
        ).map(persistenceMapper::toDomain);
    }

    @Override
    public Page<Notification> findForPatient(Pageable pageable) {
        return jpaRepository.findByTargetRole(PATIENT_TARGET, pageable).map(persistenceMapper::toDomain);
    }

    @Override
    public long countUnreadForStaff() {
        return jpaRepository.countByTargetRoleAndStatus(STAFF_TARGET, NotificationStatus.UNREAD.name());
    }

    @Override
    public long countUnreadForPatient() {
        return jpaRepository.countByTargetRoleAndStatus(PATIENT_TARGET, NotificationStatus.UNREAD.name());
    }
}
