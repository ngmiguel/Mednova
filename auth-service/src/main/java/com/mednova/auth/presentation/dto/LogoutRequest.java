package com.mednova.auth.presentation.dto;

public record LogoutRequest(
        String refreshToken
) {
}
