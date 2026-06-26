package com.mednova.auth.presentation.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record EnableTwoFactorRequest(
        @NotBlank @Pattern(regexp = "\\d{6}") String code
) {
}
