package com.mednova.ai.infrastructure.persistence.mapper;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mednova.ai.domain.model.RiskAssessment;
import com.mednova.ai.infrastructure.persistence.entity.RiskAssessmentEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class PersistenceMapper {

    private final ObjectMapper objectMapper;

    public RiskAssessment toDomain(RiskAssessmentEntity entity) {
        return RiskAssessment.builder()
                .id(entity.getId())
                .patientId(entity.getPatientId())
                .patientUserId(entity.getPatientUserId())
                .readingId(entity.getReadingId())
                .riskScore(entity.getRiskScore())
                .riskLevel(entity.getRiskLevel())
                .factors(readFactors(entity.getFactors()))
                .recommendation(entity.getRecommendation())
                .triggerEventType(entity.getTriggerEventType())
                .correlationId(entity.getCorrelationId())
                .assessedAt(entity.getAssessedAt())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public RiskAssessmentEntity toEntity(RiskAssessment assessment) {
        return RiskAssessmentEntity.builder()
                .id(assessment.getId())
                .patientId(assessment.getPatientId())
                .patientUserId(assessment.getPatientUserId())
                .readingId(assessment.getReadingId())
                .riskScore(assessment.getRiskScore())
                .riskLevel(assessment.getRiskLevel())
                .factors(writeFactors(assessment.getFactors()))
                .recommendation(assessment.getRecommendation())
                .triggerEventType(assessment.getTriggerEventType())
                .correlationId(assessment.getCorrelationId())
                .assessedAt(assessment.getAssessedAt())
                .createdAt(assessment.getCreatedAt())
                .build();
    }

    private List<String> readFactors(String json) {
        try {
            return objectMapper.readValue(json, new TypeReference<>() {});
        } catch (Exception ex) {
            return List.of(json);
        }
    }

    private String writeFactors(List<String> factors) {
        try {
            return objectMapper.writeValueAsString(factors);
        } catch (Exception ex) {
            return "[]";
        }
    }
}
