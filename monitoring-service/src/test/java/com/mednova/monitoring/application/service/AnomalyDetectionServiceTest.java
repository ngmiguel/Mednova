package com.mednova.monitoring.application.service;

import com.mednova.monitoring.domain.model.VitalReading;
import com.mednova.monitoring.infrastructure.config.AnomalyThresholdProperties;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class AnomalyDetectionServiceTest {

    private AnomalyDetectionService service;

    @BeforeEach
    void setUp() {
        service = new AnomalyDetectionService(new AnomalyThresholdProperties());
    }

    @Test
    void analyze_normalVitals_returnsNoAnomaly() {
        VitalReading reading = VitalReading.builder()
                .patientId(UUID.randomUUID())
                .heartRate(72)
                .systolicBp(120)
                .diastolicBp(80)
                .temperature(new BigDecimal("36.8"))
                .oxygenSaturation(98)
                .build();

        AnomalyDetectionService.AnomalyResult result = service.analyze(reading);

        assertThat(result.detected()).isFalse();
        assertThat(result.details()).isNull();
    }

    @Test
    void analyze_criticalVitals_detectsMultipleAnomalies() {
        VitalReading reading = VitalReading.builder()
                .patientId(UUID.randomUUID())
                .heartRate(145)
                .systolicBp(190)
                .diastolicBp(120)
                .temperature(new BigDecimal("39.5"))
                .oxygenSaturation(88)
                .build();

        AnomalyDetectionService.AnomalyResult result = service.analyze(reading);

        assertThat(result.detected()).isTrue();
        assertThat(result.details())
                .contains("Tachycardie")
                .contains("Hypertension systolique")
                .contains("Hypertension diastolique")
                .contains("Fièvre")
                .contains("SpO2 basse");
    }
}
