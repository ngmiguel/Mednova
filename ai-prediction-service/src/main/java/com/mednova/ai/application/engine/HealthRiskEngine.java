package com.mednova.ai.application.engine;

import com.mednova.ai.domain.model.RiskLevel;
import com.mednova.ai.domain.model.VitalsSnapshot;
import com.mednova.ai.infrastructure.config.RiskThresholdProperties;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class HealthRiskEngine {

    private final RiskThresholdProperties thresholds;

    public RiskResult evaluate(VitalsSnapshot vitals) {
        int score = 10;
        List<String> factors = new ArrayList<>();

        if (vitals.isAnomalyDetected()) {
            score += 25;
            factors.add("Anomalie détectée sur les constantes vitales");
        }

        if (vitals.getHeartRate() != null) {
            if (vitals.getHeartRate() > 120) {
                score += 20;
                factors.add("Tachycardie (" + vitals.getHeartRate() + " bpm)");
            } else if (vitals.getHeartRate() < 50) {
                score += 20;
                factors.add("Bradycardie (" + vitals.getHeartRate() + " bpm)");
            }
        }

        if (vitals.getSystolicBp() != null && vitals.getSystolicBp() > 160) {
            score += 15;
            factors.add("Hypertension systolique (" + vitals.getSystolicBp() + " mmHg)");
        }

        if (vitals.getDiastolicBp() != null && vitals.getDiastolicBp() > 110) {
            score += 10;
            factors.add("Hypertension diastolique (" + vitals.getDiastolicBp() + " mmHg)");
        }

        if (vitals.getTemperature() != null && vitals.getTemperature().compareTo(new BigDecimal("38.5")) > 0) {
            score += 15;
            factors.add("Fièvre (" + vitals.getTemperature() + " °C)");
        }

        if (vitals.getOxygenSaturation() != null && vitals.getOxygenSaturation() < 92) {
            score += 25;
            factors.add("SpO2 critique (" + vitals.getOxygenSaturation() + " %)");
        }

        score = Math.min(score, 100);
        RiskLevel level = resolveLevel(score);

        if (factors.isEmpty()) {
            factors.add("Paramètres vitaux dans les normes");
        }

        return new RiskResult(score, level, factors, buildRecommendation(level));
    }

    private RiskLevel resolveLevel(int score) {
        if (score >= thresholds.getCriticalThreshold()) {
            return RiskLevel.CRITICAL;
        }
        if (score >= thresholds.getHighThreshold()) {
            return RiskLevel.HIGH;
        }
        if (score >= 30) {
            return RiskLevel.MODERATE;
        }
        return RiskLevel.LOW;
    }

    private String buildRecommendation(RiskLevel level) {
        return switch (level) {
            case CRITICAL -> "Intervention médicale immédiate recommandée — alerte équipe soignante";
            case HIGH -> "Surveillance rapprochée et consultation médicale dans les 24h";
            case MODERATE -> "Suivi régulier conseillé — reprogrammer un contrôle";
            case LOW -> "Risque faible — maintenir le suivi habituel";
        };
    }

    public record RiskResult(int score, RiskLevel level, List<String> factors, String recommendation) {
    }
}
