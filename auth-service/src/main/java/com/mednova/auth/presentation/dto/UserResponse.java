package com.mednova.auth.presentation.dto;

import com.mednova.auth.domain.model.RoleType;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;

public record UserResponse(
        UUID id,
        String email,
        String firstName,
        String lastName,
        boolean enabled,
        boolean twoFactorEnabled,
        Set<RoleType> roles,
        Instant createdAt
) {
}
