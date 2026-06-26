package com.mednova.ai.presentation.dto;

import com.mednova.ai.domain.model.RiskLevel;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record RiskAssessmentResponse(
        UUID id,
        UUID patientId,
        UUID patientUserId,
        UUID readingId,
        int riskScore,
        RiskLevel riskLevel,
        List<String> factors,
        String recommendation,
        String triggerEventType,
        Instant assessedAt,
        Instant createdAt
) {
}
