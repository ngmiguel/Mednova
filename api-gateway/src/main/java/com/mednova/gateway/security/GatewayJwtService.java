package com.mednova.gateway.security;

import com.mednova.gateway.config.GatewayJwtProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.ReactiveStringRedisTemplate;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class GatewayJwtService {

    private static final String BLACKLIST_PREFIX = "jwt:blacklist:";

    private final GatewayJwtProperties jwtProperties;
    private final ReactiveStringRedisTemplate redisTemplate;

    public Optional<JwtClaims> parseToken(String token) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(signingKey())
                    .build()
                    .parseSignedClaims(stripBearerPrefix(token))
                    .getPayload();

            return Optional.of(new JwtClaims(
                    UUID.fromString(claims.getSubject()),
                    claims.getId(),
                    claims.get("email", String.class),
                    claims.get("roles", List.class)
            ));
        } catch (JwtException | IllegalArgumentException ex) {
            return Optional.empty();
        }
    }

    public reactor.core.publisher.Mono<Boolean> isBlacklisted(String jti) {
        return redisTemplate.hasKey(BLACKLIST_PREFIX + jti);
    }

    private SecretKey signingKey() {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] keyBytes = digest.digest(jwtProperties.getSecret().getBytes(StandardCharsets.UTF_8));
            return Keys.hmacShaKeyFor(keyBytes);
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("Algorithme SHA-256 indisponible", ex);
        }
    }

    private String stripBearerPrefix(String token) {
        if (token != null && token.startsWith("Bearer ")) {
            return token.substring(7);
        }
        return token;
    }

    public record JwtClaims(UUID userId, String jti, String email, List<String> roles) {
    }
}
