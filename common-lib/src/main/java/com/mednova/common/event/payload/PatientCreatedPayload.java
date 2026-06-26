package com.mednova.common.event.payload;

import java.util.UUID;

public record PatientCreatedPayload(
        UUID patientId,
        UUID userId,
        String firstName,
        String lastName,
        String email
) {
}
