package com.mednova.patient.presentation.dto;

import com.mednova.patient.domain.model.AllergySeverity;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;

public record CreateAllergyRequest(
        @NotBlank(message = "L'allergène est obligatoire") String allergen,
        @NotNull(message = "La sévérité est obligatoire") AllergySeverity severity,
        String reaction,
        LocalDate diagnosedAt
) {
}
