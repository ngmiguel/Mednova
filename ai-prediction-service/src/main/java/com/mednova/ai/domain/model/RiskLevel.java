package com.mednova.ai.domain.model;

public enum RiskLevel {
    LOW,
    MODERATE,
    HIGH,
    CRITICAL;

    public boolean requiresAlert() {
        return this == HIGH || this == CRITICAL;
    }
}
