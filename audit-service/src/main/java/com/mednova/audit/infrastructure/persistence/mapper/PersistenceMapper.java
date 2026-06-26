package com.mednova.audit.infrastructure.persistence.mapper;

import com.mednova.audit.domain.model.AuditEvent;
import com.mednova.audit.infrastructure.persistence.entity.AuditEventEntity;
import org.springframework.stereotype.Component;

@Component
public class PersistenceMapper {

    public AuditEvent toDomain(AuditEventEntity entity) {
        return AuditEvent.builder()
                .id(entity.getId())
                .eventId(entity.getEventId())
                .eventType(entity.getEventType())
                .source(entity.getSource())
                .correlationId(entity.getCorrelationId())
                .payload(entity.getPayload())
                .receivedAt(entity.getReceivedAt())
                .build();
    }

    public AuditEventEntity toEntity(AuditEvent event) {
        return AuditEventEntity.builder()
                .id(event.getId())
                .eventId(event.getEventId())
                .eventType(event.getEventType())
                .source(event.getSource())
                .correlationId(event.getCorrelationId())
                .payload(event.getPayload())
                .receivedAt(event.getReceivedAt())
                .build();
    }
}
