package com.mednova.patient.presentation.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;
import java.util.UUID;

public record CreateTreatmentRequest(
        @NotBlank String medication,
        @NotBlank String dosage,
        String frequency,
        @NotNull LocalDate startDate,
        LocalDate endDate,
        UUID prescribedBy,
        boolean active
) {
}
