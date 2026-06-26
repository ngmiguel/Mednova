package com.mednova.patient.presentation.dto;

import com.mednova.patient.domain.model.BloodType;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public record PatientResponse(
        UUID id,
        UUID userId,
        String firstName,
        String lastName,
        String email,
        String phone,
        LocalDate dateOfBirth,
        BloodType bloodType,
        String gender,
        String address,
        String emergencyContact,
        Instant createdAt,
        Instant updatedAt
) {
}
