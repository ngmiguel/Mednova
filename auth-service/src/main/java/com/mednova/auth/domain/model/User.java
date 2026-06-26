package com.mednova.auth.domain.model;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;

@Getter
@Builder(toBuilder = true)
public class User {

    private UUID id;
    private String email;
    private String passwordHash;
    private String firstName;
    private String lastName;
    private boolean enabled;
    private boolean twoFactorEnabled;
    private String totpSecret;
    private Set<RoleType> roles;
    private Instant createdAt;
    private Instant updatedAt;
}
