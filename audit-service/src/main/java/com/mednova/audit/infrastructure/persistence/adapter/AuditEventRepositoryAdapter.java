package com.mednova.audit.infrastructure.persistence.adapter;

import com.mednova.audit.domain.model.AuditEvent;
import com.mednova.audit.domain.port.AuditEventRepository;
import com.mednova.audit.infrastructure.persistence.mapper.PersistenceMapper;
import com.mednova.audit.infrastructure.persistence.repository.AuditEventJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class AuditEventRepositoryAdapter implements AuditEventRepository {

    private final AuditEventJpaRepository auditEventJpaRepository;
    private final PersistenceMapper persistenceMapper;

    @Override
    @Transactional
    public AuditEvent save(AuditEvent event) {
        return persistenceMapper.toDomain(auditEventJpaRepository.save(persistenceMapper.toEntity(event)));
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<AuditEvent> findByEventId(String eventId) {
        return auditEventJpaRepository.findByEventId(eventId).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<AuditEvent> findAll(Pageable pageable) {
        return auditEventJpaRepository.findAll(pageable).map(persistenceMapper::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<AuditEvent> findByEventType(String eventType, Pageable pageable) {
        return auditEventJpaRepository.findByEventType(eventType, pageable).map(persistenceMapper::toDomain);
    }
}
