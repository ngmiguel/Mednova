package com.mednova.audit.application.security;

import com.mednova.common.exception.ForbiddenException;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class AuditAccessGuardTest {

    private final AuditAccessGuard guard = new AuditAccessGuard();

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void checkCanRead_adminAndAuditorAllowed() {
        authenticate("ROLE_ADMIN");
        assertThatCode(guard::checkCanRead).doesNotThrowAnyException();

        authenticate("ROLE_AUDITOR");
        assertThatCode(guard::checkCanRead).doesNotThrowAnyException();
    }

    @Test
    void checkCanRead_doctorForbidden() {
        authenticate("ROLE_DOCTOR");
        assertThatThrownBy(guard::checkCanRead).isInstanceOf(ForbiddenException.class);
    }

    private void authenticate(String... roles) {
        SecurityContextHolder.getContext().setAuthentication(
                GatewayUserAuthentication.fromHeaders(UUID.randomUUID(), String.join(",", roles))
        );
    }
}
