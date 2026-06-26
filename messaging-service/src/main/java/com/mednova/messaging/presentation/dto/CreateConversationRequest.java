package com.mednova.messaging.presentation.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Builder;

import java.util.UUID;

@Builder
public record CreateConversationRequest(
        @NotNull UUID patientUserId,
        @NotNull UUID doctorUserId,
        UUID patientId,
        UUID doctorId,
        String subject
) {
}
