package com.mednova.auth.application.port.out;

import java.time.Duration;
import java.util.Optional;
import java.util.UUID;

public interface AuthChallengeStorePort {

    void storePendingTotpSecret(UUID userId, String secret, Duration ttl);

    Optional<String> consumePendingTotpSecret(UUID userId);

    void storeLoginChallenge(String challengeToken, UUID userId, Duration ttl);

    Optional<UUID> consumeLoginChallenge(String challengeToken);

    void storePasswordOtp(String email, String codeHash, Duration ttl);

    Optional<String> getPasswordOtpHash(String email);

    void deletePasswordOtp(String email);

    void storePasswordResetToken(String resetToken, UUID userId, Duration ttl);

    Optional<UUID> consumePasswordResetToken(String resetToken);
}
