package com.mednova.ai.application.service;

import com.mednova.ai.application.engine.HealthRiskEngine;
import com.mednova.ai.domain.model.RiskAssessment;
import com.mednova.ai.domain.model.VitalsSnapshot;
import com.mednova.ai.domain.port.RiskAssessmentRepository;
import com.mednova.ai.infrastructure.kafka.RiskEventPublisher;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class RiskAssessmentApplicationService {

    private final HealthRiskEngine healthRiskEngine;
    private final RiskAssessmentRepository riskAssessmentRepository;
    private final RiskEventPublisher riskEventPublisher;

    @Transactional
    public RiskAssessment assessFromVitals(VitalsSnapshot vitals, String triggerEventType, String correlationId) {
        var result = healthRiskEngine.evaluate(vitals);

        RiskAssessment assessment = RiskAssessment.builder()
                .id(UUID.randomUUID())
                .patientId(vitals.getPatientId())
                .patientUserId(vitals.getPatientUserId())
                .readingId(vitals.getReadingId())
                .riskScore(result.score())
                .riskLevel(result.level())
                .factors(result.factors())
                .recommendation(result.recommendation())
                .triggerEventType(triggerEventType)
                .correlationId(correlationId)
                .assessedAt(Instant.now())
                .createdAt(Instant.now())
                .build();

        RiskAssessment saved = riskAssessmentRepository.save(assessment);
        riskEventPublisher.publishAssessmentCompleted(saved, correlationId);

        log.info("Risk assessment completed for patient {} — score {} ({})",
                vitals.getPatientId(), result.score(), result.level());

        return saved;
    }
}
