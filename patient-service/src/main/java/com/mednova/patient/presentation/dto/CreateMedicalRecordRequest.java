package com.mednova.patient.presentation.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;
import java.util.UUID;

public record CreateMedicalRecordRequest(
        UUID doctorId,
        @NotBlank(message = "Le diagnostic est obligatoire") String diagnosis,
        String notes,
        @NotNull(message = "La date de visite est obligatoire") LocalDate visitDate
) {
}
