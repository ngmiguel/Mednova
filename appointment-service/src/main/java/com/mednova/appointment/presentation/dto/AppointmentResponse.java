package com.mednova.appointment.presentation.dto;

import com.mednova.appointment.domain.model.AppointmentStatus;

import java.time.Instant;
import java.util.UUID;

public record AppointmentResponse(
        UUID id,
        UUID patientId,
        UUID doctorId,
        UUID patientUserId,
        UUID doctorUserId,
        Instant scheduledAt,
        int durationMinutes,
        String reason,
        String notes,
        AppointmentStatus status,
        Instant createdAt,
        Instant updatedAt
) {
}
