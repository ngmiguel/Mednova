package com.mednova.appointment.presentation.dto;

import com.mednova.appointment.domain.model.AppointmentStatus;
import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.Instant;
import java.util.UUID;

public record CreateAppointmentRequest(
        @NotNull UUID patientId,
        @NotNull UUID doctorId,
        UUID patientUserId,
        @NotNull UUID doctorUserId,
        @NotNull @Future Instant scheduledAt,
        @Min(1) Integer durationMinutes,
        @NotBlank String reason,
        String notes
) {
}
