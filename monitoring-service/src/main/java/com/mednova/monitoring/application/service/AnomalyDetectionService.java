package com.mednova.monitoring.application.service;

import com.mednova.monitoring.domain.model.VitalReading;
import com.mednova.monitoring.infrastructure.config.AnomalyThresholdProperties;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AnomalyDetectionService {

    private final AnomalyThresholdProperties thresholds;

    public AnomalyResult analyze(VitalReading reading) {
        List<String> anomalies = new ArrayList<>();

        if (reading.getHeartRate() != null) {
            if (reading.getHeartRate() < thresholds.getHeartRateMin()) {
                anomalies.add("Bradycardie : fréquence cardiaque " + reading.getHeartRate() + " bpm");
            } else if (reading.getHeartRate() > thresholds.getHeartRateMax()) {
                anomalies.add("Tachycardie : fréquence cardiaque " + reading.getHeartRate() + " bpm");
            }
        }

        if (reading.getSystolicBp() != null) {
            if (reading.getSystolicBp() < thresholds.getSystolicBpMin()) {
                anomalies.add("Hypotension systolique : " + reading.getSystolicBp() + " mmHg");
            } else if (reading.getSystolicBp() > thresholds.getSystolicBpMax()) {
                anomalies.add("Hypertension systolique : " + reading.getSystolicBp() + " mmHg");
            }
        }

        if (reading.getDiastolicBp() != null) {
            if (reading.getDiastolicBp() < thresholds.getDiastolicBpMin()) {
                anomalies.add("Hypotension diastolique : " + reading.getDiastolicBp() + " mmHg");
            } else if (reading.getDiastolicBp() > thresholds.getDiastolicBpMax()) {
                anomalies.add("Hypertension diastolique : " + reading.getDiastolicBp() + " mmHg");
            }
        }

        if (reading.getTemperature() != null) {
            if (reading.getTemperature().compareTo(thresholds.getTemperatureMin()) < 0) {
                anomalies.add("Hypothermie : " + reading.getTemperature() + " °C");
            } else if (reading.getTemperature().compareTo(thresholds.getTemperatureMax()) > 0) {
                anomalies.add("Fièvre : " + reading.getTemperature() + " °C");
            }
        }

        if (reading.getOxygenSaturation() != null && reading.getOxygenSaturation() < thresholds.getOxygenSaturationMin()) {
            anomalies.add("SpO2 basse : " + reading.getOxygenSaturation() + " %");
        }

        if (anomalies.isEmpty()) {
            return AnomalyResult.normal();
        }
        return AnomalyResult.anomaly(String.join("; ", anomalies));
    }

    public record AnomalyResult(boolean detected, String details) {
        public static AnomalyResult normal() {
            return new AnomalyResult(false, null);
        }

        public static AnomalyResult anomaly(String details) {
            return new AnomalyResult(true, details);
        }
    }
}
