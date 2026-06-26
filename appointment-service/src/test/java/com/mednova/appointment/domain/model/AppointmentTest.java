package com.mednova.appointment.domain.model;

import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class AppointmentTest {

    @Test
    void isActive_scheduledOrConfirmed() {
        assertThat(appointment(AppointmentStatus.SCHEDULED).isActive()).isTrue();
        assertThat(appointment(AppointmentStatus.CONFIRMED).isActive()).isTrue();
        assertThat(appointment(AppointmentStatus.CANCELLED).isActive()).isFalse();
        assertThat(appointment(AppointmentStatus.COMPLETED).isActive()).isFalse();
    }

    private Appointment appointment(AppointmentStatus status) {
        return Appointment.builder()
                .id(UUID.randomUUID())
                .patientId(UUID.randomUUID())
                .doctorId(UUID.randomUUID())
                .patientUserId(UUID.randomUUID())
                .doctorUserId(UUID.randomUUID())
                .scheduledAt(Instant.now())
                .durationMinutes(30)
                .status(status)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();
    }
}
