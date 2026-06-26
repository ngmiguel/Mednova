package com.mednova.appointment.application.security;

import com.mednova.appointment.domain.model.Appointment;
import com.mednova.appointment.domain.model.AppointmentStatus;
import com.mednova.common.exception.ForbiddenException;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.context.SecurityContextHolder;

import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class AppointmentAccessGuardTest {

    private final AppointmentAccessGuard guard = new AppointmentAccessGuard();
    private final UUID userId = UUID.randomUUID();

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void checkCanRead_patientSeesOwnAppointment() {
        Appointment appointment = appointment(userId, UUID.randomUUID());

        authenticate("ROLE_PATIENT");
        assertThatCode(() -> guard.checkCanRead(appointment)).doesNotThrowAnyException();
    }

    @Test
    void checkCanConfirm_patientCannotConfirm() {
        Appointment appointment = appointment(userId, UUID.randomUUID());

        authenticate("ROLE_PATIENT");
        assertThatThrownBy(() -> guard.checkCanConfirm(appointment)).isInstanceOf(ForbiddenException.class);
    }

    @Test
    void checkCanConfirm_assignedDoctorCanConfirm() {
        UUID doctorUserId = UUID.randomUUID();
        Appointment appointment = appointment(UUID.randomUUID(), doctorUserId);

        authenticate("ROLE_DOCTOR");
        SecurityContextHolder.getContext().setAuthentication(
                GatewayUserAuthentication.fromHeaders(doctorUserId, "ROLE_DOCTOR")
        );
        assertThatCode(() -> guard.checkCanConfirm(appointment)).doesNotThrowAnyException();
    }

    @Test
    void checkCanCreate_doctorCannotCreate() {
        authenticate("ROLE_DOCTOR");
        assertThatThrownBy(guard::checkCanCreate).isInstanceOf(ForbiddenException.class);
    }

    private Appointment appointment(UUID patientUserId, UUID doctorUserId) {
        return Appointment.builder()
                .id(UUID.randomUUID())
                .patientId(UUID.randomUUID())
                .doctorId(UUID.randomUUID())
                .patientUserId(patientUserId)
                .doctorUserId(doctorUserId)
                .scheduledAt(Instant.now().plusSeconds(3600))
                .durationMinutes(30)
                .status(AppointmentStatus.SCHEDULED)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();
    }

    private void authenticate(String... roles) {
        SecurityContextHolder.getContext().setAuthentication(
                GatewayUserAuthentication.fromHeaders(userId, String.join(",", roles))
        );
    }
}
