package com.mednova.patient.application.security;

import com.mednova.common.exception.ForbiddenException;
import com.mednova.patient.domain.model.Patient;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class PatientAccessGuardTest {

    private final PatientAccessGuard guard = new PatientAccessGuard();
    private final UUID userId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        authenticate("ROLE_DOCTOR");
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void checkCanRead_doctorCanReadAnyPatient() {
        Patient patient = Patient.builder().userId(UUID.randomUUID()).build();

        assertThatCode(() -> guard.checkCanRead(patient)).doesNotThrowAnyException();
    }

    @Test
    void checkCanRead_patientCanReadOwnRecordOnly() {
        authenticate("ROLE_PATIENT");
        Patient own = Patient.builder().userId(userId).build();
        Patient other = Patient.builder().userId(UUID.randomUUID()).build();

        assertThatCode(() -> guard.checkCanRead(own)).doesNotThrowAnyException();
        assertThatThrownBy(() -> guard.checkCanRead(other)).isInstanceOf(ForbiddenException.class);
    }

    @Test
    void checkCanList_patientIsForbidden() {
        authenticate("ROLE_PATIENT");

        assertThatThrownBy(guard::checkCanList).isInstanceOf(ForbiddenException.class);
    }

    @Test
    void checkCanDelete_onlyAdmin() {
        authenticate("ROLE_DOCTOR");
        assertThatThrownBy(guard::checkCanDelete).isInstanceOf(ForbiddenException.class);

        authenticate("ROLE_ADMIN");
        assertThatCode(guard::checkCanDelete).doesNotThrowAnyException();
    }

    private void authenticate(String... roles) {
        SecurityContextHolder.getContext().setAuthentication(
                GatewayUserAuthentication.fromHeaders(userId, String.join(",", roles))
        );
    }
}
