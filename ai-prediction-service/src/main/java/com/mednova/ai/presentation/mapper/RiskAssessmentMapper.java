package com.mednova.ai.presentation.mapper;

import com.mednova.ai.domain.model.RiskAssessment;
import com.mednova.ai.presentation.dto.RiskAssessmentResponse;
import org.springframework.stereotype.Component;

@Component
public class RiskAssessmentMapper {

    public RiskAssessmentResponse toResponse(RiskAssessment assessment) {
        return new RiskAssessmentResponse(
                assessment.getId(),
                assessment.getPatientId(),
                assessment.getPatientUserId(),
                assessment.getReadingId(),
                assessment.getRiskScore(),
                assessment.getRiskLevel(),
                assessment.getFactors(),
                assessment.getRecommendation(),
                assessment.getTriggerEventType(),
                assessment.getAssessedAt(),
                assessment.getCreatedAt()
        );
    }
}
