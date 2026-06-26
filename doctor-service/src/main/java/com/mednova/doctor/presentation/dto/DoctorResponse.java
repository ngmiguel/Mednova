package com.mednova.doctor.presentation.dto;

import com.mednova.doctor.domain.model.Specialty;

import java.time.Instant;
import java.util.UUID;

public record DoctorResponse(
        UUID id,
        UUID userId,
        String firstName,
        String lastName,
        String email,
        String phone,
        Specialty specialty,
        String licenseNumber,
        String bio,
        boolean active,
        Instant createdAt,
        Instant updatedAt
) {
}
