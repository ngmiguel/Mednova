package com.mednova.messaging.application.service;

import com.mednova.common.exception.ForbiddenException;
import com.mednova.common.exception.ResourceNotFoundException;
import com.mednova.messaging.application.security.MessagingAccessGuard;
import com.mednova.messaging.infrastructure.persistence.entity.ConversationEntity;
import com.mednova.messaging.infrastructure.persistence.entity.MessageEntity;
import com.mednova.messaging.infrastructure.persistence.repository.ConversationJpaRepository;
import com.mednova.messaging.infrastructure.persistence.repository.MessageJpaRepository;
import com.mednova.messaging.presentation.dto.CreateConversationRequest;
import com.mednova.messaging.presentation.dto.SendMessageRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class MessagingApplicationService {

    private final MessagingAccessGuard accessGuard;
    private final ConversationJpaRepository conversationRepository;
    private final MessageJpaRepository messageRepository;

    @Transactional(readOnly = true)
    public List<ConversationEntity> listConversations() {
        accessGuard.checkCanList();
        var user = accessGuard.currentUser();

        if (accessGuard.isAdminOrNurse()) {
            return conversationRepository.findAllByOrderByUpdatedAtDesc();
        }
        if (user.hasRole("ROLE_PATIENT")) {
            return conversationRepository.findByPatientUserIdOrderByUpdatedAtDesc(user.getUserId());
        }
        if (user.hasRole("ROLE_DOCTOR")) {
            return conversationRepository.findByDoctorUserIdOrderByUpdatedAtDesc(user.getUserId());
        }
        return List.of();
    }

    @Transactional
    public ConversationEntity createConversation(CreateConversationRequest request) {
        accessGuard.checkCanCreate(request.patientUserId(), request.doctorUserId());

        return conversationRepository
                .findByPatientUserIdAndDoctorUserId(request.patientUserId(), request.doctorUserId())
                .orElseGet(() -> {
                    Instant now = Instant.now();
                    var conversation = ConversationEntity.builder()
                            .id(UUID.randomUUID())
                            .patientUserId(request.patientUserId())
                            .doctorUserId(request.doctorUserId())
                            .patientId(request.patientId())
                            .doctorId(request.doctorId())
                            .subject(request.subject())
                            .createdAt(now)
                            .updatedAt(now)
                            .build();
                    return conversationRepository.save(conversation);
                });
    }

    @Transactional(readOnly = true)
    public List<MessageEntity> listMessages(UUID conversationId) {
        var conversation = getConversationOrThrow(conversationId);
        accessGuard.checkCanRead(conversation);
        return messageRepository.findByConversationIdOrderBySentAtAsc(conversationId);
    }

    @Transactional
    public MessageEntity sendMessage(UUID conversationId, SendMessageRequest request) {
        var conversation = getConversationOrThrow(conversationId);
        accessGuard.checkCanRead(conversation);

        var sender = accessGuard.currentUser();
        if (!sender.getUserId().equals(conversation.getPatientUserId())
                && !sender.getUserId().equals(conversation.getDoctorUserId())) {
            throw new ForbiddenException("Seuls les participants peuvent envoyer un message");
        }

        Instant now = Instant.now();
        var message = MessageEntity.builder()
                .id(UUID.randomUUID())
                .conversationId(conversationId)
                .senderUserId(sender.getUserId())
                .content(request.content().trim())
                .sentAt(now)
                .build();

        conversation.setUpdatedAt(now);
        conversationRepository.save(conversation);
        return messageRepository.save(message);
    }

    @Transactional
    public void markConversationAsRead(UUID conversationId) {
        var conversation = getConversationOrThrow(conversationId);
        accessGuard.checkCanRead(conversation);

        var reader = accessGuard.currentUser();
        messageRepository.markUnreadAsRead(conversationId, reader.getUserId(), Instant.now());
    }

    private ConversationEntity getConversationOrThrow(UUID conversationId) {
        return conversationRepository.findById(conversationId)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Conversation", conversationId));
    }
}
