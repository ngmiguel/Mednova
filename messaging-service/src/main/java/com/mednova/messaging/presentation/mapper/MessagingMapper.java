package com.mednova.messaging.presentation.mapper;

import com.mednova.messaging.infrastructure.persistence.entity.ConversationEntity;
import com.mednova.messaging.infrastructure.persistence.entity.MessageEntity;
import com.mednova.messaging.presentation.dto.ConversationResponse;
import com.mednova.messaging.presentation.dto.MessageResponse;
import org.springframework.stereotype.Component;

@Component
public class MessagingMapper {

    public ConversationResponse toConversationResponse(ConversationEntity entity) {
        return ConversationResponse.builder()
                .id(entity.getId())
                .patientUserId(entity.getPatientUserId())
                .doctorUserId(entity.getDoctorUserId())
                .patientId(entity.getPatientId())
                .doctorId(entity.getDoctorId())
                .subject(entity.getSubject())
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .build();
    }

    public MessageResponse toMessageResponse(MessageEntity entity) {
        return MessageResponse.builder()
                .id(entity.getId())
                .conversationId(entity.getConversationId())
                .senderUserId(entity.getSenderUserId())
                .content(entity.getContent())
                .sentAt(entity.getSentAt())
                .readAt(entity.getReadAt())
                .build();
    }
}
