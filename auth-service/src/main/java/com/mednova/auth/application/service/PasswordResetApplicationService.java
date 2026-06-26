package com.mednova.auth.application.service;

import com.mednova.auth.application.dto.PasswordOtpVerificationResult;
import com.mednova.auth.application.port.out.AuthChallengeStorePort;
import com.mednova.auth.application.port.out.PasswordEncoderPort;
import com.mednova.auth.domain.model.User;
import com.mednova.auth.domain.port.UserRepository;
import com.mednova.auth.infrastructure.notification.EmailOtpSender;
import com.mednova.auth.infrastructure.security.OtpGenerator;
import com.mednova.common.exception.BusinessException;
import com.mednova.common.exception.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PasswordResetApplicationService {

    private static final Duration OTP_TTL = Duration.ofMinutes(10);
    private static final Duration RESET_TOKEN_TTL = Duration.ofMinutes(15);

    private final UserRepository userRepository;
    private final AuthChallengeStorePort challengeStore;
    private final OtpGenerator otpGenerator;
    private final EmailOtpSender emailOtpSender;
    private final PasswordEncoderPort passwordEncoderPort;

    public void requestReset(String email) {
        String normalizedEmail = email.toLowerCase();
        userRepository.findByEmail(normalizedEmail)
                .filter(User::isEnabled)
                .ifPresent(user -> {
                    String otp = otpGenerator.generateSixDigitCode();
                    challengeStore.storePasswordOtp(normalizedEmail, otpGenerator.hashCode(otp), OTP_TTL);
                    emailOtpSender.sendPasswordResetOtp(normalizedEmail, otp);
                });
    }

    public PasswordOtpVerificationResult verifyOtp(String email, String otp) {
        String normalizedEmail = email.toLowerCase();
        String storedHash = challengeStore.getPasswordOtpHash(normalizedEmail)
                .orElseThrow(() -> new UnauthorizedException("Code OTP invalide ou expiré"));

        if (!otpGenerator.matches(otp, storedHash)) {
            throw new UnauthorizedException("Code OTP invalide ou expiré");
        }

        User user = userRepository.findByEmail(normalizedEmail)
                .filter(User::isEnabled)
                .orElseThrow(() -> new UnauthorizedException("Code OTP invalide ou expiré"));

        challengeStore.deletePasswordOtp(normalizedEmail);
        String resetToken = UUID.randomUUID().toString();
        challengeStore.storePasswordResetToken(resetToken, user.getId(), RESET_TOKEN_TTL);
        return new PasswordOtpVerificationResult(resetToken);
    }

    @Transactional
    public void resetPassword(String resetToken, String newPassword) {
        UUID userId = challengeStore.consumePasswordResetToken(resetToken)
                .orElseThrow(() -> new UnauthorizedException("Jeton de réinitialisation invalide ou expiré"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UnauthorizedException("Utilisateur introuvable"));

        if (newPassword == null || newPassword.length() < 8) {
            throw new BusinessException("Le mot de passe doit contenir au moins 8 caractères");
        }

        userRepository.save(user.toBuilder()
                .passwordHash(passwordEncoderPort.encode(newPassword))
                .updatedAt(Instant.now())
                .build());
    }
}
