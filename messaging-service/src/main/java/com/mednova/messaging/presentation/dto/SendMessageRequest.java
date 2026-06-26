package com.mednova.messaging.presentation.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Builder;

@Builder
public record SendMessageRequest(
        @NotBlank String content
) {
}
