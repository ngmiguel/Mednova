package com.mednova.common.event.payload;

import java.util.UUID;

public record HealthAlertTriggeredPayload(
        UUID assessmentId,
        UUID patientId,
        String riskLevel,
        int riskScore,
        String message
) {
}
