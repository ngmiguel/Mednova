package com.mednova.patient.application.security;

import org.junit.jupiter.api.Test;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class GatewayUserAuthenticationTest {

    @Test
    void fromHeaders_parsesRoles() {
        UUID userId = UUID.randomUUID();
        var auth = GatewayUserAuthentication.fromHeaders(userId, "ROLE_DOCTOR, ROLE_NURSE");

        assertThat(auth.getUserId()).isEqualTo(userId);
        assertThat(auth.getAuthorities())
                .extracting(SimpleGrantedAuthority.class::cast)
                .extracting(SimpleGrantedAuthority::getAuthority)
                .containsExactlyInAnyOrder("ROLE_DOCTOR", "ROLE_NURSE");
    }

    @Test
    void hasRole_matchesExactAuthority() {
        var auth = GatewayUserAuthentication.fromHeaders(UUID.randomUUID(), "ROLE_PATIENT");

        assertThat(auth.hasRole("ROLE_PATIENT")).isTrue();
        assertThat(auth.hasRole("PATIENT")).isFalse();
    }
}
