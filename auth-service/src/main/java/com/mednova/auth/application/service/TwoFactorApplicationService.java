package com.mednova.auth.application.service;

import com.mednova.auth.application.dto.AuthTokens;
import com.mednova.auth.application.dto.TwoFactorSetupResult;
import com.mednova.auth.application.port.out.AuthChallengeStorePort;
import com.mednova.auth.application.port.out.PasswordEncoderPort;
import com.mednova.auth.domain.model.User;
import com.mednova.auth.domain.port.UserRepository;
import com.mednova.auth.infrastructure.security.TotpService;
import com.mednova.common.exception.BusinessException;
import com.mednova.common.exception.ConflictException;
import com.mednova.common.exception.ResourceNotFoundException;
import com.mednova.common.exception.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TwoFactorApplicationService {

    private static final Duration PENDING_TOTP_TTL = Duration.ofMinutes(10);

    private final UserRepository userRepository;
    private final AuthChallengeStorePort challengeStore;
    private final TotpService totpService;
    private final PasswordEncoderPort passwordEncoderPort;
    private final AuthApplicationService authApplicationService;

    @Transactional(readOnly = true)
    public boolean isEnabled(UUID userId) {
        return findUser(userId).isTwoFactorEnabled();
    }

    @Transactional
    public TwoFactorSetupResult setup(UUID userId) {
        User user = findUser(userId);
        if (user.isTwoFactorEnabled()) {
            throw new ConflictException("La double authentification est déjà activée");
        }

        String secret = totpService.generateSecret();
        challengeStore.storePendingTotpSecret(userId, secret, PENDING_TOTP_TTL);
        String otpAuthUrl = totpService.buildOtpAuthUrl(user.getEmail(), secret);

        return new TwoFactorSetupResult(
                secret,
                otpAuthUrl,
                totpService.generateQrCodeBase64(user.getEmail(), secret)
        );
    }

    @Transactional
    public void enable(UUID userId, String code) {
        findUser(userId);
        String pendingSecret = challengeStore.consumePendingTotpSecret(userId)
                .orElseThrow(() -> new BusinessException("Configuration 2FA expirée — relancez /2fa/setup"));

        if (!totpService.verifyCode(pendingSecret, code)) {
            throw new UnauthorizedException("Code TOTP invalide");
        }

        User user = findUser(userId);
        userRepository.save(user.toBuilder()
                .totpSecret(pendingSecret)
                .twoFactorEnabled(true)
                .updatedAt(Instant.now())
                .build());
    }

    @Transactional
    public void disable(UUID userId, String code, String password) {
        User user = findUser(userId);
        if (!user.isTwoFactorEnabled()) {
            throw new BusinessException("La double authentification n'est pas activée");
        }
        if (!passwordEncoderPort.matches(password, user.getPasswordHash())) {
            throw new UnauthorizedException("Mot de passe incorrect");
        }
        if (!totpService.verifyCode(user.getTotpSecret(), code)) {
            throw new UnauthorizedException("Code TOTP invalide");
        }

        userRepository.save(user.toBuilder()
                .totpSecret(null)
                .twoFactorEnabled(false)
                .updatedAt(Instant.now())
                .build());
    }

    @Transactional
    public AuthTokens verifyLogin(String challengeToken, String code) {
        UUID userId = challengeStore.consumeLoginChallenge(challengeToken)
                .orElseThrow(() -> new UnauthorizedException("Session 2FA expirée — reconnectez-vous"));

        User user = userRepository.findById(userId)
                .filter(User::isEnabled)
                .filter(User::isTwoFactorEnabled)
                .orElseThrow(() -> new UnauthorizedException("Utilisateur introuvable"));

        if (!totpService.verifyCode(user.getTotpSecret(), code)) {
            throw new UnauthorizedException("Code TOTP invalide");
        }

        return authApplicationService.issueTokensForUser(user);
    }

    private User findUser(UUID userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> ResourceNotFoundException.forResource("Utilisateur", userId));
    }
}
