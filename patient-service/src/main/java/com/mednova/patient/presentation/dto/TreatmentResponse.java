package com.mednova.patient.presentation.dto;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public record TreatmentResponse(
        UUID id,
        UUID patientId,
        String medication,
        String dosage,
        String frequency,
        LocalDate startDate,
        LocalDate endDate,
        UUID prescribedBy,
        boolean active,
        Instant createdAt
) {
}
