package com.mednova.patient.presentation.dto;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public record MedicalRecordResponse(
        UUID id,
        UUID patientId,
        UUID doctorId,
        String diagnosis,
        String notes,
        LocalDate visitDate,
        Instant createdAt
) {
}
