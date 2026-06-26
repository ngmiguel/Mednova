package com.mednova.audit.presentation.rest;

import com.mednova.audit.application.service.AuditQueryService;
import com.mednova.audit.presentation.dto.AuditEventResponse;
import com.mednova.audit.presentation.mapper.AuditEventMapper;
import com.mednova.common.dto.ApiResponse;
import com.mednova.common.dto.PageResponse;
import com.mednova.common.util.CorrelationIdUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/audit")
@RequiredArgsConstructor
@Tag(name = "Audit", description = "Journal d'audit des événements Kafka")
@SecurityRequirement(name = "bearerAuth")
public class AuditController {

    private final AuditQueryService auditQueryService;
    private final AuditEventMapper auditEventMapper;

    @GetMapping("/events")
    @Operation(summary = "Consulter le journal d'audit (ADMIN / AUDITOR)")
    public ResponseEntity<ApiResponse<PageResponse<AuditEventResponse>>> listEvents(
            @RequestParam(required = false) String eventType,
            @PageableDefault(size = 20) Pageable pageable,
            HttpServletRequest httpRequest
    ) {
        var page = auditQueryService.list(eventType, pageable);
        var mapped = PageResponse.of(
                page.content().stream().map(auditEventMapper::toResponse).toList(),
                page.page(), page.size(), page.totalElements()
        );
        return ResponseEntity.ok(ApiResponse.success(mapped, CorrelationIdUtils.resolve(httpRequest)));
    }
}
