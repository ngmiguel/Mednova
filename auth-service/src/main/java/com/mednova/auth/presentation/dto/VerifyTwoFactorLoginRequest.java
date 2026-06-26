package com.mednova.auth.presentation.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record VerifyTwoFactorLoginRequest(
        @NotBlank String challengeToken,
        @NotBlank @Pattern(regexp = "\\d{6}") String code
) {
}
