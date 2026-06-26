package com.mednova.common.event.payload;

import java.util.UUID;

public record AppointmentCancelledPayload(
        UUID appointmentId,
        UUID patientId,
        UUID doctorId,
        String reason
) {
}
