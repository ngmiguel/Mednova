package com.mednova.monitoring.presentation.dto;

import jakarta.validation.constraints.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public record CreateVitalReadingRequest(
        @NotNull UUID patientId,
        UUID patientUserId,
        @Min(20) @Max(250) Integer heartRate,
        @Min(50) @Max(300) Integer systolicBp,
        @Min(30) @Max(200) Integer diastolicBp,
        @DecimalMin("30.0") @DecimalMax("45.0") BigDecimal temperature,
        @Min(50) @Max(100) Integer oxygenSaturation,
        Instant recordedAt
) {
}
