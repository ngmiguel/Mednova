package com.mednova.gateway.security;

import com.mednova.gateway.config.GatewayJwtProperties;
import io.jsonwebtoken.Jwts;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.redis.core.ReactiveStringRedisTemplate;
import reactor.core.publisher.Mono;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Instant;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GatewayJwtServiceTest {

    private static final String SECRET = "change-me-in-production-use-a-long-random-secret-key-at-least-32-chars";

    @Mock
    private ReactiveStringRedisTemplate redisTemplate;

    private GatewayJwtService service;

    @BeforeEach
    void setUp() {
        GatewayJwtProperties properties = new GatewayJwtProperties();
        properties.setSecret(SECRET);
        service = new GatewayJwtService(properties, redisTemplate);
    }

    @Test
    void parseToken_validToken_returnsClaims() {
        UUID userId = UUID.randomUUID();
        String token = buildToken(userId, "user@mednova.ai", List.of("ROLE_DOCTOR"));

        var claims = service.parseToken(token);

        assertThat(claims).isPresent();
        assertThat(claims.get().userId()).isEqualTo(userId);
        assertThat(claims.get().email()).isEqualTo("user@mednova.ai");
        assertThat(claims.get().roles()).containsExactly("ROLE_DOCTOR");
    }

    @Test
    void parseToken_bearerPrefixIsStripped() {
        UUID userId = UUID.randomUUID();
        String token = "Bearer " + buildToken(userId, "user@mednova.ai", List.of("ROLE_PATIENT"));

        var claims = service.parseToken(token);

        assertThat(claims).isPresent();
        assertThat(claims.get().userId()).isEqualTo(userId);
    }

    @Test
    void parseToken_invalidToken_returnsEmpty() {
        assertThat(service.parseToken("invalid.token.value")).isEmpty();
    }

    @Test
    void isBlacklisted_whenKeyExists_returnsTrue() {
        when(redisTemplate.hasKey(anyString())).thenReturn(Mono.just(true));

        assertThat(service.isBlacklisted("jti-123").block()).isTrue();
    }

    private String buildToken(UUID userId, String email, List<String> roles) {
        Instant now = Instant.now();
        return Jwts.builder()
                .id(UUID.randomUUID().toString())
                .subject(userId.toString())
                .claim("email", email)
                .claim("roles", roles)
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plusSeconds(900)))
                .signWith(signingKey())
                .compact();
    }

    private SecretKey signingKey() {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] keyBytes = digest.digest(SECRET.getBytes(StandardCharsets.UTF_8));
            return io.jsonwebtoken.security.Keys.hmacShaKeyFor(keyBytes);
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException(ex);
        }
    }
}
