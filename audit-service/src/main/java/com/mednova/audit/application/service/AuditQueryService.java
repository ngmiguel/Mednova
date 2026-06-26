package com.mednova.audit.application.service;

import com.mednova.audit.application.security.AuditAccessGuard;
import com.mednova.audit.domain.model.AuditEvent;
import com.mednova.audit.domain.port.AuditEventRepository;
import com.mednova.common.dto.PageResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuditQueryService {

    private final AuditEventRepository auditEventRepository;
    private final AuditAccessGuard accessGuard;

    @Transactional(readOnly = true)
    public PageResponse<AuditEvent> list(String eventType, Pageable pageable) {
        accessGuard.checkCanRead();
        Page<AuditEvent> page = eventType != null && !eventType.isBlank()
                ? auditEventRepository.findByEventType(eventType, pageable)
                : auditEventRepository.findAll(pageable);
        return PageResponse.of(page.getContent(), page.getNumber(), page.getSize(), page.getTotalElements());
    }
}
