package com.mednova.auth.presentation.dto;

import jakarta.validation.constraints.NotNull;

public record UpdateUserAccessRequest(@NotNull Boolean enabled) {
}
