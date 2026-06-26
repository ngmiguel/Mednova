package com.mednova.common.event.payload;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record RiskAssessmentCompletedPayload(
        UUID assessmentId,
        UUID patientId,
        int riskScore,
        String riskLevel,
        List<String> factors,
        String recommendation,
        Instant assessedAt
) {
}
