package com.mednova.monitoring.presentation.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public record VitalReadingResponse(
        UUID id,
        UUID patientId,
        UUID patientUserId,
        Integer heartRate,
        Integer systolicBp,
        Integer diastolicBp,
        BigDecimal temperature,
        Integer oxygenSaturation,
        boolean anomalyDetected,
        String anomalyDetails,
        Instant recordedAt,
        Instant createdAt
) {
}
