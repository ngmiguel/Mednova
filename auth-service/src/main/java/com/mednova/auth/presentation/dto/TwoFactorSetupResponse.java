package com.mednova.auth.presentation.dto;

public record TwoFactorSetupResponse(
        String secret,
        String otpAuthUrl,
        String qrCodeBase64
) {
}
