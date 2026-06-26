package com.mednova.auth.infrastructure.redis;

import com.mednova.auth.application.port.out.TokenBlacklistPort;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import java.time.Duration;

@Component
@RequiredArgsConstructor
public class RedisTokenBlacklistAdapter implements TokenBlacklistPort {

    private static final String KEY_PREFIX = "jwt:blacklist:";

    private final StringRedisTemplate redisTemplate;

    @Override
    public void blacklist(String jti, Duration ttl) {
        redisTemplate.opsForValue().set(KEY_PREFIX + jti, "1", ttl);
    }

    @Override
    public boolean isBlacklisted(String jti) {
        Boolean exists = redisTemplate.hasKey(KEY_PREFIX + jti);
        return Boolean.TRUE.equals(exists);
    }
}
