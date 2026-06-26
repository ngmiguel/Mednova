package com.mednova.auth.application.port.out;

import com.mednova.auth.application.dto.AuthTokens;
import com.mednova.auth.domain.model.User;

import java.time.Duration;

public interface TokenProviderPort {

    String generateAccessToken(User user);

    String generateRefreshTokenValue();

    String hashToken(String token);

    Duration getAccessTokenExpiration();

    Duration getRefreshTokenExpiration();

    AuthTokens buildAuthTokens(User user, String refreshTokenValue);
}
