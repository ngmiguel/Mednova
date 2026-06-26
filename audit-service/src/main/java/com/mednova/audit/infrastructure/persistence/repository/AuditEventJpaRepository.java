package com.mednova.audit.infrastructure.persistence.repository;

import com.mednova.audit.infrastructure.persistence.entity.AuditEventEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface AuditEventJpaRepository extends JpaRepository<AuditEventEntity, UUID> {

    Optional<AuditEventEntity> findByEventId(String eventId);

    Page<AuditEventEntity> findByEventType(String eventType, Pageable pageable);
}
