package com.mednova.ai.domain.model;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Getter
@Builder
public class RiskAssessment {

    private final UUID id;
    private final UUID patientId;
    private final UUID patientUserId;
    private final UUID readingId;
    private final int riskScore;
    private final RiskLevel riskLevel;
    private final List<String> factors;
    private final String recommendation;
    private final String triggerEventType;
    private final String correlationId;
    private final Instant assessedAt;
    private final Instant createdAt;
}
