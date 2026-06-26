package com.mednova.auth.presentation.dto;

import com.mednova.auth.domain.model.RoleType;

import java.util.Set;

public record AuthResponse(
        String accessToken,
        String refreshToken,
        String tokenType,
        Long expiresIn,
        Set<RoleType> roles,
        boolean requiresTwoFactor,
        String challengeToken
) {
}
