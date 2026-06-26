package com.mednova.audit.domain.port;

import com.mednova.audit.domain.model.AuditEvent;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Optional;

public interface AuditEventRepository {

    AuditEvent save(AuditEvent event);

    Optional<AuditEvent> findByEventId(String eventId);

    Page<AuditEvent> findAll(Pageable pageable);

    Page<AuditEvent> findByEventType(String eventType, Pageable pageable);
}
