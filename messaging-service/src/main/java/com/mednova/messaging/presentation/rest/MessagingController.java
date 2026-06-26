package com.mednova.messaging.presentation.rest;

import com.mednova.common.dto.ApiResponse;
import com.mednova.common.util.CorrelationIdUtils;
import com.mednova.messaging.application.service.MessagingApplicationService;
import com.mednova.messaging.presentation.dto.ConversationResponse;
import com.mednova.messaging.presentation.dto.CreateConversationRequest;
import com.mednova.messaging.presentation.dto.MessageResponse;
import com.mednova.messaging.presentation.dto.SendMessageRequest;
import com.mednova.messaging.presentation.mapper.MessagingMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/messaging")
@RequiredArgsConstructor
@Tag(name = "Messaging", description = "Messagerie patient-médecin")
@SecurityRequirement(name = "bearerAuth")
public class MessagingController {

    private final MessagingApplicationService messagingService;
    private final MessagingMapper messagingMapper;

    @GetMapping("/conversations")
    @Operation(summary = "Lister les conversations accessibles")
    public ResponseEntity<ApiResponse<List<ConversationResponse>>> listConversations(
            HttpServletRequest httpRequest
    ) {
        var conversations = messagingService.listConversations().stream()
                .map(messagingMapper::toConversationResponse)
                .toList();
        return ResponseEntity.ok(ApiResponse.success(conversations, CorrelationIdUtils.resolve(httpRequest)));
    }

    @PostMapping("/conversations")
    @Operation(summary = "Créer ou récupérer une conversation patient-médecin")
    public ResponseEntity<ApiResponse<ConversationResponse>> createConversation(
            @Valid @RequestBody CreateConversationRequest request,
            HttpServletRequest httpRequest
    ) {
        var conversation = messagingService.createConversation(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(
                        messagingMapper.toConversationResponse(conversation),
                        CorrelationIdUtils.resolve(httpRequest)
                ));
    }

    @GetMapping("/conversations/{id}/messages")
    @Operation(summary = "Lister les messages d'une conversation")
    public ResponseEntity<ApiResponse<List<MessageResponse>>> listMessages(
            @PathVariable UUID id,
            HttpServletRequest httpRequest
    ) {
        var messages = messagingService.listMessages(id).stream()
                .map(messagingMapper::toMessageResponse)
                .toList();
        return ResponseEntity.ok(ApiResponse.success(messages, CorrelationIdUtils.resolve(httpRequest)));
    }

    @PostMapping("/conversations/{id}/messages")
    @Operation(summary = "Envoyer un message dans une conversation")
    public ResponseEntity<ApiResponse<MessageResponse>> sendMessage(
            @PathVariable UUID id,
            @Valid @RequestBody SendMessageRequest request,
            HttpServletRequest httpRequest
    ) {
        var message = messagingService.sendMessage(id, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(
                        messagingMapper.toMessageResponse(message),
                        CorrelationIdUtils.resolve(httpRequest)
                ));
    }

    @PatchMapping("/conversations/{id}/read")
    @Operation(summary = "Marquer les messages non lus comme lus")
    public ResponseEntity<ApiResponse<Map<String, String>>> markAsRead(
            @PathVariable UUID id,
            HttpServletRequest httpRequest
    ) {
        messagingService.markConversationAsRead(id);
        return ResponseEntity.ok(ApiResponse.success(
                Map.of("status", "READ"),
                CorrelationIdUtils.resolve(httpRequest)
        ));
    }
}
