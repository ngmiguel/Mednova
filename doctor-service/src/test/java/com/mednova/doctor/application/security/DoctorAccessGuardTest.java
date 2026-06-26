package com.mednova.doctor.application.security;

import com.mednova.common.exception.ForbiddenException;
import com.mednova.doctor.domain.model.Doctor;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class DoctorAccessGuardTest {

    private final DoctorAccessGuard guard = new DoctorAccessGuard();
    private final UUID userId = UUID.randomUUID();

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void checkCanCreate_onlyAdmin() {
        authenticate("ROLE_DOCTOR");
        assertThatThrownBy(guard::checkCanCreate).isInstanceOf(ForbiddenException.class);

        authenticate("ROLE_ADMIN");
        assertThatCode(guard::checkCanCreate).doesNotThrowAnyException();
    }

    @Test
    void checkCanUpdate_doctorCanUpdateOwnProfile() {
        Doctor own = Doctor.builder().userId(userId).build();
        Doctor other = Doctor.builder().userId(UUID.randomUUID()).build();

        authenticate("ROLE_DOCTOR");
        assertThatCode(() -> guard.checkCanUpdate(own)).doesNotThrowAnyException();
        assertThatThrownBy(() -> guard.checkCanUpdate(other)).isInstanceOf(ForbiddenException.class);
    }

    @Test
    void checkCanManageAvailability_nurseCanManageAnyDoctor() {
        Doctor doctor = Doctor.builder().userId(UUID.randomUUID()).build();

        authenticate("ROLE_NURSE");
        assertThatCode(() -> guard.checkCanManageAvailability(doctor)).doesNotThrowAnyException();
    }

    private void authenticate(String... roles) {
        SecurityContextHolder.getContext().setAuthentication(
                GatewayUserAuthentication.fromHeaders(userId, String.join(",", roles))
        );
    }
}
