package com.mednova.patient.presentation.dto;

import com.mednova.patient.domain.model.AllergySeverity;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public record AllergyResponse(
        UUID id,
        UUID patientId,
        String allergen,
        AllergySeverity severity,
        String reaction,
        LocalDate diagnosedAt,
        Instant createdAt
) {
}
