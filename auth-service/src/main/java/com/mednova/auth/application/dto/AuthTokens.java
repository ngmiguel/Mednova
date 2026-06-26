package com.mednova.auth.application.dto;

import com.mednova.auth.domain.model.RoleType;
import lombok.Builder;

import java.util.Set;

@Builder
public record AuthTokens(
        String accessToken,
        String refreshToken,
        String tokenType,
        Long expiresIn,
        Set<RoleType> roles,
        boolean requiresTwoFactor,
        String challengeToken
) {

    public static AuthTokens withTokens(
            String accessToken,
            String refreshToken,
            String tokenType,
            long expiresIn,
            Set<RoleType> roles
    ) {
        return AuthTokens.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType(tokenType)
                .expiresIn(expiresIn)
                .roles(roles)
                .requiresTwoFactor(false)
                .build();
    }

    public static AuthTokens twoFactorRequired(String challengeToken) {
        return AuthTokens.builder()
                .requiresTwoFactor(true)
                .challengeToken(challengeToken)
                .build();
    }
}
