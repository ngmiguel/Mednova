package com.mednova.auth.application.port.out;

import com.mednova.auth.domain.model.User;

import java.util.Optional;
import java.util.Set;
import java.util.UUID;

public interface JwtParserPort {

    Optional<UUID> extractUserId(String token);

    Optional<String> extractJti(String token);

    Set<String> extractRoles(String token);

    boolean isTokenValid(String token);

    Optional<User> extractAuthenticatedUser(String token);
}
