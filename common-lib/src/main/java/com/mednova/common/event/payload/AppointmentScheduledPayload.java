package com.mednova.common.event.payload;

import java.time.Instant;
import java.util.UUID;

public record AppointmentScheduledPayload(
        UUID appointmentId,
        UUID patientId,
        UUID doctorId,
        Instant scheduledAt,
        String reason
) {
}
