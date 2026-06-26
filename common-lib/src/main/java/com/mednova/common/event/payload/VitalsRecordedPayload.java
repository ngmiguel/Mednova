package com.mednova.common.event.payload;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public record VitalsRecordedPayload(
        UUID readingId,
        UUID patientId,
        UUID patientUserId,
        Integer heartRate,
        Integer systolicBp,
        Integer diastolicBp,
        BigDecimal temperature,
        Integer oxygenSaturation,
        boolean anomalyDetected,
        Instant recordedAt
) {
}
