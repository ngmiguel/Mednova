package com.mednova.monitoring.presentation.dto;

import java.util.UUID;

public record VitalAlertMessage(
        UUID readingId,
        UUID patientId,
        String message,
        VitalReadingResponse reading
) {
}
