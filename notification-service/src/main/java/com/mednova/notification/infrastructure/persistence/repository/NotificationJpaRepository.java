package com.mednova.notification.infrastructure.persistence.repository;

import com.mednova.notification.infrastructure.persistence.entity.NotificationEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.UUID;

public interface NotificationJpaRepository extends JpaRepository<NotificationEntity, UUID>,
        JpaSpecificationExecutor<NotificationEntity> {

    @Query("""
            SELECT n FROM NotificationEntity n
            WHERE n.targetRole = 'STAFF'
              AND (:patientId IS NULL OR n.patientId = :patientId)
              AND (:status IS NULL OR n.status = :status)
              AND (:type IS NULL OR n.type = :type)
            """)
    Page<NotificationEntity> findStaffNotifications(
            @Param("patientId") UUID patientId,
            @Param("status") String status,
            @Param("type") String type,
            Pageable pageable
    );

    Page<NotificationEntity> findByTargetRoleAndStatus(String targetRole, String status, Pageable pageable);

    Page<NotificationEntity> findByTargetRole(String targetRole, Pageable pageable);

    long countByTargetRoleAndStatus(String targetRole, String status);
}
