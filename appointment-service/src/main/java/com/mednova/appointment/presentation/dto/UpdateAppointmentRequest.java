package com.mednova.appointment.presentation.dto;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.Min;

import java.time.Instant;

public record UpdateAppointmentRequest(
        @Future Instant scheduledAt,
        @Min(1) Integer durationMinutes,
        String reason,
        String notes
) {
}
