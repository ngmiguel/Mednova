package com.mednova.auth.presentation.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record DisableTwoFactorRequest(
        @NotBlank @Pattern(regexp = "\\d{6}") String code,
        @NotBlank String password
) {
}
