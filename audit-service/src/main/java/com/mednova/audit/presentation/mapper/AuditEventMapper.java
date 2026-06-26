package com.mednova.audit.presentation.mapper;

import com.mednova.audit.domain.model.AuditEvent;
import com.mednova.audit.presentation.dto.AuditEventResponse;
import org.springframework.stereotype.Component;

@Component
public class AuditEventMapper {

    public AuditEventResponse toResponse(AuditEvent event) {
        return new AuditEventResponse(
                event.getId(),
                event.getEventId(),
                event.getEventType(),
                event.getSource(),
                event.getCorrelationId(),
                event.getPayload(),
                event.getReceivedAt()
        );
    }
}
