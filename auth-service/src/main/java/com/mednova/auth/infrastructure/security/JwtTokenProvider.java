package com.mednova.auth.infrastructure.security;

import com.mednova.auth.application.dto.AuthTokens;
import com.mednova.auth.application.port.out.JwtParserPort;
import com.mednova.auth.application.port.out.TokenProviderPort;
import com.mednova.auth.domain.model.RoleType;
import com.mednova.auth.domain.model.User;
import com.mednova.auth.infrastructure.config.JwtProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Duration;
import java.time.Instant;
import java.util.Date;
import java.util.HexFormat;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class JwtTokenProvider implements TokenProviderPort, JwtParserPort {

    private static final String TOKEN_TYPE = "Bearer";

    private final JwtProperties jwtProperties;

    @Override
    public String generateAccessToken(User user) {
        Instant now = Instant.now();
        Instant expiry = now.plusMillis(jwtProperties.getAccessTokenExpirationMs());

        return Jwts.builder()
                .id(UUID.randomUUID().toString())
                .subject(user.getId().toString())
                .claim("email", user.getEmail())
                .claim("roles", user.getRoles().stream().map(RoleType::name).toList())
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiry))
                .signWith(signingKey())
                .compact();
    }

    @Override
    public String generateRefreshTokenValue() {
        return UUID.randomUUID() + "." + UUID.randomUUID();
    }

    @Override
    public String hashToken(String token) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(token.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("Algorithme SHA-256 indisponible", ex);
        }
    }

    @Override
    public Duration getAccessTokenExpiration() {
        return Duration.ofMillis(jwtProperties.getAccessTokenExpirationMs());
    }

    @Override
    public Duration getRefreshTokenExpiration() {
        return Duration.ofMillis(jwtProperties.getRefreshTokenExpirationMs());
    }

    @Override
    public AuthTokens buildAuthTokens(User user, String refreshTokenValue) {
        return AuthTokens.withTokens(
                generateAccessToken(user),
                refreshTokenValue,
                TOKEN_TYPE,
                jwtProperties.getAccessTokenExpirationMs() / 1000,
                user.getRoles()
        );
    }

    @Override
    public Optional<UUID> extractUserId(String token) {
        return parseClaims(token).map(claims -> UUID.fromString(claims.getSubject()));
    }

    @Override
    public Optional<String> extractJti(String token) {
        return parseClaims(token).map(Claims::getId);
    }

    @Override
    @SuppressWarnings("unchecked")
    public Set<String> extractRoles(String token) {
        return parseClaims(token)
                .map(claims -> (List<String>) claims.get("roles", List.class))
                .map(roles -> roles.stream().collect(Collectors.toSet()))
                .orElse(Set.of());
    }

    @Override
    public boolean isTokenValid(String token) {
        return parseClaims(token).isPresent();
    }

    @Override
    public Optional<User> extractAuthenticatedUser(String token) {
        return parseClaims(token).map(claims -> User.builder()
                .id(UUID.fromString(claims.getSubject()))
                .email(claims.get("email", String.class))
                .roles(extractRoles(token).stream()
                        .map(RoleType::valueOf)
                        .collect(Collectors.toSet()))
                .enabled(true)
                .build());
    }

    private Optional<Claims> parseClaims(String token) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(signingKey())
                    .build()
                    .parseSignedClaims(stripBearerPrefix(token))
                    .getPayload();
            return Optional.of(claims);
        } catch (JwtException | IllegalArgumentException ex) {
            return Optional.empty();
        }
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
}
