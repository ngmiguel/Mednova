package com.mednova.auth.infrastructure.redis;

import com.mednova.auth.application.port.out.AuthChallengeStorePort;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.util.Optional;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class RedisAuthChallengeStoreAdapter implements AuthChallengeStorePort {

    private static final String PENDING_TOTP_PREFIX = "auth:2fa-pending:";
    private static final String LOGIN_CHALLENGE_PREFIX = "auth:2fa-challenge:";
    private static final String PASSWORD_OTP_PREFIX = "auth:password-otp:";
    private static final String PASSWORD_RESET_PREFIX = "auth:password-reset:";

    private final StringRedisTemplate redisTemplate;

    @Override
    public void storePendingTotpSecret(UUID userId, String secret, Duration ttl) {
        redisTemplate.opsForValue().set(PENDING_TOTP_PREFIX + userId, secret, ttl);
    }

    @Override
    public Optional<String> consumePendingTotpSecret(UUID userId) {
        String key = PENDING_TOTP_PREFIX + userId;
        String secret = redisTemplate.opsForValue().get(key);
        if (secret == null) {
            return Optional.empty();
        }
        redisTemplate.delete(key);
        return Optional.of(secret);
    }

    @Override
    public void storeLoginChallenge(String challengeToken, UUID userId, Duration ttl) {
        redisTemplate.opsForValue().set(LOGIN_CHALLENGE_PREFIX + challengeToken, userId.toString(), ttl);
    }

    @Override
    public Optional<UUID> consumeLoginChallenge(String challengeToken) {
        String key = LOGIN_CHALLENGE_PREFIX + challengeToken;
        String userId = redisTemplate.opsForValue().get(key);
        if (userId == null) {
            return Optional.empty();
        }
        redisTemplate.delete(key);
        return Optional.of(UUID.fromString(userId));
    }

    @Override
    public void storePasswordOtp(String email, String codeHash, Duration ttl) {
        redisTemplate.opsForValue().set(PASSWORD_OTP_PREFIX + email.toLowerCase(), codeHash, ttl);
    }

    @Override
    public Optional<String> getPasswordOtpHash(String email) {
        return Optional.ofNullable(redisTemplate.opsForValue().get(PASSWORD_OTP_PREFIX + email.toLowerCase()));
    }

    @Override
    public void deletePasswordOtp(String email) {
        redisTemplate.delete(PASSWORD_OTP_PREFIX + email.toLowerCase());
    }

    @Override
    public void storePasswordResetToken(String resetToken, UUID userId, Duration ttl) {
        redisTemplate.opsForValue().set(PASSWORD_RESET_PREFIX + resetToken, userId.toString(), ttl);
    }

    @Override
    public Optional<UUID> consumePasswordResetToken(String resetToken) {
        String key = PASSWORD_RESET_PREFIX + resetToken;
        String userId = redisTemplate.opsForValue().get(key);
        if (userId == null) {
            return Optional.empty();
        }
        redisTemplate.delete(key);
        return Optional.of(UUID.fromString(userId));
    }
}
