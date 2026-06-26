package com.mednova.ai.domain.model;

import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.util.UUID;

@Getter
@Builder
public class VitalsSnapshot {

    private final UUID readingId;
    private final UUID patientId;
    private final UUID patientUserId;
    private final Integer heartRate;
    private final Integer systolicBp;
    private final Integer diastolicBp;
    private final BigDecimal temperature;
    private final Integer oxygenSaturation;
    private final boolean anomalyDetected;
}
