package com.mednova.ai.infrastructure.kafka;

import com.mednova.ai.domain.model.RiskAssessment;
import com.mednova.common.event.EventTypes;
import com.mednova.common.event.payload.HealthAlertTriggeredPayload;
import com.mednova.common.event.payload.RiskAssessmentCompletedPayload;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class RiskEventPublisher {

    private final DomainEventPublisher domainEventPublisher;

    public void publishAssessmentCompleted(RiskAssessment assessment, String correlationId) {
        String correlation = correlationId != null ? correlationId : UUID.randomUUID().toString();

        domainEventPublisher.publish(
                EventTypes.RISK_ASSESSMENT_COMPLETED,
                correlation,
                new RiskAssessmentCompletedPayload(
                        assessment.getId(),
                        assessment.getPatientId(),
                        assessment.getRiskScore(),
                        assessment.getRiskLevel().name(),
                        assessment.getFactors(),
                        assessment.getRecommendation(),
                        assessment.getAssessedAt()
                )
        );

        if (assessment.getRiskLevel().requiresAlert()) {
            domainEventPublisher.publish(
                    EventTypes.HEALTH_ALERT_TRIGGERED,
                    correlation,
                    new HealthAlertTriggeredPayload(
                            assessment.getId(),
                            assessment.getPatientId(),
                            assessment.getRiskLevel().name(),
                            assessment.getRiskScore(),
                            assessment.getRecommendation()
                    )
            );
        }
    }
}
