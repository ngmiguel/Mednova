package com.mednova.ai.application.engine;

import com.mednova.ai.domain.model.RiskLevel;
import com.mednova.ai.domain.model.VitalsSnapshot;
import com.mednova.ai.infrastructure.config.RiskThresholdProperties;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class HealthRiskEngineTest {

    private HealthRiskEngine engine;

    @BeforeEach
    void setUp() {
        RiskThresholdProperties thresholds = new RiskThresholdProperties();
        thresholds.setHighThreshold(60);
        thresholds.setCriticalThreshold(80);
        engine = new HealthRiskEngine(thresholds);
    }

    @Test
    void evaluate_normalVitals_returnsLowRisk() {
        VitalsSnapshot vitals = VitalsSnapshot.builder()
                .patientId(UUID.randomUUID())
                .heartRate(72)
                .systolicBp(120)
                .diastolicBp(80)
                .temperature(new BigDecimal("36.8"))
                .oxygenSaturation(98)
                .anomalyDetected(false)
                .build();

        HealthRiskEngine.RiskResult result = engine.evaluate(vitals);

        assertThat(result.score()).isEqualTo(10);
        assertThat(result.level()).isEqualTo(RiskLevel.LOW);
        assertThat(result.factors()).containsExactly("Paramètres vitaux dans les normes");
    }

    @Test
    void evaluate_criticalVitals_returnsCriticalRiskCappedAt100() {
        VitalsSnapshot vitals = VitalsSnapshot.builder()
                .patientId(UUID.randomUUID())
                .heartRate(145)
                .systolicBp(190)
                .diastolicBp(120)
                .temperature(new BigDecimal("39.5"))
                .oxygenSaturation(88)
                .anomalyDetected(true)
                .build();

        HealthRiskEngine.RiskResult result = engine.evaluate(vitals);

        assertThat(result.score()).isEqualTo(100);
        assertThat(result.level()).isEqualTo(RiskLevel.CRITICAL);
        assertThat(result.factors()).hasSize(6);
        assertThat(result.recommendation()).contains("Intervention médicale immédiate");
    }
}
