package com.mednova.appointment.domain.model;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

@Getter
@Builder
public class Appointment {

    private final UUID id;
    private final UUID patientId;
    private final UUID doctorId;
    private final UUID patientUserId;
    private final UUID doctorUserId;
    private final Instant scheduledAt;
    private final int durationMinutes;
    private final String reason;
    private final String notes;
    private final AppointmentStatus status;
    private final Instant createdAt;
    private final Instant updatedAt;

    public boolean isActive() {
        return status == AppointmentStatus.SCHEDULED || status == AppointmentStatus.CONFIRMED;
    }
}
