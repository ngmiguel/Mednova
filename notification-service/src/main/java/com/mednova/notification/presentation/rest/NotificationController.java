package com.mednova.notification.presentation.rest;

import com.mednova.common.dto.ApiResponse;
import com.mednova.common.dto.PageResponse;
import com.mednova.common.util.CorrelationIdUtils;
import com.mednova.notification.application.service.NotificationCommandService;
import com.mednova.notification.application.service.NotificationQueryService;
import com.mednova.notification.domain.model.NotificationStatus;
import com.mednova.notification.domain.model.NotificationType;
import com.mednova.notification.presentation.dto.NotificationResponse;
import com.mednova.notification.presentation.mapper.NotificationMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
@Tag(name = "Notifications", description = "Alertes in-app et emails simulés")
@SecurityRequirement(name = "bearerAuth")
public class NotificationController {

    private final NotificationQueryService notificationQueryService;
    private final NotificationCommandService notificationCommandService;
    private final NotificationMapper notificationMapper;

    @GetMapping
    @Operation(summary = "Lister les notifications (staff ou patient)")
    public ResponseEntity<ApiResponse<PageResponse<NotificationResponse>>> list(
            @RequestParam(required = false) UUID patientId,
            @RequestParam(required = false) NotificationStatus status,
            @RequestParam(required = false) NotificationType type,
            @PageableDefault(size = 20) Pageable pageable,
            HttpServletRequest httpRequest
    ) {
        var page = notificationQueryService.list(patientId, status, type, pageable);
        var mapped = PageResponse.of(
                page.content().stream().map(notificationMapper::toResponse).toList(),
                page.page(), page.size(), page.totalElements()
        );
        return ResponseEntity.ok(ApiResponse.success(mapped, CorrelationIdUtils.resolve(httpRequest)));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtenir une notification par ID")
    public ResponseEntity<ApiResponse<NotificationResponse>> getById(
            @PathVariable UUID id,
            HttpServletRequest httpRequest
    ) {
        var notification = notificationQueryService.getById(id);
        return ResponseEntity.ok(
                ApiResponse.success(notificationMapper.toResponse(notification), CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @GetMapping("/unread-count")
    @Operation(summary = "Nombre de notifications non lues")
    public ResponseEntity<ApiResponse<Map<String, Long>>> unreadCount(HttpServletRequest httpRequest) {
        long count = notificationQueryService.countUnread();
        return ResponseEntity.ok(
                ApiResponse.success(Map.of("unreadCount", count), CorrelationIdUtils.resolve(httpRequest))
        );
    }

    @PatchMapping("/{id}/read")
    @Operation(summary = "Marquer une notification comme lue")
    public ResponseEntity<ApiResponse<NotificationResponse>> markAsRead(
            @PathVariable UUID id,
            HttpServletRequest httpRequest
    ) {
        var notification = notificationCommandService.markAsRead(id);
        return ResponseEntity.ok(
                ApiResponse.success(notificationMapper.toResponse(notification), CorrelationIdUtils.resolve(httpRequest))
        );
    }
}
