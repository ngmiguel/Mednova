package com.mednova.auth.application.dto;

public record TwoFactorSetupResult(
        String secret,
        String otpAuthUrl,
        String qrCodeBase64
) {
}
