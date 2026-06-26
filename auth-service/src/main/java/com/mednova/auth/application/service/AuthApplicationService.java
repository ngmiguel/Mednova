package com.mednova.auth.application.service;

import com.mednova.auth.application.dto.AuthTokens;
import com.mednova.auth.application.dto.LoginCommand;
import com.mednova.auth.application.dto.RegisterCommand;
import com.mednova.auth.application.port.out.AuthChallengeStorePort;
import com.mednova.auth.application.port.out.JwtParserPort;
import com.mednova.auth.application.port.out.PasswordEncoderPort;
import com.mednova.auth.application.port.out.TokenBlacklistPort;
import com.mednova.auth.application.port.out.TokenProviderPort;
import com.mednova.auth.domain.model.RefreshToken;
import com.mednova.auth.domain.model.RoleType;
import com.mednova.auth.domain.model.User;
import com.mednova.auth.domain.port.RefreshTokenRepository;
import com.mednova.auth.domain.port.UserRepository;
import com.mednova.common.exception.ConflictException;
import com.mednova.common.exception.ResourceNotFoundException;
import com.mednova.common.exception.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.Set;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthApplicationService {

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoderPort passwordEncoderPort;
    private final TokenProviderPort tokenProviderPort;
    private final TokenBlacklistPort tokenBlacklistPort;
    private final JwtParserPort jwtParserPort;
    private final AuthChallengeStorePort challengeStore;

    private static final Duration LOGIN_CHALLENGE_TTL = Duration.ofMinutes(5);

    @Transactional
    public AuthTokens register(RegisterCommand command) {
        if (userRepository.existsByEmail(command.email())) {
            throw new ConflictException("Un compte existe déjà avec cet email");
        }

        RoleType role = command.role() != null ? command.role() : RoleType.ROLE_PATIENT;

        User user = User.builder()
                .id(UUID.randomUUID())
                .email(command.email().toLowerCase())
                .passwordHash(passwordEncoderPort.encode(command.password()))
                .firstName(command.firstName())
                .lastName(command.lastName())
                .enabled(true)
                .twoFactorEnabled(false)
                .roles(Set.of(role))
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        User savedUser = userRepository.save(user);
        return issueTokens(savedUser);
    }

    @Transactional
    public AuthTokens login(LoginCommand command) {
        User user = userRepository.findByEmail(command.email().toLowerCase())
                .filter(User::isEnabled)
                .orElseThrow(() -> new UnauthorizedException("Email ou mot de passe incorrect"));

        if (!passwordEncoderPort.matches(command.password(), user.getPasswordHash())) {
            throw new UnauthorizedException("Email ou mot de passe incorrect");
        }

        if (user.isTwoFactorEnabled()) {
            String challengeToken = UUID.randomUUID().toString();
            challengeStore.storeLoginChallenge(challengeToken, user.getId(), LOGIN_CHALLENGE_TTL);
            return AuthTokens.twoFactorRequired(challengeToken);
        }

        refreshTokenRepository.revokeAllByUserId(user.getId());
        return issueTokens(user);
    }

    @Transactional
    public AuthTokens issueTokensForUser(User user) {
        refreshTokenRepository.revokeAllByUserId(user.getId());
        return issueTokens(user);
    }

    @Transactional
    public AuthTokens refresh(String refreshTokenValue) {
        String tokenHash = tokenProviderPort.hashToken(refreshTokenValue);

        RefreshToken storedToken = refreshTokenRepository.findByTokenHash(tokenHash)
                .filter(token -> !token.isRevoked())
                .filter(token -> token.getExpiresAt().isAfter(Instant.now()))
                .orElseThrow(() -> new UnauthorizedException("Refresh token invalide ou expiré"));

        User user = userRepository.findById(storedToken.getUserId())
                .filter(User::isEnabled)
                .orElseThrow(() -> new UnauthorizedException("Utilisateur introuvable"));

        refreshTokenRepository.revokeAllByUserId(user.getId());
        return issueTokens(user);
    }

    @Transactional
    public void logout(String accessToken, String refreshTokenValue) {
        jwtParserPort.extractJti(accessToken).ifPresent(jti ->
                tokenBlacklistPort.blacklist(jti, tokenProviderPort.getAccessTokenExpiration())
        );

        if (refreshTokenValue != null && !refreshTokenValue.isBlank()) {
            String tokenHash = tokenProviderPort.hashToken(refreshTokenValue);
            refreshTokenRepository.findByTokenHash(tokenHash)
                    .ifPresent(token -> refreshTokenRepository.revokeAllByUserId(token.getUserId()));
        }
    }

    @Transactional(readOnly = true)
    public User getCurrentUser(UUID userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Utilisateur", userId));
    }

    private AuthTokens issueTokens(User user) {
        String refreshTokenValue = tokenProviderPort.generateRefreshTokenValue();
        String tokenHash = tokenProviderPort.hashToken(refreshTokenValue);

        RefreshToken refreshToken = RefreshToken.builder()
                .id(UUID.randomUUID())
                .userId(user.getId())
                .tokenHash(tokenHash)
                .expiresAt(Instant.now().plus(tokenProviderPort.getRefreshTokenExpiration()))
                .revoked(false)
                .createdAt(Instant.now())
                .build();

        refreshTokenRepository.save(refreshToken);
        return tokenProviderPort.buildAuthTokens(user, refreshTokenValue);
    }
}
