package com.mednova.monitoring.domain.model;

import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Getter
@Builder
public class VitalReading {

    private final UUID id;
    private final UUID patientId;
    private final UUID patientUserId;
    private final Integer heartRate;
    private final Integer systolicBp;
    private final Integer diastolicBp;
    private final BigDecimal temperature;
    private final Integer oxygenSaturation;
    private final boolean anomalyDetected;
    private final String anomalyDetails;
    private final Instant recordedAt;
    private final Instant createdAt;
}
